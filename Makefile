
datasets/enwiki.fa_revisions.5k.json:
	wget -qO- https://quarry.wmflabs.org/run/123179/output/0/json-lines?download=true > \
	datasets/enwiki.fa_revisions.5k.json

datasets/enwiki.fa_sentences.bz2: datasets/enwiki.fa_revisions.5k.json
	cat datasets/enwiki.fa_revisions.5k.json | \
	./utility extract_sentences \
	  --host https://en.wikipedia.org \
	  --verbose | bzip2 -c > \
	datasets/enwiki.fa_sentences.bz2

