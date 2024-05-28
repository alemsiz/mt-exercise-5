#! /bin/bash

scripts=$(dirname "$0")
base=$scripts/..

data=data
beam_configs=configs/bpe_level_model_4000_beam_size

translations=translations

mkdir -p $translations

src=it
trg=en


num_threads=4
device=0

beam_size_translations=$translations/beam_size_translations

mkdir -p $beam_size_translations

mkdir -p $beam_configs

# generate the set of config files with different beam sizes for the BPE 4000 model using the Python script
python scripts/generate_config_beam_size_variants.py

# for each beam size
for beam_size in 2 4 6 8 10 12 14 16 18 20
do

# start measuring time
SECONDS=0

# get the config filename for the current beam size
config_name=beam_size_$beam_size.yaml

echo "###############################################################################"
echo "beam size $beam_size"

# translate the test set using the current beam size
CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $beam_configs/$config_name < $data/test.it-en.$src > $beam_size_translations/test.beam_size_$beam_size.$trg

# compute case-sensitive BLEU 
cat $beam_size_translations/test.beam_size_$beam_size.$trg | sacrebleu $data/test.it-en.$trg

# print time taken
echo "time taken:"
echo "$SECONDS seconds"

done