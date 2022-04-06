#!/bin/bash

#SBATCH --job-name=prep_container
#SBATCH --time=0:20:0
#SBATCH --ntasks=1
#SBATCH -N 1
#SBATCH --mem=200MB
#SBATCH --partition=XXXX-GPU

export TUT_DIR=$SCRATCH/udocker-tutorial

cd $TUT_DIR
source udockervenv/bin/activate
export UDOCKER_DIR=$TUT_DIR/.udocker

echo "###############################"
udocker run -v $TUT_DIR/tensorflow:/root tf_gpu python3 keras_example_small.py
echo
