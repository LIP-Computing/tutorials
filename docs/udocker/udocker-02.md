---
marp: true
theme: gaia
paginate: true
author: Mario David
size: 16:9
header: "![width:50px](imgs/LIP.png) ![width:90px](imgs/BigHPC.png)"
footer: "![width:450px](imgs/funding.png)   ![width:100px](imgs/by.png)"
---

<!-- <style>

</style> -->

# udocker tutorial

## Tutorial 02 - Hands on, the CLI

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
  * For installation with pip it is advisable to setup a Python3 virtual environment

```bash
python3 -m venv udockervenv
source udockervenv/bin/activate
pip install udocker
```

---

## Installation: PyPI - II


The udocker command will be `udockervenv/bin/udocker`.

(More details: <https://indigo-dc.github.io/udocker/installation_manual.html>)

---

## Installation: tools and libraries - I

* udocker executes containers using external tools and libraries that are enhanced
  and packaged for use with udocker.

* To complete the installation, download and install the required tools and libraries.

```bash
udocker install
```

* Installs in `$HOME/.udocker`

---

## Installation: tools and libraries - II

* Optionally if you want to install the tools, libraries and later the images and c
  containers:

```bash
export UDOCKER_DIR=/my/other/nice/udocker/dir/.udocker
udocker install
```

* Explore the directory structure under `/my/other/nice/udocker/dir/.udocker`
