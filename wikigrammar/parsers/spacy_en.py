import kasami.normalizers
from spacy.en import English

spacy_en_parse = English()


def parse(sentence_text):
    doc = spacy_en_parse(sentence_text)
    return kasami.normalizers.spacy(doc)
