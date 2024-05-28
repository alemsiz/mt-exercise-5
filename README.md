# MT Exercise 5: Byte Pair Encoding, Beam Search
This repository is a starting point for the 5th and final exercise. As before, fork this repo to your own account and the clone it into your prefered directory.

## Requirements

- This only works on a Unix-like system, with bash available.
- Python 3 must be installed on your system, i.e. the command `python3` must be available
- Make sure virtualenv is installed on your system. To install, e.g.

    `pip install virtualenv`

## Steps

Clone your fork of this repository in the desired place:

    git clone https://github.com/[your-name]/mt-exercise-5

Create a new virtualenv that uses Python 3.10. Please make sure to run this command outside of any virtual Python environment:

    ./scripts/make_virtualenv.sh

**Important**: Then activate the env by executing the `source` command that is output by the shell script above.

Download and install required software as described in the exercise pdf.

Download data:

    ./download_iwslt_2017_data.sh
    
Before executing any further steps, you need to make the modifications described in the exercise pdf.

Train a model:

    ./scripts/train.sh

The training process can be interrupted at any time, and the best checkpoint will always be saved.

Evaluate a trained model with

    ./scripts/evaluate.sh

## Part 1 modifications

### Preprocessing data

In order to sub-sample my parallel training data to 100k sentence pairs, I created the script `subsample_data.sh`. This script takes the data file to be subsampled as a command line argument, and outputs a new file containing the first 100k lines of the provided file. In order to subsample both the EN and IT training files for the IT-EN translation direction, I ran:

    ./scripts/subsample_data.sh data/train.it-en.it
    ./scripts/subsample_data.sh data/train.it-en.en

This generated the two subsampled training files which I use from now on: `head100k.train.it-en.it` and `head100k.train.it-en.en`.

### BPE learning and joint vocabulary creation

For this step, I followed the best practices for Subword NMT [https://github.com/rsennrich/subword-nmt#best-practice-advice-for-byte-pair-encoding-in-nmt]. To this end, I created a single shell script to both learn the BPE model for the training texts and generate a shared vocabulary for both the source and target language: `learn_bpe_and_get_joint_vocab.sh`.

This script contains a variable `vocab_size` which determines the desired size of the shared vocabulary. It should be set within the script itself for each variation. The output BPE codes file (from the learned model) as well as the shared vocabulary are saved in the directory `bpe_data/{vocab_size}`, e.g. if `vocab_size` is set to 2000 in the script, the output files are stored in `bpe_data/2000`.

Within this directory of output files for the specified vocabulary size, the BPE codes for the learned model can be found in the file `codes.BPE`, while the cleaned (= symbol counts removed) version of the shared vocabulary is found in `bpe_vocab.it-en.joint.cleaned` - this is the vocabulary file we will use to configure the BPE-level JoeyNMT model. The language-specific vocabularies are also output by the script so they could be used for a different model configuration, but they are not used further in my experiments.

### JoeyNMT model configurations

The following are the configuration files for the three models I trained:

Word-level model: `configs/word_level_model.yaml`
BPE-level model with vocab size 2000: `configs/bpe_level_model_2000.yaml`
BPE-level model with vocab size 4000: `configs/bpe_level_model_4000.yaml`

For all three models, the training, testing and dev filenames under `data` in the configuration files were replaced with the IT-EN datasets from the multilingual task of the IWSLT 2017 evaluation campaign (excluding the final `it` or `en` in the filenames, since these are added automatically by JoeyNMT). The source (IT) and target (EN) languages were also updated accordingly, and `level` was set to `word` for the word-level model and `bpe` for the BPE-level models in both the `src` and `trg` fields. Further, for all three models the `model_dir` field under `training` was set to the appropriate filepath.

For the word-level model, no vocabulary files were built before training, so the field `voc limit` was set to 2000 under both `src` and `trg`, defining a vocabulary threshold of 2000 for both languages. Since you can only share input and output embeddings (`tied embeddings`=True) if you use the exact same vocabulary for each language, `tied_embeddings` under `model` is set to False here. Further, since the model is word-level, no subword tokenizer was set in `tokenizer_type`; instead only Moses pretokenization is applied, as specified under `tokenizer_cfg`.

For the BPE-level models, no `voc_limit` was provided, since in the previous subsection [here](#bpe-learning-and-joint-vocabulary-creation) we already generated a shared vocabulary. The filepath of this shared vocabulary is added in the `voc_file` field under `data/src` and `data/trg`. Further, for these models a `tokenizer_type` is specified: `subword-nmt`, and in `tokenizer_cfg`, the BPE codes file generated in the previous subsection is added in the field `codes`, so that BPE can be applied to the raw training, testing and dev datasets (this is done automatically by JoeyNMT). 

## Part 1 results

### Evaluation method

In order to evaluate the three models I trained, I ran `scripts/evaluate.sh` three times, replacing the `model_name` variable each time. The test translations for each model were saved in the respective subfolder in the `translations` folder and the BLEU score information was printed in the terminal.

### Results

| Model name | Uses BPE | Vocab size | BLEU |
|----------|----------|----------|----------|
| word_level_model    | no     | 2000     | 14.8     |
| bpe_level_model_2000    | yes     | 2000     | 21.2     |
| bpe_level_model_4000    | yes     | 4000     | 22.2     |

### Discussion

## Part 2 modifications

In order to investigate the effect of beam size on the BLEU score and generation time, I used my highest-scoring model (`bpe_level_model_4000`) and evaluated it 10 times, beginning with a beam size of 2 and incrementing it by 2 each time, ending up at 20. 

In order to vary the beam size, I had to generate 10 different versions of the `bpe_word_level_4000.yaml` configuration file, each with a different value for `testing/beam_size`. To automate this process, I created a Python script (`scripts/generate_config_beam_size_variants.py`) which creates the 10 different configuration files and saves them in the folder `configs/bpe_level_model_4000_beam_size`.

To run the 10 evaluations for the different beam sizes, I created the script `scripts/beam_size_evaluate.sh` which first runs the Python script to generate the 10 configuration files. Once these have been generated, the script loops through the 10 beam sizes, assembles the corresponding configuration filename for each one and then translates the test set using this configuration file (i.e. using the specified beam size). Then, the case-sensitive BLEU score is produced.

To run this script:

    ./scripts/beam_size_evaluate.sh

Once the script has finished running and looped through all the beam sizes, the 10 output translations can be found in `translations/beam_size_translations` and the generation times and BLEU scores are printed to the terminal.

In order to visualise the results, I manually created a CSV file from the terminal outputs which contains the BLEU score and time taken for generation for each beam size. This can be found in `translations/beam_size_translations/beam_size_results.csv`.

Then, I created a Python script to produce the actual visualisations (`scripts/visualise_results.py`). Please run the following command before running this file:

    pip install argparse

The script takes two command line arguments: (1) The filename of the CSV file containing the BLEU and time results, (2) The directory the plots should be saved in.

The command I used to generate and save the plots in the `translations` directory was:

    python scripts/visualise_results.py translations/beam_size_translations/beam_size_results.csv translations

## Part 2 results

![image](https://github.com/alemsiz/mt-exercise-5/assets/152906037/8abefe5c-da45-4dd2-8db5-2e54ab7f7577)

![image](https://github.com/alemsiz/mt-exercise-5/assets/152906037/264a7d0e-ca2c-4510-95fe-85edf381658b)


