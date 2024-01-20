#!/bin/bash
#SBATCH --job-name=run_gromacs
#SBATCH --ntasks=8
#SBATCH --partition=hpc
#SBATCH --output=gromacs-%j.out
#SBATCH --error=gromacs-%j.err

export TUT_DIR=$HOME/udocker-tutorial
export PATH=$HOME/udocker-1.3.10/udocker:$PATH
export UDOCKER_DIR=$TUT_DIR/.udocker
module load python/3.10.13
cd $TUT_DIR

echo "###############################"
udocker run -v=$TUT_DIR/gromacs:/home/user -w=/home/user grom \
    gmx mdrun -s /home/user/input/md.tpr -deffnm ud-tutorial \
    -maxh 0.50 -resethway -noconfout -nsteps 10000 -g output/logile -nt 8 -pin on
