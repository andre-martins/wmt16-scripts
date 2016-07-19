#!/bin/sh

# this sample script preprocesses a sample corpus, including tokenization,
# truecasing, and subword segmentation. 
# for application to a different language pair,
# change source and target prefix, optionally the number of BPE operations,
# and the file names (currently, ${DATA_PATH}/corpus and ${DATA_PATH}/newsdev2016 are being processed)

# in the tokenization step, you will want to remove Romanian-specific normalization / diacritic removal,
# and you may want to add your own.
# also, you may want to learn BPE segmentations separately for each language,
# especially if they differ in their alphabet

# Define the environment variables containing the paths to Moses, Nematus, etc.
# These paths must be stored in a .env file.
export $(cat .env | xargs)

# suffix of source language files
SRC=ro

# suffix of target language files
TRG=en

# number of merge operations. Network vocabulary should be slightly larger (to include characters),
# or smaller if the operations are learned on the joint vocabulary
bpe_operations=89500

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=${MOSES_DECODER_PATH}

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
subword_nmt=${SUBWORD_NMT_PATH}

# path to nematus ( https://www.github.com/rsennrich/nematus )
nematus=${NEMATUS_PATH}

# tokenize
for prefix in corpus newsdev2016
 do
   cat ${DATA_PATH}/$prefix.$SRC | \
   $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $SRC | \
   ../preprocess/normalise-romanian.py | \
   ../preprocess/remove-diacritics.py | \
   $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC > ${DATA_PATH}/$prefix.tok.$SRC

   cat ${DATA_PATH}/$prefix.$TRG | \
   $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $TRG | \
   $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > ${DATA_PATH}/$prefix.tok.$TRG

 done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$mosesdecoder/scripts/training/clean-corpus-n.perl ${DATA_PATH}/corpus.tok $SRC $TRG ${DATA_PATH}/corpus.tok.clean 1 80

# train truecaser
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus ${DATA_PATH}/corpus.tok.clean.$SRC -model ${MODEL_PATH}/truecase-model.$SRC
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus ${DATA_PATH}/corpus.tok.clean.$TRG -model ${MODEL_PATH}/truecase-model.$TRG

# apply truecaser (cleaned training corpus)
for prefix in corpus
 do
  $mosesdecoder/scripts/recaser/truecase.perl -model ${MODEL_PATH}/truecase-model.$SRC < ${DATA_PATH}/$prefix.tok.clean.$SRC > ${DATA_PATH}/$prefix.tc.$SRC
  $mosesdecoder/scripts/recaser/truecase.perl -model ${MODEL_PATH}/truecase-model.$TRG < ${DATA_PATH}/$prefix.tok.clean.$TRG > ${DATA_PATH}/$prefix.tc.$TRG
 done

# apply truecaser (dev/test files)
for prefix in newsdev2016
 do
  $mosesdecoder/scripts/recaser/truecase.perl -model ${MODEL_PATH}/truecase-model.$SRC < ${DATA_PATH}/$prefix.tok.$SRC > ${DATA_PATH}/$prefix.tc.$SRC
  $mosesdecoder/scripts/recaser/truecase.perl -model ${MODEL_PATH}/truecase-model.$TRG < ${DATA_PATH}/$prefix.tok.$TRG > ${DATA_PATH}/$prefix.tc.$TRG
 done

# train BPE
cat ${DATA_PATH}/corpus.tc.$SRC ${DATA_PATH}/corpus.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > ${MODEL_PATH}/$SRC$TRG.bpe

# apply BPE

for prefix in corpus newsdev2016
 do
  $subword_nmt/apply_bpe.py -c ${MODEL_PATH}/$SRC$TRG.bpe < ${DATA_PATH}/$prefix.tc.$SRC > ${DATA_PATH}/$prefix.bpe.$SRC
  $subword_nmt/apply_bpe.py -c ${MODEL_PATH}/$SRC$TRG.bpe < ${DATA_PATH}/$prefix.tc.$TRG > ${DATA_PATH}/$prefix.bpe.$TRG
 done

# build network dictionary
$nematus/data/build_dictionary.py ${DATA_PATH}/corpus.bpe.$SRC ${DATA_PATH}/corpus.bpe.$TRG
