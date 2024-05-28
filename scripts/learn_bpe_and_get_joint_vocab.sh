#! /bin/bash

# Define source and target languages
src=it
trg=en

# Our desired BPE vocabulary size
vocab_size=4000

fol=bpe_data/$vocab_size

mkdir -p $fol

# Learn BPE codes and apply them to training corpora, and from the BPE-encoded corpora generate vocabulary files for each language (all in one command)
subword-nmt learn-joint-bpe-and-vocab --input data/head100k.train.it-en.$src data/head100k.train.it-en.$trg -s $vocab_size -o $fol/codes.BPE --write-vocabulary $fol/bpe_vocab.$src $fol/bpe_vocab.$trg --total-symbols

# Reapply BPE using a vocabulary threshold this time (any word with frequency < 50 in the provided vocabulary will be treated as OOV)
subword-nmt apply-bpe -c $fol/codes.BPE --vocabulary $fol/bpe_vocab.$src --vocabulary-threshold 50 < data/head100k.train.it-en.$src > $fol/head100k.train.it-en.BPE.$src
subword-nmt apply-bpe -c $fol/codes.BPE --vocabulary $fol/bpe_vocab.$trg --vocabulary-threshold 50 < data/head100k.train.it-en.$trg > $fol/head100k.train.it-en.BPE.$trg

# Concatenate both BPE-encoded (with vocab threshold) training files 
cat $fol/head100k.train.it-en.BPE.$src $fol/head100k.train.it-en.BPE.$trg > $fol/head100k.train.it-en.BPE.joint

rm -f $fol/head100k.train.it-en.BPE.$src
rm -f $fol/head100k.train.it-en.BPE.$trg

# Create a new shared vocabulary for both languages on the concatenated file
subword-nmt get-vocab --input $fol/head100k.train.it-en.BPE.joint --output $fol/bpe_vocab.it-en.joint

rm -f $fol/head100k.train.it-en.BPE.joint

# Create a 'cleaned' version of this vocabulary file, without the counts - this is what we give to the model
cut -d " " -f 1 $fol/bpe_vocab.it-en.joint > $fol/bpe_vocab.it-en.joint.cleaned
