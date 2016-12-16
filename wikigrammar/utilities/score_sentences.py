"""
Scores all sentences from a set of observations and writes a TSV.

Usage:
    score_sentences <model>...
               [--input=<path>] [--output=<path>]
               [--workers=<num>]
               [--verbose] [--debug]

Options:
    -h --help        Print this documentation
    <model>          The path to a model file to load
    --input=<path>   Path to a file containing observations [default: <stdin>]
    --output=<path>  Path to a file to revision sentence scores
                     [default: <stdout>]
    --workers=<num>  The number of parallel workers to spool up for sentence
                     extraction [default: <cpu-count>]
    --verbose        Print dots and stuff to note progress
    --debug          Print debug logging
"""
import logging
import os.path
import sys
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

import docopt
import mysqltsv
from revscoring.datasources import revision_oriented as ro
from revscoring.dependencies import solve
from revscoring.errors import RevisionNotFound, TextDeleted
from revscoring.features import wikitext
from revscoring.utilities.util import read_observations

from ..functions import clean_wikitext
from ..sentence_scorer import SentenceScorer

logger = logging.getLogger(__name__)


def main(argv=None):
    args = docopt.docopt(__doc__, argv=argv)

    logging.basicConfig(
        level=logging.INFO if not args['--debug'] else logging.DEBUG,
        format='%(asctime)s %(levelname)s:%(name)s -- %(message)s'
    )
    logging.getLogger('requests').setLevel(logging.WARNING)

    logger.info("Loading models...")
    models = [(os.path.basename(path), SentenceScorer.load(open(path)))
              for path in args['<model>']]

    if args['--input'] == "<stdin>":
        obs = read_observations(sys.stdin)
    else:
        obs = read_observations(open(args['--input']))

    if args['--output'] == "<stdout>":
        output = sys.stdout
    else:
        output = open(args['--output'], 'w')

    if args['--workers'] == "<cpu-count>":
        workers = cpu_count()
    else:
        workers = int(args['--workers'])

    verbose = args['--verbose']

    run(models, obs, output, workers, verbose)


def run(models, obs, output, workers, verbose):
    writer = mysqltsv.Writer(
        output, headers=['rev_id', 'i', 'sentence', 'length', 'productions'] +
                        [name for name, model in models])

    se_scorer = SentenceExtractorScorer(models)
    with ProcessPoolExecutor(max_workers=workers) as executor:
        logger.info("Processing sentences...")
        for error, r_i_s_l_scores in executor.map(se_scorer.score, obs):
            if error is None:
                for rev_id, i, sent, slen, scores in r_i_s_l_scores:
                    writer.write([rev_id, i, sent, slen,
                                  scores[0]['productions']] +
                                 [s['log_proba'] for s in scores])
                    if verbose:
                        sys.stderr.write(".")
                        sys.stderr.flush()
            else:
                sys.stderr.write(str(error))
                sys.stderr.write('\n')

            if verbose:
                sys.stderr.flush()


class SentenceExtractorScorer:

    def __init__(self, models):
        self.models = models

    def score(self, ob):
        try:
            # Extract sentences
            sentences = solve(wikitext.revision.datasources.sentences,
                              cache={ro.revision.text: ob['text']})

            clean_sentences = [
                clean_wikitext("".join(str(t) for t in sentence))
                for sentence in sentences]

            return None, [(ob['rev_id'], i, s[:10] + "..." + s[-10:], len(s),
                           [m.score(s) for _, m in self.models])
                          for i, s in enumerate(clean_sentences)
                          if len(s) > 0]
        except Exception as e:
            return e, []
