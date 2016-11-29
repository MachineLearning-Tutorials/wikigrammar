import logging
import pickle
import traceback

from kasami import TreeScorer

logger = logging.getLogger(__name__)


class SentenceScorer:

    def __init__(self, parse, tree_scorer):
        self.parse = parse
        self.scorer = tree_scorer

    def score(self, sentence_text):
        tree = self.parse(sentence_text)
        return self.scorer.score(tree)

    @classmethod
    def load(cls, f):
        """
        Reads serialized model information from a file.
        """
        if hasattr(f, 'buffer'):
            return pickle.load(f.buffer)
        else:
            return pickle.load(f)

    def dump(self, f):
        """
        Writes serialized model information to a file.
        """

        if hasattr(f, 'buffer'):
            return pickle.dump(self, f.buffer)
        else:
            return pickle.dump(self, f)

    @classmethod
    def from_sentence_texts(cls, parse, sentence_texts, min_freq=None):
        trees = cls.parse_sentences_and_log_warnings(parse, sentence_texts)
        tree_scorer = TreeScorer.from_tree_bank(trees, min_freq=min_freq)
        return cls(parse, tree_scorer)

    @classmethod
    def parse_sentences_and_log_warnings(self, parse, sentence_texts):
        for sentence_text in sentence_texts:
            try:
                tree = parse(sentence_text)
                yield tree
            except:
                logger.warn("Could not parse sentence {0}."
                            .format(sentence_text))
                logger.warn(traceback.format_exc())
