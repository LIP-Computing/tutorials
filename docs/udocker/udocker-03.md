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

```bash
$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
gromacs      latest    8473080f1963   3 minutes ago   376MB
ubuntu       20.04     ff0fea8310f3   2 weeks ago     72.8MB
```

---

<!-- _class: lead -->

# About mounting volumes and directories

---
