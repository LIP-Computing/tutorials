#!/bin/bash

#SBATCH --job-name=prep_container
#SBATCH --gres=gpu
#SBATCH --partition=XXX
#SBATCH --qos=YYY

export TUT_DIR=$HOME/udocker-tutorial

cd $TUT_DIR
source udockervenv/bin/activate
export UDOCKER_DIR=$TUT_DIR/.udocker

echo "###############################"
echo ">> udocker command"
which udocker
echo
echo ">> List images"
udocker images
echo
echo ">> Create container"
udocker create --name=tf_gpu tensorflow/tensorflow:2.8.0-gpu
echo
echo ">> Set nvidia mode"
udocker setup --nvidia tf_gpu
echo
echo ">> check nvidia inside container"
udocker run tf_gpu nvidia_smi
