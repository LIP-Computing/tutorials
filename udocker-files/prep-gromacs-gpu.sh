#!/bin/bash
#SBATCH --job-name=prep_gromacs
#SBATCH --ntasks=1
#SBATCH --partition=gpu
#SBATCH --gres=gpu
#SBATCH --output=gromacs-gpu-prep-%j.out
#SBATCH --error=gromacs-gpu-prep-%j.err

export TUT_DIR=$HOME/udocker-tutorial
export PATH=$HOME/udocker-1.3.17/udocker:$PATH
cd $TUT_DIR
export UDOCKER_DIR=$TUT_DIR/.udocker
module load python

echo "###############################"
hostname
echo ">> udocker command"
which udocker
echo
echo ">> List images"
udocker images
echo
echo ">> Create container"
udocker create --name=grom_gpu gromacs-gpu-2025.4
echo
echo ">> Set nvidia mode"
udocker setup --nvidia --force grom_gpu
echo ">> List containers"
udocker ps -m -p
