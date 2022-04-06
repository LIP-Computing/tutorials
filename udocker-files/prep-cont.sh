#!/bin/bash

#SBATCH --job-name=prep_container
#SBATCH --time=0:10:0
#SBATCH --ntasks=1
#SBATCH -N 1
#SBATCH --mem=200MB
#SBATCH --partition=XXXX-GPU

export TUT_DIR=$SCRATCH/udocker-tutorial

cd $TUT_DIR
source udockervenv/bin/activate
export UDOCKER_DIR=$TUT_DIR/.udocker

echo "###############################"
hostname
uname -a
which nvidia-smi
nvidia-smi
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
udocker setup --nvidia --force tf_gpu
echo
