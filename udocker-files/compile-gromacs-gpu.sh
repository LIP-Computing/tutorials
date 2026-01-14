#!/bin/bash
#SBATCH --job-name=compile_gromacs
#SBATCH --ntasks=64
#SBATCH --partition=gpu
#SBATCH --output=gromacs-compile-%j.out
#SBATCH --error=gromacs-compile-%j.err

export TUT_DIR=$HOME/udocker-tutorial
export GROM_INPUT=$TUT_DIR/udocker-files/gromacs-gpu
export PATH=$HOME/udocker-1.3.17/udocker:$PATH
export UDOCKER_DIR=$TUT_DIR/.udocker
module load python
cd $TUT_DIR

echo "###############################"
udocker run -v=$GROM_INPUT:/home/user -w=/home/user grom_gpu /home/user/compile.sh
