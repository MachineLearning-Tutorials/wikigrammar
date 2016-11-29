
################## Featured Articles ##########################################
datasets/enwiki.fa_revisions.5k.json:
	wget -qO- https://quarry.wmflabs.org/run/123179/output/0/json-lines?download=true > \
	datasets/enwiki.fa_revisions.5k.json

datasets/enwiki.fa_revisions.with_text.5k.json.bz2: \
		datasets/enwiki.fa_revisions.5k.json
	cat datasets/enwiki.fa_revisions.5k.json | \
	./utility fetch_text --host https://en.wikipedia.org --verbose | \
	bzip2 -c > \
	datasets/enwiki.fa_revisions.with_text.5k.json.bz2

datasets/enwiki.fa_sentences.bz2: \
		datasets/enwiki.fa_revisions.with_text.5k.json.bz2
	bzcat datasets/enwiki.fa_revisions.with_text.5k.json.bz2 | \
	./utility extract_sentences \
	  --verbose | bzip2 -c > \
	datasets/enwiki.fa_sentences.bz2

models/enwiki.fa_sentence.normalized.model: datasets/enwiki.fa_sentences.bz2
	bzcat datasets/enwiki.fa_sentences.bz2 | \
	./utility fit_scorer wikigrammar.parsers.spacy_en_normalized \
	  --verbose > \
	models/enwiki.fa_sentence.normalized.model

datasets/enwiki.fa_sentence_scores.tsv: \
		models/enwiki.fa_sentence.normalized.model \
		datasets/enwiki.fa_revisions.5k.json
	cat datasets/enwiki.fa_revisions.5k.json | \
	./utility score_sentences \
		models/enwiki.fa_sentence.normalized.model \
		models/enwiki.spam_sentence.normalized.model \
		models/enwiki.vandalism_sentence.normalized.model \
		models/enwiki.attack_sentence.normalized.model \
		--host https://en.wikipedia.org \
		--workers 1 \
		--verbose > \
	datasets/enwiki.fa_sentence_scores.tsv

################## Spam, vandalism, and attack ################################
datasets/enwiki.not_ok_draft_quality.revisions.json:
	wget https://github.com/wiki-ai/draftquality/raw/master/datasets/enwiki.draft_quality.201508-201608.tsv.bz2 -qO- | \
	bzcat - | \
	grep -P "\t(spam|vandalism|attack|rev_id\t)" | \
	cut -f2,5 | \
	tsv2json int str > \
	datasets/enwiki.not_ok_draft_quality.revisions.json

################# Spam ########################################################
datasets/enwiki.spam_revisions.18k.json:
	cat datasets/enwiki.not_ok_draft_quality.revisions.json | \
	grep '"draft_quality": "spam"' > \
	datasets/enwiki.spam_revisions.18k.json

datasets/enwiki.spam_revisions.with_text.18k.json.bz2: \
		datasets/enwiki.spam_revisions.18k.json
	cat datasets/enwiki.spam_revisions.18k.json | \
	./utility fetch_text --host https://en.wikipedia.org \
	  --verbose --deleted-1st | \
	bzip2 -c > \
	datasets/enwiki.spam_revisions.with_text.18k.json.bz2

datasets/enwiki.spam_sentences.bz2: \
		datasets/enwiki.spam_revisions.with_text.18k.json.bz2
	bzcat datasets/enwiki.spam_revisions.with_text.18k.json.bz2 | \
	./utility extract_sentences \
	  --verbose | bzip2 -c > \
	datasets/enwiki.spam_sentences.bz2

models/enwiki.spam_sentence.normalized.model: \
		datasets/enwiki.spam_sentences.bz2
	bzcat datasets/enwiki.spam_sentences.bz2 | \
	./utility fit_scorer wikigrammar.parsers.spacy_en_normalized \
	  --verbose > \
	models/enwiki.spam_sentence.normalized.model

datasets/enwiki.spam_sentence_scores.tsv: \
		models/enwiki.spam_sentence.normalized.model \
		datasets/enwiki.spam_revisions.18k.json.bz2
	bzcat datasets/enwiki.spam_revisions.18k.json.bz2 | \
	./utility score_sentences \
		models/enwiki.fa_sentence.normalized.model \
		models/enwiki.spam_sentence.normalized.model \
		models/enwiki.vandalism_sentence.normalized.model \
		models/enwiki.attack_sentence.normalized.model \
		--workers 1 \
		--verbose > \
	datasets/enwiki.spam_sentence_scores.tsv

################# Vandalism ###################################################
datasets/enwiki.vandalism_revisions.7k.json:
	cat datasets/enwiki.not_ok_draft_quality.revisions.json | \
	grep '"draft_quality": "vandalism"' > \
	datasets/enwiki.vandalism_revisions.7k.json

datasets/enwiki.vandalism_revisions.with_text.7k.json.bz2: \
		datasets/enwiki.vandalism_revisions.7k.json
	cat datasets/enwiki.vandalism_revisions.7k.json | \
	./utility fetch_text --host https://en.wikipedia.org \
	  --verbose --deleted-1st | \
	bzip2 -c > \
	datasets/enwiki.vandalism_revisions.with_text.7k.json.bz2

datasets/enwiki.vandalism_sentences.bz2: \
		datasets/enwiki.vandalism_revisions.with_text.7k.json.bz2
	bzcat datasets/enwiki.vandalism_revisions.with_text.7k.json.bz2 | \
	./utility extract_sentences \
	  --verbose | bzip2 -c > \
	datasets/enwiki.vandalism_sentences.bz2

models/enwiki.vandalism_sentence.normalized.model: \
		datasets/enwiki.vandalism_sentences.bz2
	bzcat datasets/enwiki.vandalism_sentences.bz2 | \
	./utility fit_scorer wikigrammar.parsers.spacy_en_normalized \
	  --verbose > \
	models/enwiki.vandalism_sentence.normalized.model

datasets/enwiki.vandalism_sentence_scores.tsv: \
		models/enwiki.vandalism_sentence.normalized.model \
		datasets/enwiki.vandalism_revisions.with_text.7k.json.bz2
	bzcat datasets/enwiki.vandalism_revisions.with_text.7k.json.bz2 | \
	./utility score_sentences \
		models/enwiki.fa_sentence.normalized.model \
		models/enwiki.spam_sentence.normalized.model \
		models/enwiki.vandalism_sentence.normalized.model \
		models/enwiki.attack_sentence.normalized.model \
		--workers 1 \
		--verbose > \
	datasets/enwiki.vandalism_sentence_scores.tsv

################# Attack ######################################################
datasets/enwiki.attack_revisions.2k.json:
	cat datasets/enwiki.not_ok_draft_quality.revisions.json | \
	grep '"draft_quality": "attack"' > \
	datasets/enwiki.attack_revisionshttp://pythonhosted.org/mwapi/ith_text.2k.json.bz2: \
		datasets/enwiki.attack_revisions.2k.json
	cat datasets/enwiki.attack_revisions.2k.json | \
	./utility fetch_text --host https://en.wikipedia.org \
	  --verbose --deleted-1st | \
	bzip2 -c > \
	datasets/enwiki.attack_revisions.with_text.2k.json.bz2

datasets/enwiki.attack_sentences.bz2: \
		datasets/enwiki.attack_revisions.with_text.2k.json.bz2
	bzcat datasets/enwiki.attack_revisions.with_text.2k.json.bz2 | \
	./utility extract_sentences \
	  --verbose | bzip2 -c > \
	datasets/enwiki.attack_sentences.bz2

models/enwiki.attack_sentence.normalized.model: \
		datasets/enwiki.attack_sentences.bz2
	bzcat datasets/enwiki.attack_sentences.bz2 | \
	./utility fit_scorer wikigrammar.parsers.spacy_en_normalized \
	  --verbose > \
	models/enwiki.attack_sentence.normalized.model

datasets/enwiki.attack_sentence_scores.tsv: \
		models/enwiki.attack_sentence.normalized.model \
		datasets/enwiki.attack_revisions.with_text.2k.json.bz2
	bzcat datasets/enwiki.attack_revisions.with_text.2k.json.bz2 | \
	./utility score_sentences \
		models/enwiki.fa_sentence.normalized.model \
		models/enwiki.spam_sentence.normalized.model \
		models/enwiki.vandalism_sentence.normalized.model \
		models/enwiki.attack_sentence.normalized.model \
		--workers 1 \
		--verbose > \
	datasets/enwiki.attack_sentence_scores.tsv
