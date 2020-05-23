#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

models=$base/models
configs=$base/configs

mkdir -p $models

num_threads=16
device=0

# measure time

SECONDS=0


#change model name for each training
model_name=bpe_1000_ende
 


CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt train $configs/$model_name.yaml


echo "time taken:"
echo "$SECONDS seconds"
