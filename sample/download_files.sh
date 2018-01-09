#!/bin/bash

# Define the environment variables containing the paths to Moses, Nematus, etc.
# These paths must be stored in a .env file.
export $(cat .env | xargs)

SOURCE=fi
TARGET=en
LANGPAIR=${SOURCE}-${TARGET}

# Download all the WMT16 test files.
if [ ! -f ${DATA_PATH}/test_wmt16.tgz ];
then
  wget http://data.statmt.org/wmt16/translation-task/test.tgz -O ${DATA_PATH}/test_wmt16.tgz
fi

# Download all the WMT16 dev files.
if [ ! -f ${DATA_PATH}/dev_wmt16.tgz ];
then
  wget http://data.statmt.org/wmt16/translation-task/dev.tgz -O ${DATA_PATH}/dev_wmt16.tgz
fi

if [ "$LANGPAIR" == "ro-en" ]
then
    # get En-Ro training data for WMT16

    if [ ! -f ${DATA_PATH}/ro-en.tgz ];
    then
        wget http://www.statmt.org/europarl/v7/ro-en.tgz -O ${DATA_PATH}/ro-en.tgz
    fi

    if [ ! -f data/SETIMES2.ro-en.txt.zip ];
    then
        wget http://opus.lingfil.uu.se/download.php?f=SETIMES2/en-ro.txt.zip -O ${DATA_PATH}/SETIMES2.ro-en.txt.zip
    fi

    cd ${DATA_PATH}
    tar -xf ro-en.tgz
    unzip SETIMES2.ro-en.txt.zip

    cat europarl-v7.ro-en.en SETIMES2.en-ro.en > corpus.en
    cat europarl-v7.ro-en.ro SETIMES2.en-ro.ro > corpus.ro

elif [ "$LANGPAIR" == "de-en" ]
then
    # get En-De training data for WMT16

    if [ ! -f ${DATA_PATH}/${SOURCE}-${TARGET}.tgz ];
    then
        wget http://www.statmt.org/europarl/v7/${SOURCE}-${TARGET}.tgz -O ${DATA_PATH}/${SOURCE}-${TARGET}.tgz
    fi

    if [ ! -f ${DATA_PATH}/training-parallel-nc-v11.tgz ];
    then
        wget http://data.statmt.org/wmt16/translation-task/training-parallel-nc-v11.tgz -O ${DATA_PATH}/training-parallel-nc-v11.tgz
    fi

    if [ ! -f ${DATA_PATH}/training-parallel-commoncrawl.tgz ];
    then
        wget http://www.statmt.org/wmt13/training-parallel-commoncrawl.tgz -O ${DATA_PATH}/training-parallel-commoncrawl.tgz
    fi

    cd ${DATA_PATH}
    tar -xf de-en.tgz
    tar -zxvf training-parallel-nc-v11.tgz
    tar -zxvf training-parallel-commoncrawl.tgz

    cat europarl-v7.${SOURCE}-${TARGET}.${TARGET} \
        training-parallel-nc-v11/news-commentary-v11.${SOURCE}-${TARGET}.${TARGET} \
        commoncrawl.${SOURCE}-${TARGET}.${TARGET} \
        > corpus.${TARGET}
    cat europarl-v7.${SOURCE}-${TARGET}.${SOURCE} \
        training-parallel-nc-v11/news-commentary-v11.${SOURCE}-${TARGET}.${SOURCE} \
        commoncrawl.${SOURCE}-${TARGET}.${SOURCE} \
        > corpus.${SOURCE}

    # Convert the dev files from sgm to plain text.
    tar -zxvf dev_wmt16.tgz
    mosesdecoder=${MOSES_DECODER_PATH}
    $mosesdecoder/scripts/ems/support/input-from-sgm.perl \
        < dev/newstest2015-${SOURCE}${TARGET}-src.${SOURCE}.sgm \
        > newsdev2016.${SOURCE}
    $mosesdecoder/scripts/ems/support/input-from-sgm.perl \
        < dev/newstest2015-${SOURCE}${TARGET}-ref.${TARGET}.sgm \
        > newsdev2016.${TARGET}

elif [ "$LANGPAIR" == "fi-en" ]
then
    # get En-De training data for WMT16

    if [ ! -f ${DATA_PATH}/training-parallel-ep-v8.tgz ];
    then
        wget http://data.statmt.org/wmt16/translation-task/training-parallel-ep-v8.tgz -O ${DATA_PATH}/training-parallel-ep-v8.tgz
    fi

    #if [ ! -f ${DATA_PATH}/wiki-titles.tgz ];
    #then
    #    wget http://www.statmt.org/wmt15/wiki-titles.tgz -O ${DATA_PATH}/wiki-titles.tgz
    #fi

    cd ${DATA_PATH}
    tar -xf training-parallel-ep-v8.tgz
    #tar -zxvf wiki-titles.tgz

    cat training-parallel-ep-v8/europarl-v8.${SOURCE}-${TARGET}.${TARGET} \
        > corpus.${TARGET}
    cat training-parallel-ep-v8/europarl-v8.${SOURCE}-${TARGET}.${SOURCE} \
        > corpus.${SOURCE}

    # Convert the dev files from sgm to plain text.
    tar -zxvf dev_wmt16.tgz
    mosesdecoder=${MOSES_DECODER_PATH}
    $mosesdecoder/scripts/ems/support/input-from-sgm.perl \
        < dev/newsdev2015-${SOURCE}${TARGET}-src.${SOURCE}.sgm \
        > newsdev2016.${SOURCE}
    $mosesdecoder/scripts/ems/support/input-from-sgm.perl \
        < dev/newstest2015-${SOURCE}${TARGET}-src.${SOURCE}.sgm \
        >> newsdev2016.${SOURCE}
    $mosesdecoder/scripts/ems/support/input-from-sgm.perl \
        < dev/newsdev2015-${SOURCE}${TARGET}-ref.${TARGET}.sgm \
        > newsdev2016.${TARGET}
    $mosesdecoder/scripts/ems/support/input-from-sgm.perl \
        < dev/newstest2015-${SOURCE}${TARGET}-ref.${TARGET}.sgm \
        >> newsdev2016.${TARGET}

fi


# Convert the test files from sgm to plain text.

tar -zxvf test_wmt16.tgz
mosesdecoder=${MOSES_DECODER_PATH}
$mosesdecoder/scripts/ems/support/input-from-sgm.perl \
    < test/newstest2016-${SOURCE}${TARGET}-src.${SOURCE}.sgm \
    > newstest2016.${SOURCE}
$mosesdecoder/scripts/ems/support/input-from-sgm.perl \
    < test/newstest2016-${SOURCE}${TARGET}-ref.${TARGET}.sgm \
    > newstest2016.${TARGET}

cd ..
