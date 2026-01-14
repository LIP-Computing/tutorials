#!/bin/bash
#SBATCH --job-name=run_gromacs_gpu
#SBATCH --ntasks=8
#SBATCH --partition=gpu
#SBATCH --output=gromacs-gpu-%j.out
#SBATCH --error=gromacs-gpu-%j.err

export TUT_DIR=$HOME/udocker-tutorial
export PATH=$HOME/udocker-1.3.17/udocker:$PATH
export UDOCKER_DIR=$TUT_DIR/.udocker
export GROM_INPUT=$TUT_DIR/udocker-files/gromacs-gpu

export OUT_NAME=$GROM_INPUT/output/ud-gpu-tutorial
export TRR=${OUT_NAME}.trr
export XTC=${OUT_NAME}.xtc
export EDR=${OUT_NAME}.edr
export LOG=${OUT_NAME}.log
mkdir -p $OUT_NAME
module load python
cd $TUT_DIR

echo "###############################"
udocker run -v=$GROM_INPUT:/home/user -w=/home/user grom_gpu /home/user/run-grom-gpu.sh
