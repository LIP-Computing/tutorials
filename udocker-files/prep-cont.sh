#!/bin/bash
#SBATCH --job-name=prep_container
#SBATCH --ntasks=1
#SBATCH -N 1
#SBATCH --partition=gpu
#SBATCH --gres=gpu

export TUT_DIR=$HOME/udocker-tutorial
export PATH=$HOME/udocker-1.3.10/udocker:$PATH
cd $TUT_DIR
export UDOCKER_DIR=$TUT_DIR/.udocker
module load python/3.10.8

echo "###############################"
hostname
echo ">> udocker command"
which udocker
echo
echo ">> List images"
udocker images
echo
echo ">> Create container"
udocker create --name=tf_gpu tensorflow/tensorflow:latest-gpu
echo
echo ">> Set nvidia mode"
udocker setup --execmode=F3 --force tf_gpu
udocker setup --nvidia --force tf_gpu
echo
echo ">> List containers"
udocker ps -m -p
