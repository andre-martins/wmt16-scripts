#!/bin/bash

# Define the environment variables containing the paths to Moses, Nematus, etc.
# These paths must be stored in a .env file.
export $(cat .env | xargs)

# get En-Ro training data for WMT16

if [ ! -f data/ro-en.tgz ];
then
  wget http://www.statmt.org/europarl/v7/ro-en.tgz -O data/ro-en.tgz
fi

if [ ! -f data/SETIMES2.ro-en.txt.zip ];
then
  wget http://opus.lingfil.uu.se/download.php?f=SETIMES2/en-ro.txt.zip -O data/SETIMES2.ro-en.txt.zip
fi

# Now download the WMT16 test files.

if [ ! -f data/test.tgz ];
then
  wget http://data.statmt.org/wmt16/translation-task/test.tgz -O data/test_wmt16.tgz
fi

cd data/
tar -xf ro-en.tgz
unzip SETIMES2.ro-en.txt.zip

cat europarl-v7.ro-en.en SETIMES2.en-ro.en > corpus.en
cat europarl-v7.ro-en.ro SETIMES2.en-ro.ro > corpus.ro

# Convert the test files from sgm to plain text.

tar -zxvf test_wmt16.tgz
mosesdecoder=${MOSES_DECODER_PATH}
$mosesdecoder/scripts/ems/support/input-from-sgm.perl \
    < test/newstest2016-roen-src.ro.sgm \
    > newstest2016.ro
$mosesdecoder/scripts/ems/support/input-from-sgm.perl \
    < test/newstest2016-roen-ref.en.sgm \
    > newstest2016.en

cd ..
