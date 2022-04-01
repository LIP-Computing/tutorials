---
marp: true
theme: gaia
paginate: true
author: Mario David
size: 16:9
header: "![width:100px](imgs/lip-udocker-logos.png)"
footer: "![width:1200px](imgs/funding-by-log.png)"
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
</style>

<!-- _class: lead -->

# udocker tutorial

## Tutorial 03 - Hands On part II: intermediate stuff

<https://github.com/indigo-dc/udocker>

Mario David <david@lip.pt>
Jorge Gomes <jorge@lip.pt>

---

<!-- _class: lead -->

# Importing and exporting, loading and saving: images and containers

---

## I have a dockerfile!

* *But udocker does not support `build` the dockerfile...*
  * Use `docker` itself in you <lap|desk>top
  * Example: <https://github.com/mariojmdavid/docker-gromacs-cuda/blob/master/gromacs-cpu/Dockerfile-cpu>
  * `docker build --build-arg gromacs_ver=2022 -t gromacs -f Dockerfile-cpu .`
  * (Will take quite awhile)

---

## I have a docker image!

After you build the image with docker:

```bash
$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
gromacs      latest    8473080f1963   3 minutes ago   376MB
ubuntu       20.04     ff0fea8310f3   2 weeks ago     72.8MB
```

Save the image with `docker` to a tarball:

```bash
$ docker save -o gromacs.tar gromacs
```

---

## udocker load

You can load a tarball with udocker that is a docker image, and that you saved previously with docker:

```bash
$ udocker load -i gromacs.tar gromacs
```

And now you can check several things:

```bash
$ udocker images
REPOSITORY
gromacs:latest                                               .

```

---

## Create a container and run it

```bash
$ udocker create --name=grom gromacs

$ udocker ps
CONTAINER ID                         P M NAMES              IMAGE               
e2e014d9-9770-3fb5-a4a9-098a95371adf . W ['grom']           gromacs:latest      

$ udocker run grom env
 ****************************************************************************** 
 *                                                                            * 
 *               STARTING e2e014d9-9770-3fb5-a4a9-098a95371adf                * 
 *                                                                            * 
 ****************************************************************************** 
 executing: env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/gromacs/bin
LD_LIBRARY_PATH=:/usr/local/gromacs/lib
```

---

## Running gromacs with udocker

```bash
$ udocker run grom gmx mdrun -h
 ****************************************************************************** 
 executing: gmx
                       :-) GROMACS - gmx mdrun, 2022 (-:
Executable:   /usr/local/gromacs/bin/gmx
Data prefix:  /usr/local/gromacs
Working dir:  /home
Command line:
  gmx mdrun -h
SYNOPSIS
gmx mdrun [-s [<.tpr>]] [-cpi [<.cpt>]] [-table [<.xvg>]] [-tablep [<.xvg>]]
```

---

## Environment in dockerfile is preserved - I

You can check the dockerfile: <https://github.com/mariojmdavid/docker-gromacs-cuda/blob/master/gromacs-cpu/Dockerfile-cpu>

```dockerfile
FROM ubuntu:20.04
LABEL maintainer="Mario David <mariojmdavid@gmail.com>"
...
ENV PATH=$PATH:/usr/local/gromacs/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/gromacs/lib
WORKDIR /home
```

---

## Environment in dockerfile is preserved in udocker container - II

Just check the `ENV` and `WORKDIR`:

```bash
$ udocker run grom env
...
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/gromacs/bin
LD_LIBRARY_PATH=:/usr/local/gromacs/lib

$ udocker run grom pwd
...
/home
```

---

## I want to install/compile in a container! - I

Pull some base image, create a container and run:

```bash
$ udocker pull rockylinux
$ udocker create --name=mypython rockylinux
$ udocker run mypython bash
```

And after that install and/or compile whatever you want

---

## I want to install/compile in a container! - II

Now you are inside the container:

```bash
# dnf -y install python39 gcc-c++
# pip-3 install numpy matplotlib scypy
```

You are satisfied so you exit the container, but... I want to preserve what I did.

---

<!-- _class: lead -->

# About mounting volumes and directories

---
