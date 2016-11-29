"""
Fits a sentence scorer to a corpus of sentences.

Usage:
    fit_scorer <parser>
               [--min-freq=<num>]
               [--sentences=<path>] [--ss-model=<path>]
               [--verbose] [--debug]

Options:
    -h --help           Print this documentation
    <parser>            The classpath to a parser to use on the sentences
    --min-freq=<num>    If set, productions with lower frequency will be
                        ignored [default: 4]
    --sentences=<path>  Path to a file containing sentence to train from
                        [default: <stdin>]
    --ss-model=<path>   Path to write out sentence scorer model
                        [default: <stdout>]
    --verbose           Print dots and stuff to note progress
    --debug             Print debug logging
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

    logger.info("Loading parser...")
    parser = yamlconf.import_path(args['<parser>'])

    min_freq = int(args['--min-freq'])

    verbose = args['--verbose']

    if args['--sentences'] == "<stdin>":
        sentences = read_sentences(sys.stdin, verbose)
    else:
        sentences = read_sentences(open(args['--sentences']), verbose)

    if args['--ss-model'] == "<stdout>":
        output = sys.stdout
    else:
        output = open(args['--ss-model'], "w")

    run(parser, min_freq, sentences, output, verbose)


def run(parser, min_freq, sentences, output, verbose):

    logger.info("Training scorer...")
    ss = SentenceScorer.from_sentence_texts(
        parser.parse, sentences, min_freq=min_freq)

    ss.dump(output)


def read_sentences(f, verbose=False):
    for i, line in enumerate(f):
        if verbose and i % 10 == 0:
            sys.stderr.write(".")
            sys.stderr.flush()
        yield line.strip()

    if verbose:
        sys.stderr.write("\n")
