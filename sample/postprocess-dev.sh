#/bin/sh

# Define the environment variables containing the paths to Moses, Nematus, etc.
# These paths must be stored in a .env file.
export $(cat .env | xargs)

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=${MOSES_DECODER_PATH}

# suffix of target language files
lng=en

sed 's/\@\@ //g' | \
$mosesdecoder/scripts/recaser/detruecase.perl
