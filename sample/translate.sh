#!/bin/sh

# Define the environment variables containing the paths to Moses, Nematus, etc.
# These paths must be stored in a .env file.
export $(cat .env | xargs)

# theano device, in case you do not want to compute on gpu, change it to cpu
device=gpu

# path to nematus ( https://www.github.com/rsennrich/nematus )
nematus=${NEMATUS_PATH}

THEANO_FLAGS=mode=FAST_RUN,floatX=float32,device=$device,on_unused_input=warn python $nematus/nematus/translate.py \
     -m ${MODEL_PATH}/model.npz \
     -i ${DATA_PATH}/newsdev2016.bpe.ro \
     -o ${DATA_PATH}/newsdev2016.output \
     -k 12 -n -p 1
