#!/bin/bash

. /usr/local/gromacs/bin/GMXRC.bash

gmx mdrun -s /home/user/input/md.tpr -e $EDR -x $XTC -o $TRR -g $LOG \
    -maxh 0.50 -resethway -noconfout -nsteps 10000 -nt 8 -pin on
