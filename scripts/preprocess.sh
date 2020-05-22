#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
tools=$base/tools

mkdir -p $base/shared_models

src=en
trg=de

shared_models=$base/shared_models


# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$tools/moses-scripts/scripts

train_size=100000
vocab_size=2000
bpe_vocab_threshold=10

#################################################################
# take {train_size} of sentences randomly from the train data
# if this leads to out-of-memory on your machine, use the argument --memory-efficient 
python $scripts/subsample.py \
 --src-input $data/train.$src-$trg.$src \
 --trg-input $data/train.$src-$trg.$trg \
 --src-output $data/subsample.train.$src-$trg.$src \
 --trg-output $data/subsample.train.$src-$trg.$trg \
 --size $train_size   
 

for corpus in subsample.train test dev; do
	$MOSES/tokenizer/tokenizer.perl -l $src < $data/$corpus.$src-$trg.$src > $data/tokenized.$corpus.$src-$trg.$src 
	$MOSES/tokenizer/tokenizer.perl -l $trg < $data/$corpus.$src-$trg.$trg > $data/tokenized.$corpus.$src-$trg.$trg  
done   
 
wc -l $data/*tokenized.*
 
# prepare bpe data for bpe_level  


# measure time
SECONDS=0

for vocab_size in 1000 2000 3000; do
	# learn BPE model on train (concatenate both languages)
	subword-nmt learn-joint-bpe-and-vocab -i $data/tokenized.subsample.train.$src-$trg.$src $data/tokenized.subsample.train.$src-$trg.$trg \
		--write-vocabulary $shared_models/vocab.$vocab_size.$src $shared_models/vocab.$vocab_size.$trg \
		-s $vocab_size --total-symbols -o $shared_models/$src$trg.$vocab_size.bpe

	
	#build a common dictionary for both languages
	python tools/joeynmt/scripts/build_vocab.py \
		$shared_models/vocab.$vocab_size.$src $shared_models/vocab.$vocab_size.$trg \
		--output_path $shared_models/vocab.$vocab_size.joined.$src-$trg
	
	# apply BPE model to train, test and dev
	for corpus in subsample.train dev test; do
		subword-nmt apply-bpe -c $shared_models/$src$trg.$vocab_size.bpe --vocabulary $shared_models/vocab.$vocab_size.$src --vocabulary-threshold $bpe_vocab_threshold < $data/tokenized.$corpus.$src-$trg.$src > $data/$vocab_size.bpe.$corpus.$src-$trg.$src
		subword-nmt apply-bpe -c $shared_models/$src$trg.$vocab_size.bpe --vocabulary $shared_models/vocab.$vocab_size.$trg --vocabulary-threshold $bpe_vocab_threshold < $data/tokenized.$corpus.$src-$trg.$trg > $data/$vocab_size.bpe.$corpus.$src-$trg.$trg
	done
done



# sanity checks   

echo "time taken:"
echo "$SECONDS seconds"

