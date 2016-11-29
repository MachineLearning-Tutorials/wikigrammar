import mwparserfromhell as mwparser
from mwparserfromhell.nodes import Heading, Wikilink


def clean_wikitext(sentence_text):
    wikicode = mwparser.parse(sentence_text.strip())
    stripped_text = strip_wikicode(wikicode)
    return stripped_text.replace("\t", "\\t").replace("\n", "\\n")


def strip_wikicode(wikicode):
    return "".join(_strip_wikicode(wikicode))


def _strip_wikicode(wikicode):

    for node in wikicode.nodes:
        stripped = node.__strip__(normalize=True, collapse=True)
        if isinstance(node, Wikilink):
            stripped = stripped.split("|")[-1]
        if stripped is not None:
            yield str(stripped.strip("\n"))
