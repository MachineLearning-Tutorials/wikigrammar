from wikigrammar import SentenceScorer

scorer = SentenceScorer.load(
    open("models/enwiki.fa_sentence.normalized.model"))

sentence = "I have a lovely bunch of coconuts."
score = scorer.score(sentence)
score
score['log_proba'] / score['productions']

sentence = "Obama was born in 1961 in Honolulu, Hawaii, two years after " + \
           "the territory was admitted to the Union as the 50th state."
score = scorer.score(sentence)
score
score['log_proba'] / score['productions']
