# theano device, in case you do not want to compute on gpu, change it to cpu
device=gpu0

THEANO_FLAGS=mode=FAST_RUN,floatX=float32,device=$device,on_unused_input=warn python -u config.py
