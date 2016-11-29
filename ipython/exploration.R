library(ggplot2)
library(data.table)

fa_scores = data.table(read.table("../datasets/enwiki.fa_sentence_scores.tsv",
                                  sep="\t", header=T, quote="", comment.char=""))
fa_scores[1:5,]


ggplot(
    fa_scores,
    aes(x=enwiki.fa_sentence.normalized.model/productions)
) +
theme_bw() +
geom_density()

fa_scores.normalized = with(fa_scores, rbind(
  data.table(
    productions = productions,
    model = "FA",
    log_proba = enwiki.fa_sentence.normalized.model
  ),
  data.table(
    productions = productions,
    model = "spam",
    log_proba = enwiki.spam_sentence.normalized.model
  ),
  data.table(
    productions = productions,
    model = "vandalism",
    log_proba = enwiki.vandalism_sentence.normalized.model
  ),
  data.table(
    productions = productions,
    model = "attack",
    log_proba = enwiki.attack_sentence.normalized.model
  )
))

ggplot(
    fa_scores.normalized,
    aes(x=log_proba/productions, fill=model)
) +
theme_bw() +
geom_density(alpha=0.2)
