This directory contains some sample files and configuration scripts for training a simple neural MT model


INSTRUCTIONS
------------

all scripts contain variables that you will need to set to run the scripts.
For processing the sample data, only paths to different toolkits need to be set.

This can be done by creating a ```.env``` file locally containing the following paths:

```
MOSES_DECODER_PATH="/path/to/mosesdecoder"
SUBWORD_NMT_PATH="/path/to/subword-nmt"
NEMATUS_PATH="/path/to/nematus"
DATA_PATH="/path/to/data"
MODEL_PATH="/path/to/model"
```

For processing new data, more changes will be necessary.

As a first step, preprocess the training data:

  ./preprocess.sh

Then, start training: on normal-size data sets, this will take about 1-2 weeks to converge.
Models are saved regularly, and you may want to interrupt this process without waiting for it to finish.

  ./train.sh

Given a model, preprocessed text can be translated thusly:

  ./translate.sh

Finally, you may want to post-process the translation output, namely merge BPE segments,
detruecase and detokenize:

  ./postprocess-test.sh < data/newsdev2016.output > data/newsdev2016.postprocessed