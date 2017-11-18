# Wiki Grammar

A library for building PCFG models and a collection of models.

# Example usage

In this example, we load the English Wikipedia Featured Article model and use
it to score a couple of sentences.

```
  >>> from wikigrammar import SentenceScorer
  >>>
  >>> scorer = SentenceScorer.load(
  ...     open("models/enwiki.fa_sentence.normalized.model"))

  >>>
  >>> sentence = "I have a lovely bunch of coconuts."
  >>> score = scorer.score(sentence)
  >>> score
  {'log_proba': -6.431574747850158, 'productions': 11}
  >>> score['log_proba'] / score['productions']
  -0.5846886134409235
  >>>
  >>> sentence = "Obama was born in 1961 in Honolulu, Hawaii, two years after " + \
  ...            "the territory was admitted to the Union as the 50th state."
  >>> score = scorer.score(sentence)
  >>> score
  {'log_proba': -16.875312424797468, 'productions': 36}
  >>> score['log_proba'] / score['productions']
  -0.4687586784665963
```
