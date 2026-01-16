#!/bin/bash
#SBATCH --job-name=run_gromacs_gpu
#SBATCH --ntasks=12
#SBATCH --partition=gpu
#SBATCH --gres=gpu
#SBATCH --output=gromacs-gpu-%j.out
#SBATCH --error=gromacs-gpu-%j.err

export TUT_DIR=$HOME/udocker-tutorial
export PATH=$HOME/udocker-1.3.17/udocker:$PATH
export UDOCKER_DIR=$TUT_DIR/.udocker
export GROM=$TUT_DIR/gromacs
export GROM_INPUT=$GROM/input
export OUT_NAME=/home/user/output/ud-gpu-tutorial
export TRR=${OUT_NAME}.trr
export XTC=${OUT_NAME}.xtc
export EDR=${OUT_NAME}.edr
export LOG=${OUT_NAME}.log
module load python
cd $TUT_DIR

echo "###############################"
echo "On the container: nvidia-smi"
udocker run -v=$GROM:/home/user -w=/home/user grom_gpu nvidia-smi

echo "###############################"
echo "Executing gromacs-gpu"
echo "###############################"
udocker run -v=$GROM:/home/user -w=/home/user grom_gpu gmx mdrun -s /home/user/input/md.tpr -e $EDR -x $XTC -o $TRR -g $LOG -nsteps 10000 -nt 12 -gpu_id 0
