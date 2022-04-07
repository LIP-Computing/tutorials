#!/bin/bash

#SBATCH --job-name=run_keras
#SBATCH --time=0:30:0
#SBATCH --ntasks=1
#SBATCH -N 1
#SBATCH --mem=4GB
#SBATCH --partition=XXX_GPU

export TUT_DIR=$SCRATCH/udocker-tutorial

cd $TUT_DIR
source udockervenv/bin/activate
export UDOCKER_DIR=$TUT_DIR/.udocker

echo "###############################"
udocker run -v $TUT_DIR/tensorflow:/home/user -w /home/user tf_gpu python3 keras_example_small.py
