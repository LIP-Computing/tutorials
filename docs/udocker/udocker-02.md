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
    ul {
        font-size: 28px;
    }
    p {
        font-size: 28px;
    }
</style>

<!-- _class: lead -->

![width:1000px](imgs/udocker-project-logos.png)

# udocker tutorial

## Tutorial 02 - Hands On part I: basic stuff

<https://github.com/indigo-dc/udocker>

Mario David <david@lip.pt>
Jorge Gomes <jorge@lip.pt>

---

## What udocker is not - I

* Not appropriate to run services:
  * In most cases you need root privileges for this.
  * You have Docker (or other container techs) for this.

* Build docker images:
  * You have Docker for this.
  * Use you (Lap/Des)top with Docker, for this.

---

## What udocker is not - II

* docker-compose like functionality:
  * This is usually to compose micro-services to deploy a platform/service.
  * Use docker-compose itself for this.

---

## udocker aims/objectives

* Execute applications as non privilege user.
* Execute containers from docker images (includes officially supported images in Dockerhub).
* Execute applications with very specific, customized libraries and environments, that are difficult
  to have in very controlled systems such as the HPC machines.

---

<!-- _class: lead -->

# udocker: Installation

<https://indigo-dc.github.io/udocker/installation_manual.html>

---

## Installation: tarball

* The end user can download and execute udocker without system administrator intervention.
* Install from a released version:
  * Download a release tarball from <https://github.com/indigo-dc/udocker/releases>:

```bash
wget https://github.com/indigo-dc/udocker/releases/download/v1.3.1/udocker-1.3.1.tar.gz
tar zxvf udocker-1.3.1.tar.gz
export PATH=`pwd`/udocker:$PATH
```

---

## Installation: PyPI - I

* Install from PyPI using pip:
  * For installation with pip it is advisable to setup a Python3 virtual
    environment

```bash
python3 -m venv udockervenv
source udockervenv/bin/activate
pip install udocker
```

---

## Installation: PyPI - II

The udocker command will be `udockervenv/bin/udocker`.

* Optionally, we can set `UDOCKER_DIR` environment variable where the binaries, libraries images and containers will be saved. The default directory is `$HOME/.udocker`.

```bash
mkdir udocker-tutorial
cd udocker-tutorial/
export UDOCKER_DIR=$HOME/udocker-tutorial/.udocker
```

(More details: <https://indigo-dc.github.io/udocker/installation_manual.html>)

---

## Installation: tools and libraries - I

* udocker executes containers using external tools and libraries that are enhanced and packaged for use with udocker.

* To complete the installation, download and install the required tools and libraries.

```bash
udocker install
```

---

## Installation: tools and libraries - II

* Installs by default in `$HOME/.udocker`, or
  in `UDOCKER_DIR=$HOME/udocker-tutorial/.udocker`.

* Explore the directory structure under `$HOME/udocker-tutorial/.udocker`

---

<!-- _class: lead -->

# udocker: CLI - the basic (introductory) stuff

<https://indigo-dc.github.io/udocker/user_manual.html>

---

## 0. help and version

Global help and version

```bash
udocker --help
udocker --version
```

You can get help on a given command

```bash
udocker run --help
```

---

## 1. pull

Pull an image from Dockerhub (for example, an officially supported tensorflow):

```bash
udocker pull tensorflow/tensorflow
```

---

## 2. images

List the images in your local repository (`-l` option shows long format):

```bash
udocker images
udocker images -l
```

---

## 3. create

To create a container named `mytensor`, the default execution engine is P1 (PTRACE + SECCOMP filtering):

```bash
udocker create --name=mytensor tensorflow/tensorflow
```

---

## 4. ps

List extracted containers. These are not processes but containers extracted and available for
execution:

```bash
udocker ps
```

---

## 5. run: I

Executes a container. Several execution engines are provided. The container can be specified using the container id or its associated name. Additionally it is possible to invoke run with an image name:

```bash
udocker run mytensor bash
```

---

## 5. run: II

Now you are inside the container (apparently as `root`), you might as well try out:

```bash
root@pcdavid:~# python
Python 3.8.10 (default, Nov 26 2021, 20:14:08) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow as tf
```

Or:

```bash
udocker run mytensor cat /etc/lsb-release 
```

---

## 6. setup

With `--execmode` chooses an execution mode to define how a given container will be executed. The option `--nvidia` enables access to NVIDIA GPUs (only possible if they are available).

```bash
udocker setup --execmode=F1 mytensor
udocker ps -m  # confirm change of execution engine
```

---

## 7. rm

Delete a previously created container. Removes the entire directory tree extracted from the container image and associated metadata:

```bash
udocker rm mytensor
```

---

## 8. rmi

Delete a local container image previously pulled/loaded/imported:

```bash
udocker rmi tensorflow/tensorflow
```

---

<!-- _class: lead -->

# End of Hands On part I

![width:200px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)
