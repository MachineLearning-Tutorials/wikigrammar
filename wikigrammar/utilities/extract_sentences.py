"""
Extracts sentences for a set of revisions provided.  Writes out a file where
each line contains a complete sentence.  Tabs and linebreaks are escaped as
`\t` and `\n` respectively.

Usage:
    extract_sentences --host=<url> [--input=<path>] [--output=<path>]
                      [--workers=<num>]
                      [--verbose] [--debug]

Options:
    -h --help        Print this documentation
    --host=<url>     The host URL of a MediaWiki installation to extract
                     text from
    --input=<path>   Path to a file containing observations [default: <stdin>]
    --output=<path>  Path to a file to write new observations to
                     [default: <stdout>]
    --workers=<num>  The number of parallel workers to spool up for sentence
                     extraction [default: <cpu-count>]

"""
import logging
import sys
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

import docopt
import mwapi
from revscoring.extractors import api
from revscoring.features import wikitext
from revscoring.utilities.util import read_observations

from ..functions import clean_wikitext


def main(argv=None):
    args = docopt.docopt(__doc__, argv=argv)

    logging.basicConfig(
        level=logging.WARNING if not args['--debug'] else logging.DEBUG,
        format='%(asctime)s %(levelname)s:%(name)s -- %(message)s'
    )

    host = args['--host']

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

    run(host, obs, output, workers, verbose)


def run(host, obs, output, workers, verbose):
    extractor = api.Extractor(mwapi.Session(
        host, user_agent="Wikigrammar sentence extractor"))

    sentence_extractor = SentenceExtractor(extractor)
    with ProcessPoolExecutor(max_workers=workers) as executor:
        for sentences in executor.map(sentence_extractor.extract, obs):
            if verbose:
                sys.stderr.write("{0}: {1}\n".format(
                    len(sentences), "." * int(len(sentences) / 10)))
            for sentence in sentences:
                output.write(sentence)
                output.write("\n")


class SentenceExtractor:

    def __init__(self, extractor):
        self.extractor = extractor

    def extract(self, ob):
        # Extract sentences
        sentences = self.extractor.extract(
            ob['rev_id'], wikitext.revision.datasources.sentences)

        # Clean them up
        return [clean_wikitext("".join(str(t) for t in sentence))
                for sentence in sentences]
