# Exercise 5 Report

# Part 1 Experiments with Byte Pair Encoding
# Steps

Clone this repository in the desired place and check out the correct branch:

    git clone https://github.com/sugarsword/joeynmt-toy-models
    cd joeynmt-toy-models
    checkout ex5

Create a new virtualenv that uses Python 3. Please make sure to run this command outside of any virtual Python environment:

    ./scripts/make_virtualenv.sh

**Important**: Then activate the env by executing the `source` command that is output by the shell script above.

Download and install required software:

    ./scripts/download_install_packages.sh

Download and split data:

    ./scripts/download_data.sh

Preprocess data:

Select the language pair: en-de

Subsample train data, tokenize train, dev, test data
	
Prepare for bpe training:
	
For each vocabulary size (1k, 2k, 3k)
	
Learn a BPE vocabulary, create a joined vocabulary, apply bpe to train, dev and test data

    ./scripts/preprocess.sh

Train a word-level model, where the config file is word_level_ende.yaml

    ./scripts/train.sh
	

Evaluate the word-level model

    ./scripts/evaluate_word_level.sh
	
Train bpe models with different configs: 1000.bpe.ende.yaml, 2000.bpe.ende.yaml, 3000.bpe.ende.yaml, modify train.sh manually each time before training.

	./scripts/train.sh

Evaluate the results of the bpe models:

    ./scripts/evaluate.sh
	
Comparison Table for the Models

| Model name | Level | Vocabulary size |  BLEU |
|---|---|---|---|
|word_level_ende|word|2000|5.3|
|bpe_3000_ende|bpe|1000|4.4|
|bpe_2000_ende|bpe|2000|6.2|
|bpe_3000_ende|bpe|3000|8.8|

Manual inspection of the translation output:

Word-level: a collection of most frequent words and lots of "unk"s. One of the sentences was: 

	Und wir haben <unk> <unk> <unk> als <unk>.
	<unk> <unk>. Ich liebe es.

That was almost "unk"-poetry in a sense.

For all the bpe models: many short sentences are like real sentences with semantic inconsistencies. Most sentences end with repetitions of words. One example of a short sentence in the source language:

	They manage the process, they understand the process.

The bpe_1000_ende translation:

	Sie sind das Problem, sie sind die Frauen.

The bpe_2000_ende translation:
	
	Sie verändert die Probleme, sie können die Probleme.

The bpe_3000_ende translation:

	Sie brauchen die Prozess, die Technologie verändern.

The sentence structures are fine, the correct words are not yet there.

An example of a long short sentence in the source language:

	So the average for most people is around 20 inches;  business schools students, about half of that;  lawyers, a little better, but not much better than that,  kindergarteners, better than most adults.

The 1k model translation:

	Die meisten Zeitpunkt, die Menschen in 10 Millionen Studenten, die Medikamente, in denen Medikamente, die ein paar Jahren, ist ein paar Jahren, aber nicht mehr, dass die Zukunft.

The 2k model translation:

	Also, die Fähigkeit für die Leute ist in 30 Prozent, ist eine Menge Probleme, von dem wir erreichen, ein wenig, eine kleinen, aber nicht mehr, aber nicht besser, aber nicht besser, aber nicht besser, aber nicht besserhalb, aber nicht besser als die Welt.
	
The 3k model translation: 

	Die meisten Menschen ist in der meisten Menschen, in 20 Zritter, verschiedene Bülern, mit der Tage, und Laulern, ein wenig besser, aber nicht viel besser, aber nicht viel besser als die Welt als die meisten Wahl.


I wondered why the translations did not keep the original numerical value, until I read the "official" translation which was:

	Der Durchschnitt für die meisten liegt bei ca. 50cm, BWL-Studenten schaffen die Hälfte davon, Anwälte etwas mehr, aber nicht viel, Kindergartenkinder sind besser als die Erwachsenen.

It gives the impression that training has not yet reached the sentence length and with more training time the models will improve and approximate a reasonable translation. Although the word-level model has a slightly higher BLEU score than the 1000_bpe model, the impression I have from manual check is that the bpe model is actually better than the word-level model.


# Part 2 Impact of beam size on translation quality

I took the best performing model from part 1, bpe_3000_ende, for this analysis. The following bash file evaluates 13 translations varying the beam sizes, recording their BLEU scores and evaluation time and plots a graph depicted below. 

    ./scripts/beam_comparison.sh


![beam_chart](https://github.com/sugarsword/joeynmt-toy-models/blob/ex5/beam.png)

In the range from 1 to 20 the BLEU scores improve but flatten out after 10. The BLEU scores hardly improve any more after beam size 20. The evaluation time seems to increase linearly along with beam sizes.

It is worthwhile to increase beam size to 10 to improve the BLEU scores. But when beam sizes are greater than 10 the benefits become marginal particularly taking translation time into account.
