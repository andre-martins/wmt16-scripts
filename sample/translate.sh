#!/bin/sh

# Define the environment variables containing the paths to Moses, Nematus, etc.
# These paths must be stored in a .env file.
export $(cat .env | xargs)

# theano device
device=gpu

# path to nematus ( https://www.github.com/rsennrich/nematus )
nematus=${NEMATUS_PATH}

THEANO_FLAGS=mode=FAST_RUN,floatX=float32,device=$device,on_unused_input=warn python $nematus/nematus/translate.py \
     -m model/model.npz \
     -i data/newsdev2016.bpe.ro \
     -o data/newsdev2016.output \
     -k 12 -n -p 1
