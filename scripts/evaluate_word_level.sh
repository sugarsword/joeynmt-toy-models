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

# measure time

SECONDS=0


for model_name in word_level_ende; do

    echo "###############################################################################"
    echo "model_name $model_name"

    translations_sub=$translations/$model_name

    mkdir -p $translations_sub

    CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $configs/$model_name.yaml < $data/tokenized.test.en-de.$src > $translations_sub/test.tokenized.$model_name.$trg

    # undo tokenization

    cat $translations_sub/test.tokenized.$model_name.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $translations_sub/test.$model_name.$trg

    # compute case-sensitive BLEU on detokenized data

    cat $translations_sub/test.$model_name.$trg | sacrebleu $data/test.en-de.$trg

done

echo "time taken:"
echo "$SECONDS seconds"


