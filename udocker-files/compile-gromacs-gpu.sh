#!/bin/bash
#SBATCH --job-name=run_gromacs
#SBATCH --ntasks=64
#SBATCH --partition=gpu
#SBATCH --output=gromacs-%j.out
#SBATCH --error=gromacs-%j.err

export TUT_DIR=$HOME/udocker-tutorial
export PATH=$HOME/udocker-1.3.17/udocker:$PATH
export UDOCKER_DIR=$TUT_DIR/.udocker
export OUT_NAME=output/ud-tutorial
module load python
cd $TUT_DIR

echo "###############################"
udocker run -v=$TUT_DIR/gromacs:/home/user -w=/home/user grom_gpu /home/user/compile.sh
