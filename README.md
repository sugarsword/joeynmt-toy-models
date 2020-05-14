# joeynmt-toy-models

This repo is just a collection of scripts showing how to install [JoeyNMT](https://github.com/joeynmt/joeynmt), preprocess
data, train and evaluate models.

# Requirements

- This only works on a Unix-like system, with bash.
- Python 3 must be installed on your system, i.e. the command `python3` must be available
- Make sure virtualenv is installed on your system. To install, e.g.

    `pip install virtualenv`

# Steps

Clone this repository in the desired place and check out the correct branch:

    git clone https://github.com/bricksdont/joeynmt-toy-models
    cd joeynmt-toy-models
    checkout ex4

Create a new virtualenv that uses Python 3. Please make sure to run this command outside of any virtual Python environment:

    ./scripts/make_virtualenv.sh

**Important**: Then activate the env by executing the `source` command that is output by the shell script above.

Download and install required software:

    ./scripts/download_install_packages.sh

Download and split data:

    ./scripts/download_split_data.sh

Preprocess data:

    ./scripts/preprocess.sh

Then finally train a model:

    ./scripts/train.sh

The training process can be interrupted at any time, and the best checkpoint will always be saved.

Evaluate a trained model with

    ./scripts/evaluate.sh

--------------------------
# Exercise 4 Report

Working plan:
- train baseline model with rnn_wmt16_yaml as instructed above, evaluate
- modify model.py : according to changes made in the branch factors_incomplete

	in batch.py: self.factor, in data.py: factor_vocab, use_factor, factor_field,
	
	in initialization.py: factor_padding_idx: int, factor_embed
	
	in rnn_wmt16_add_deen.yaml: factor_combine
	
  modify the embedding size in the encode function to accomodate factor input,
  
  raise ConfigurationError for dimension incompatibilities
  
- train one new model with "add" factor one model with "concatenate" factor
- evaluate both models


Realisation report:
1) fork repo: joeynmt-toy-models, fork repo: joeynmt
2) clone joeynmt-toy-models, create virtual environment
3) in joeynmt-toy-models: `git checkout ex4`
4) modify scripts/download_install_packages.sh install from own fork of joeynmt
5) `./scripts/download_install_packages.sh`
6) `./scripts/download_preprocessed_data.sh`
8) `./scripts/train.sh`  #baseline model trained, inspect train.log
9) `./scripts/evaluate.sh` #baseline model bleu score
10) create new branch in tools/joeynmt: `git checkout -b factors_ss`
11) in factors_ss modify tools/joeynmt/joeynmt/model.py
12) in tools/joeynmt, `pip install -upgrade .` reinstall joeynmt
13) substitute the '?' with dimensions in rnn_wmt16_factors_concatenate_deen.yaml
14) modify train.sh to train one "concatenate" factor model
15) modify evaluate.sh to evaluate one "concatenate" factor model
16) substitute the '?' with dimensions in rnn_wmt16_factors_add_deen.yaml
17) modify train.sh to train one "add" factor model
18) modify evaluate.sh to evaluate one "add" factor model
19) repeated 15-17 above to train and evaluate another "add" factor model with dimension size 256
15) create comparison table in README.md
16) commit all the changes and push them all to remote joeynmt repo and joeynmt-toy-models repo


Model comparison table


| Model name | soure dimension | factor dimension | target dimension | Hidden dimension| BLEU | Time |
|---|---|---|---|---|---|   ------   |
|  |--- |--- |--- |  (same for source and target)|---|---|
|rnn_wmt16_deen|512|n/a|512|1024|8.9|46242sec (4cpu engine)|
|rnn_wmt16 _add_deen|512|512|512|1024|1.6|30566sec (8cpu engine)|
|rnn_wmt16 _concatenate_deen|256|256|512|1024|8.3|28932sec (8cpu engine)|
|rnn_wmt16 _add_256_deen|256|256|256|1024|8.6|27180sec (8cpu engine)|


Comment: just from this table, with the same embedding size and calculation time, I cannot see great improvement for using factors. Did I miss something important?
I took the same dimension sizes as in the baseline model to make the comparison meaningful. However the BLEU score for the "add" factor is strangely low (1.6). There might be somethin wrong with my model? I trained another "add" factor model with another set of dimension and called it the rnn_wmt16_add_256_deen model. The BLEU score improved (8.6). I wonder what was the reason for the differences in result? I did not make any changes more in the model.py after I started training the factor models. I only changed the dimensions in the configuration files.

Another impression is that this project consumes much machine time and disk space, a trained model is about 2G size, depending on the dimensions.


# Excerpts from train.log and results from evaluation

baseline model

  	2020-05-10 06:49:09,616 Epoch   2 Step:     6100 Batch Loss:     2.568165 Tokens per Sec:      222, Lr: 0.000300
  	2020-05-10 06:58:27,122 Epoch   2 Step:     6200 Batch Loss:     2.423815 Tokens per Sec:      217, Lr: 0.000300
  	2020-05-10 07:07:28,082 Epoch   2 Step:     6300 Batch Loss:     2.451769 Tokens per Sec:      218, Lr: 0.000300
  	2020-05-10 07:16:34,874 Epoch   2 Step:     6400 Batch Loss:     2.541642 Tokens per Sec:      219, Lr: 0.000300
  	2020-05-10 07:24:56,565 Epoch   2: total training loss 8575.20
  	2020-05-10 07:24:56,565 Training ended after   2 epochs.
  	2020-05-10 07:24:56,567 Best validation result (greedy) at step     6000:  18.57 ppl.
  	2020-05-10 06:39:57,175 Validation result (greedy) at epoch   2, step     6000: bleu:   6.07, loss: 265490.9688, ppl:  18.5690, duration: 823.7788s

  	###############################################################################
  	model_name rnn_wmt16_deen
  	2020-05-10 08:07:06,813 Hello! This is Joey-NMT.
  	Detokenizer Version $Revision: 4134 $
  	Language: en
  	BLEU+case.mixed+numrefs.1+smooth.exp+tok.13a+version.1.4.9 = 8.7 40.1/13.6/5.3/2.2 (BP = 0.974 ratio = 0.974 hyp_len = 62473 ref_len = 64132)
  	time taken:
  	1700 seconds
  	
  	
"add" factor model
  	
  	2020-05-10 14:18:01,522 Validation result (greedy) at epoch   2, step     6000: bleu:   1.27, loss: 332963.6562, ppl:  39.0161, duration: 510.6265s
  	2020-05-10 14:23:57,901 Epoch   2 Step:     6100 Batch Loss:     3.161341 Tokens per Sec:      345, Lr: 0.000300
  	2020-05-10 14:29:49,471 Epoch   2 Step:     6200 Batch Loss:     3.143417 Tokens per Sec:      344, Lr: 0.000300
  	2020-05-10 14:35:41,824 Epoch   2 Step:     6300 Batch Loss:     3.046057 Tokens per Sec:      335, Lr: 0.000300
  	2020-05-10 14:41:32,982 Epoch   2 Step:     6400 Batch Loss:     3.235485 Tokens per Sec:      341, Lr: 0.000300
  	2020-05-10 14:46:51,537 Epoch   2: total training loss 10548.34
  	2020-05-10 14:46:51,538 Training ended after   2 epochs.
  	2020-05-10 14:46:51,539 Best validation result (greedy) at step     6000:  39.02 ppl.
  	2020-05-10 15:01:40,045 test bleu:   1.65 [Beam search decoding with beam size = 5 and alpha = 1.0]
  	2020-05-10 15:01:40,047 Translations saved to: models/rnn_wmt16_factors_add_deen/00006000.hyps.test
  	2020-05-10 15:11:56,198  dev bleu:   1.54 [Beam search decoding with beam size = 5 and alpha = 1.0]
  	2020-05-10 15:11:56,200 Translations saved to: models/rnn_wmt16_factors_add_deen/00006000.hyps.dev
  	time taken:
  	30566 seconds

valuation result:

  	###############################################################################
  	model_name rnn_wmt16_factors_add_deen
  	2020-05-10 15:18:09,998 Hello! This is Joey-NMT.
  	Detokenizer Version $Revision: 4134 $
  	Language: en
  	BLEU+case.mixed+numrefs.1+smooth.exp+tok.13a+version.1.4.9 = 1.6 25.5/3.7/0.6/0.1 (BP = 0.992 ratio = 0.992 hyp_len = 63608 ref_len = 64132)
  	time taken:
  	932 seconds
  	
  	
"concatenate" factor model
  	
  	2020-05-10 03:18:05,163 Validation result (greedy) at epoch   2, step     6000: bleu:   5.48, loss: 268557.9688, ppl:  19.2064, duration: 478.3398s
  	2020-05-10 03:23:38,909 Epoch   2 Step:     6100 Batch Loss:     2.605097 Tokens per Sec:      368, Lr: 0.000300
  	2020-05-10 03:29:10,487 Epoch   2 Step:     6200 Batch Loss:     2.493124 Tokens per Sec:      364, Lr: 0.000300
  	2020-05-10 03:34:40,631 Epoch   2 Step:     6300 Batch Loss:     2.548773 Tokens per Sec:      357, Lr: 0.000300
  	2020-05-10 03:40:10,027 Epoch   2 Step:     6400 Batch Loss:     2.678240 Tokens per Sec:      364, Lr: 0.000300
  	2020-05-10 03:45:12,636 Epoch   2: total training loss 8856.16
  	2020-05-10 03:45:12,637 Training ended after   2 epochs.
  	2020-05-10 03:45:12,638 Best validation result (greedy) at step     6000:  19.21 ppl.
  	2020-05-10 03:54:49,869  dev bleu:   7.25 [Beam search decoding with beam size = 5 and alpha = 1.0]
  	2020-05-10 03:54:49,872 Translations saved to: models/rnn_wmt16_factors_concatenate_deen/00006000.hyps.dev
  	2020-05-10 04:08:38,780 test bleu:   8.14 [Beam search decoding with beam size = 5 and alpha = 1.0]
  	2020-05-10 04:08:38,782 Translations saved to: models/rnn_wmt16_factors_concatenate_deen/00006000.hyps.test


  	###############################################################################    
	model_name rnn_wmt16_factors_concatenate_deen
  	2020-05-10 05:26:34,663 Hello! This is Joey-NMT.
  	Detokenizer Version $Revision: 4134 $
  	Language: en
  	BLEU+case.mixed+numrefs.1+smooth.exp+tok.13a+version.1.4.9 = 8.3 41.8/14.1/5.6/2.3 (BP = 0.883 ratio = 0.889 hyp_len = 57038 ref_len = 64132)
  	time taken:
  	855 seconds
  	
"add" factor with embedding dimension 256
  	
  	2020-05-08 22:36:20,591 Validation result (greedy) at epoch   2, step     6000: bleu:   6.26, loss: 274684.9688, ppl:  20.5460, duration: 475.7725s
  	2020-05-08 22:41:55,349 Epoch   2 Step:     6100 Batch Loss:     2.668803 Tokens per Sec:      367, Lr: 0.000300
  	2020-05-08 22:47:27,163 Epoch   2 Step:     6200 Batch Loss:     2.562169 Tokens per Sec:      364, Lr: 0.000300
  	2020-05-08 22:52:56,363 Epoch   2 Step:     6300 Batch Loss:     2.586158 Tokens per Sec:      358, Lr: 0.000300
  	2020-05-08 22:58:25,400 Epoch   2 Step:     6400 Batch Loss:     2.617651 Tokens per Sec:      364, Lr: 0.000300
  	2020-05-08 23:03:27,894 Epoch   2: total training loss 9073.91
  	2020-05-08 23:03:27,896 Training ended after   2 epochs.
  	2020-05-08 23:03:27,896 Best validation result (greedy) at step     6000:  20.55 ppl.
	2020-05-08 23:13:15,644  dev bleu:   7.94 [Beam search decoding with beam size = 5 and alpha = 1.0]
	2020-05-08 23:13:15,646 Translations saved to: models/rnn_wmt16_factors_add_deen/00006000.hyps.dev



  	###############################################################################
  	model_name rnn_wmt16_factors_add_256_deen
  	2020-05-10 17:01:08,053 Hello! This is Joey-NMT.
  	Detokenizer Version $Revision: 4134 $
  	Language: en
  	BLEU+case.mixed+numrefs.1+smooth.exp+tok.13a+version.1.4.9 = 8.6 42.6/14.5/5.8/2.4 (BP = 0.892 ratio = 0.897 hyp_len = 57529 ref_len = 64132)
  	time taken:
  	875 seconds

