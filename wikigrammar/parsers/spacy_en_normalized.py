from kasami import SymbolNode, TerminalNode

from . import spacy_en

MAP = {
    "NNP": "NNP",
    "CD": "CD"
}


def parse(sentence_text):
    tree = spacy_en.parse(sentence_text)
    return normalize(tree)


def normalize(tree):
    if isinstance(tree, SymbolNode):
        targets = [normalize(sub_tree) for sub_tree in tree.produces]
        return SymbolNode(tree.source, targets)
    else:
        if tree.source in MAP:
            return TerminalNode(tree.source, MAP[tree.source])
        else:
            return tree
