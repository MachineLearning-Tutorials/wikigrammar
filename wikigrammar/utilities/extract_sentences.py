"""
Extracts sentences for a set of observations (with text) provided.
Writes out a file where each line contains a complete sentence.
Tabs and linebreaks are escaped as `\t` and `\n` respectively.

Usage:
    extract_sentences [--input=<path>] [--output=<path>]
                      [--workers=<num>]
                      [--verbose] [--debug]

Options:
    -h --help        Print this documentation
    --input=<path>   Path to a file containing observations [default: <stdin>]
    --output=<path>  Path to a file to write new observations to
                     [default: <stdout>]
    --workers=<num>  The number of parallel workers to spool up for sentence
                     extraction [default: <cpu-count>]
    --verbose        Print dots and stuff to note progress
    --debug          Print debug logging

"""
import logging
import sys
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import cpu_count

import docopt
from revscoring.datasources import revision_oriented as ro
from revscoring.dependencies import solve
from revscoring.features import wikitext
from revscoring.utilities.util import read_observations

from ..functions import clean_wikitext


def main(argv=None):
    args = docopt.docopt(__doc__, argv=argv)

    logging.basicConfig(
        level=logging.WARNING if not args['--debug'] else logging.DEBUG,
        format='%(asctime)s %(levelname)s:%(name)s -- %(message)s'
    )

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

    run(obs, output, workers, verbose)


def run(obs, output, workers, verbose):

    with ProcessPoolExecutor(max_workers=workers) as executor:
        for sentences in executor.map(solve_sentences, obs):
            if verbose:
                sys.stderr.write("{0: 4d}: {1}\n".format(
                    len(sentences), "." * int(len(sentences) / 10)))
                sys.stderr.flush()
            for sentence in sentences:
                if len(sentence) > 0:
                    output.write(sentence)
                    output.write("\n")


def solve_sentences(ob):
    # Extract sentences
    sentences = solve(wikitext.revision.datasources.sentences,
                      cache={ro.revision.text: ob['text']})

    # Clean them up
    return [clean_wikitext("".join(str(t) for t in sentence))
            for sentence in sentences]
