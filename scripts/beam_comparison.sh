#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
configs=$base/configs

translations=$base/translations

mkdir -p $translations

src=en
trg=de

# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$base/tools/moses-scripts/scripts

num_threads=16
device=5


beam_comparison=$base/beam_comparison
model_name=bpe_3000_ende


mkdir -p beam_comparison

for beam_size in 1 2 3 4 5 6 7 9 11 15 20 30 60; do

    echo "###############################################################################"
    echo "beam_size $beam_size"
	printf "$beam_size\n" >> $beam_comparison/size.txt
	# measure time
	SECONDS=0
    sed "s/^\(\s*beam_size\s*:\s*\).*/\1$beam_size/" configs/$model_name.yaml > $beam_comparison/beam.$beam_size.yaml
	
	CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $beam_comparison/beam.$beam_size.yaml < $data/3000.bpe.test.en-de.$src > $beam_comparison/beam.$beam_size.$trg

    # undo BPE (this does not do anything: https://github.com/joeynmt/joeynmt/issues/91)

    cat $beam_comparison/beam.$beam_size.$trg | sed 's/\@\@ //g' > $beam_comparison/test.truecased.beam.$beam_size.$trg

    # undo truecasing

    cat $beam_comparison/test.truecased.beam.$beam_size.$trg | $MOSES/recaser/detruecase.perl > $beam_comparison/test.tokenized.beam.$beam_size.$trg

    # undo tokenization

    cat $beam_comparison/test.tokenized.beam.$beam_size.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $beam_comparison/test.beam.$beam_size.$trg

    # compute case-sensitive BLEU on detokenized data

    cat $beam_comparison/test.beam.$beam_size.$trg | sacrebleu -b $data/test.en-de.$trg >> $beam_comparison/score.txt

	echo "time taken for beam size $beam_size:"
	echo "$SECONDS seconds"
	printf "$SECONDS\n" >> $beam_comparison/time.txt
done

python3 $scripts/plot_beam.py --beam_size $beam_comparison/size.txt --score $beam_comparison/score.txt --time $beam_comparison/time.txt --graph $beam_comparison/beam.png
