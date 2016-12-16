library(ggplot2)
library(data.table)

fa_scores = data.table(read.table("../datasets/enwiki.fa_sentence_scores.tsv",
                                  sep="\t", header=T, quote="", comment.char=""))
fa_scores$quality = "FA"

spam_scores = data.table(read.table("../datasets/enwiki.spam_sentence_scores.tsv",
                                    sep="\t", header=T, quote="", comment.char=""))
spam_scores$quality = "spam"

vandalism_scores = data.table(read.table("../datasets/enwiki.vandalism_sentence_scores.tsv",
                                         sep="\t", header=T, quote="", comment.char=""))
vandalism_scores$quality = "vandalism"

attack_scores = data.table(read.table("../datasets/enwiki.attack_sentence_scores.tsv",
                                      sep="\t", header=T, quote="", comment.char=""))
attack_scores$quality = "attack"

scores = rbind(fa_scores, spam_scores, vandalism_scores, attack_scores)

scores.normalized = with(scores, rbind(
  data.table(
    rev_id,
    i,
    sentence,
    quality,
    model = "FA",
    productions,
    log_proba = enwiki.fa_sentence.normalized.model
  ),
  data.table(
    rev_id,
    i,
    sentence,
    quality,
    model = "spam",
    productions,
    log_proba = enwiki.spam_sentence.normalized.model
  ),
  data.table(
    rev_id,
    i,
    sentence,
    quality,
    model = "vandalism",
    productions,
    log_proba = enwiki.vandalism_sentence.normalized.model
  ),
  data.table(
    rev_id,
    i,
    sentence,
    quality,
    model = "attack",
    productions,
    log_proba = enwiki.attack_sentence.normalized.model
  )
))

svg("plots/proba_per_prod.density.fa_spam_vandalism_attack.svg",
    height=7, width=7)
ggplot(
    scores.normalized,
    aes(x=log_proba/productions, fill=model)
) +
facet_wrap(~quality) +
theme_bw() +
geom_density(alpha=0.2) +
scale_x_continuous("Log proba / # of Productions")
dev.off()


scores.normalized.own_model = merge(
    scores.normalized, scores.normalized[,list(rev_id, i, model, log_proba),],
    by.x=c("rev_id", "i", "quality"),
    by.y=c("rev_id", "i", "model"),
    suffixes=c("", ".own_model"))[quality != model,]

scores.normalized.own_model$log_proba_diff = with(
  scores.normalized.own_model,
  (log_proba - log_proba.own_model) / productions
)

svg("plots/proba_per_prod_difference.density.fa_spam_vandalism_attack.svg",
    height=7, width=7)
ggplot(
    scores.normalized.own_model,
    aes(x=log_proba_diff, fill=model)
) +
facet_wrap(~quality) +
theme_bw() +
geom_density(alpha=0.2) +
geom_vline(xintercept=0) +
scale_x_continuous(limits=c(-2, 2))
dev.off()

# Spam that we think looks like FA content
scores.normalized.own_model[
  quality == "spam" &
  model == "FA" &
  productions > 1,][order(log_proba_diff, decreasing=T)]
# - Not only will it stink, it's going to shorten the lifetime of the device.
# - We not too long ago had to have this carried out at our home; the basement drain was clogged; the plumber finally pulled out a mass of tree roots the scale of a volleyball!
# - Battle through hordes of undead, skeletons, orcs, goblin and monsters. (0.52)

# Spam that we're really sure is not FA
scores.normalized.own_model[
  quality == "spam" &
  model == "FA" &
  log_proba_diff > -2.7 &
  productions > 1,][order(log_proba_diff)][1:10]
# - Intuit QuickBooks Tech Support Phone\t1 800 903 7315\t\u00a024*7 Support \u00a0\n...
# - b.er\n http://upstart.ubuntu.com/wiki/Obama%2B1888%20624%204666%20Turbotax%20Helpdesk%20number,%20helpdesk%20phone%20number.

# Vandalism content that looks like FA content
scores.normalized.own_model[
  quality == "vandalism" &
  model == "FA" &
  productions > 1,][order(log_proba_diff, decreasing=T)][1:10]
# - p. 288.
# - Sodium chloride supplies essential ions.
# - The temple was destroyed in the VII century, during the Byzantine invasion.

# Vandalism that we're really sure is not FA
scores.normalized.own_model[
  quality == "vandalism" &
  model == "FA" &
  productions > 1 &
  log_proba_diff > -3.11,][order(log_proba_diff)][1:10]
# - mynamenickpang
# - HEAVEN ON TEARS HEAVEN ON TEARS <repeat 100 times>
# - UNCYCLOPEDIA IS SHIT
# - Meowwwwwwwwwwwwwww
# - charlie is jesus jesus is charlie charlie is jesus jesus is charlie charlie is jesus <repeat 100 times>
# - r.t quickbooks T.

# Attack content that looks like FA content
scores.normalized.own_model[
  quality == "attack" &
  model == "FA" &
  productions > 1,][order(log_proba_diff, decreasing=T)][1:10]
# - Colonel G.
# - p. 251.
# - Hitler was a decorated veteran of World War I.
# - 98 mm long.


# Attack that we're really sure is not FA
scores.normalized.own_model[
  quality == "attack" &
  model == "FA" &
  productions > 1 &
  log_proba_diff > -2.41,][order(log_proba_diff)][1:10]
# - POO....POO....
# - Chris Mostly Bums Dwarves Chris Mostly Bums Dwarves <repeat 20 times>
# - h.. h..
# - c.. c..
# - BEEF! BEEF!
# - REDIRECT Donald Trump
# - Integer euismod lacus luctus magna.
