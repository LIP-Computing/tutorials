---
marp: true
theme: gaia
paginate: true
author: Mario David
size: 16:9
---

<style>
    section{
        background: #29303B;
        color: white;
    }
    a:link {
        color: #CCE5FF;
        background-color: transparent;
        text-decoration: underline;
    }
    a:visited {
        color: #CCE5FF;
        background-color: transparent;
        text-decoration: underline;
    }
    ul {
        font-size: 28px;
    }
    p {
        font-size: 28px;
    }
    table {
        font-size: 22px;
    }

</style>

<!-- _class: lead -->

![width:1000px](imgs/udocker-project-logos.png)

# `udocker` - *be anywhere*

## Part 3 - Hands On: intermediate stuff

<https://github.com/indigo-dc/udocker>

Mario David <david@lip.pt>, Jorge Gomes <jorge@lip.pt>

![width:150px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)

---

## Recap from last slide deck: udocker Installation

* The end user can download and execute `udocker` without system administrator intervention.
* Install from a released version:
  * Download a release tarball from <https://github.com/indigo-dc/udocker/releases>:

```bash
wget https://github.com/indigo-dc/udocker/releases/download/1.3.17/udocker-1.3.17.tar.gz
tar zxvf udocker-1.3.17.tar.gz
export PATH=`pwd`/udocker-1.3.17/udocker:$PATH
udocker install
```

---

<!-- _class: lead -->

# Importing and exporting, loading and saving: images and containers

---

## I have a dockerfile!

* *But `udocker` does not support `build` the dockerfile...*
  * Use `docker` itself in you <lap|desk>top
  * Example: <https://github.com/mariojmdavid/docker-gromacs-cuda/blob/master/gromacs/Dockerfile-gpu>

```bash
git clone https://github.com/mariojmdavid/docker-gromacs-cuda.git
cd docker-gromacs-cuda/gromacs/
docker build --build-arg gromacs_ver=2025.4 -t gromacs-openmp-2025.4 -f Dockerfile-cpu .

## Or you can build instead the GPU version
docker build --build-arg gromacs_ver=2025.4 -t gromacs-gpu-2005.4 -f Dockerfile-gpu .
```

* (Will take quite awhile, 30+ minutes on my desktop)

---

## I have a docker image!

After you build the image with docker:

```bash
docker images
REPOSITORY              TAG                        IMAGE ID       CREATED         SIZE
gromacs-gpu-2025.4      latest                     9aabe656c32e   5 hours ago     7.46GB
```

Save the image with `docker` to a tarball:

```bash
docker save -o gromacs-gpu.tar gromacs-gpu-2025.4
```

---

## `udocker` load

You can load a tarball with `udocker` that is a docker image, and that you saved previously with docker:

```bash
udocker load -i gromacs-gpu.tar gromacs-gpu-2025.4
```

And now you can check several things:

```bash
udocker images
REPOSITORY
gromacs-gpu-2025.4:latest                                               .

```

---

## Create a container and run it

```bash
udocker create --name=grom_gpu gromacs-gpu-2025.4

udocker ps
CONTAINER ID                         P M NAMES              IMAGE               
e2e014d9-9770-3fb5-a4a9-098a95371adf . W ['grom_gpu']       gromacs-gpu-2025.4:latest      

udocker run grom_gpu env
 ****************************************************************************** 
 *                                                                            * 
 *               STARTING e2e014d9-9770-3fb5-a4a9-098a95371adf                * 
 *                                                                            * 
 ****************************************************************************** 
 executing: env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/gromacs/bin
LD_LIBRARY_PATH=/usr/local/gromacs/lib
```

---

## Running gromacs with `udocker`

```bash
udocker run grom_gpu gmx mdrun -h
 
 ****************************************************************************** 
 *                                                                            * 
 *               STARTING ad754a36-b951-38da-a116-a05fb572d7ca                * 
 *                                                                            * 
 ****************************************************************************** 
 executing: gmx
                      :-) GROMACS - gmx mdrun, 2025.4 (-:

Executable:   /usr/local/gromacs/bin/gmx
Data prefix:  /usr/local/gromacs
Working dir:  /home
Command line:
  gmx mdrun -h

SYNOPSIS
gmx mdrun [-s [<.tpr>]] [-cpi [<.cpt>]] [-table [<.xvg>]] [-tablep [<.xvg>]]
...
```

---

## Environment in dockerfile is preserved - I

You can check the dockerfile: <https://github.com/mariojmdavid/docker-gromacs-cuda/blob/master/gromacs/Dockerfile-cpu>

```dockerfile
FROM ubuntu:24.04
LABEL maintainer="Mario David <mariojmdavid@gmail.com>"
ARG gromacs_ver
RUN apt-get update \
...
ENV PATH=$PATH:/usr/local/gromacs/bin
ENV LD_LIBRARY_PATH=/usr/local/gromacs/lib
WORKDIR /home
```

---

## Environment in dockerfile is preserved in `udocker` container - II

Just check the `ENV` and `WORKDIR`:

```bash
udocker run grom_gpu env
...
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/gromacs/bin
LD_LIBRARY_PATH=/usr/local/gromacs/lib

udocker run grom_gpu pwd
...
/home
```

---

## I want to install/compile in a container! - I

Pull some base image, create a container and run:

```bash
udocker pull almalinux:9
udocker create --name=mypython almalinux:9
udocker run mypython bash
```

And after that install and/or compile whatever you want

---

## I want to install/compile in a container! - II

Now you are inside the container and seems you are `root`:

```bash
dnf -y install python3 gcc-c++ python3-pip
pip-3 install numpy matplotlib scipy
exit
```

You are satisfied so, you exit the container, but... I want to preserve what I installed.

---

## `udocker` export and import

You can export a container into a tarball, for safekeeping:

```bash
udocker export -o mypython.tar mypython
```

Now you can import this container into an image with a given tag (empty tag defaults to `latest`):

```bash
udocker import mypython.tar mypython:v1.0
```

---

## `udocker` list images long format

```bash
udocker images -l
REPOSITORY
...
almalinux:9    .
 /home/david/.udocker/repos/almalinux/9
    /sha256:c9bcec02f046478f7ecf78b9568b666cc3b63a2effe339b1022e3b550faca3e8 (0 MB)
    /sha256:08d3c44badca17b0b810e53779272d43e9542081ae05f516071ae4d5d2369271 (67 MB)
mypython:v1.0    .
 /home/david/.udocker/repos/mypython/v1.0
    /9e1605be9a6064f41fe0ee83c6ad3cd644d77d5b3c8ff45af4157719ccd627a3.json (0 MB)
    /9e1605be9a6064f41fe0ee83c6ad3cd644d77d5b3c8ff45af4157719ccd627a3.layer (780 MB)
```

---

<!-- _class: lead -->

# About mounting volumes and directories

---

## Mounting a directory in the container - I

Assume you have a directory you want to use inside the container.
First grab yourself a tpr file:

```bash
mkdir -p $HOME/udocker-tutorial/gromacs/input
cd $HOME/udocker-tutorial/gromacs/input/
wget --no-check-certificate https://download.a.acnca.pt/webdav/gromacs-input/md.tpr
```

---

## Mounting a directory in the container - II

We will bind mount the directory in the `/home/user` inside the container
(if this directory does not exist inside the container, then it will be created):

```bash
udocker run -v=$HOME/udocker-tutorial/gromacs:/home/user -w=/home/user grom_gpu /bin/bash
```

---

## Mounting a directory in the container - III

Now, inside the container:

```bash
ls -al
total 12
drwxrwxr-x 3 root root 4096 Apr  4 08:31 .
drwxr-xr-x 3 root root 4096 Apr  4 08:42 ..
drwxrwxr-x 2 root root 4096 Apr  4 08:31 input
```

---

## Mounting a directory in the container - IV

Inside the container - make a directory for your output, and run your favourite molecular dynamics
simulation software, (if you want wait a few minutes to finish, will not take long):

```bash
mkdir output
cd output
gmx mdrun -s /home/user/input/md.tpr -deffnm ud-tutorial \
    -maxh 0.50 -resethway -noconfout -nsteps 10000 -g logile

exit
```

---

## Mounting a directory in the container - V

And back to your preferred machine:

```bash
ls $HOME/udocker-tutorial/gromacs/output
logile.log  ud-tutorial.edr  ud-tutorial.trr  ud-tutorial.xtc
```

All nice output files right there in you home directory.

---

<!-- _class: lead -->

# End of Hands On part II

![width:200px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)
