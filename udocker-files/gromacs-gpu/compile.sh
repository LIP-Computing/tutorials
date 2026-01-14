#!/bin/bash
PATH=$PATH:/usr/local/gromacs/bin
LD_LIBRARY_PATH=/usr/local/gromacs/lib
gromacs_ver=2025.4

apt update
apt-get install -y --no-install-recommends cmake wget

cd /tmp
wget --no-check-certificate https://ftp.gromacs.org/gromacs/gromacs-${gromacs_ver}.tar.gz
tar zxvf gromacs-${gromacs_ver}.tar.gz
cd gromacs-${gromacs_ver}
mkdir -p /tmp/gromacs-${gromacs_ver}/build
cd /tmp/gromacs-${gromacs_ver}/build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DGMX_OPENMP=ON -DGMX_GPU=CUDA -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda
make
make install
rm -rf /tmp/gromacs-${gromacs_ver}*
