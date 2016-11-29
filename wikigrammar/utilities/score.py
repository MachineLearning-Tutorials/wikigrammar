"""
Scores a single sentence using a scorer

Usage:
    fit_scorer <model> <sentence>
               [--verbose] [--debug]

Options:
    -h --help  Print this documentation
    <model>    The path to a model file to load
    <sentence>    A sentence to score
    --verbose  Print dots and stuff to note progress
    --debug    Print debug logging
"""
import logging
import sys

import docopt
import yamlconf

from ..sentence_scorer import SentenceScorer

logger = logging.getLogger(__name__)


def main(argv=None):
    args = docopt.docopt(__doc__, argv=argv)

    logging.basicConfig(
        level=logging.INFO if not args['--debug'] else logging.DEBUG,
        format='%(asctime)s %(levelname)s:%(name)s -- %(message)s'
    )

    logger.info("Loading model...")
    model = SentenceScorer.load(open(args['<model>']))
    sentence = args['<sentence>']
    verbose = args['--verbose']

    run(model, sentence, verbose)


def run(model, sentence, verbose):
    print(model.score(sentence))
