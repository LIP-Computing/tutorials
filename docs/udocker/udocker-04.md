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

# udocker - *be anywhere*

## Part 4 - Hands On: submission to SLURM clusters

<https://github.com/indigo-dc/udocker>

Mario David <david@lip.pt>, Jorge Gomes <jorge@lip.pt>

![width:150px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)

---

## In the beginning

ssh into your favorite HPC system's head node (user interface host), install udocker and make a directory for the tutorial:

```bash
mkdir udocker-tutorial
cd udocker-tutorial
export UDOCKER_DIR=$HOME/udocker-tutorial/.udocker
```

I assume that the compute/worker nodes mount your $HOME directory or, you can do this in some directory mounted in the compute/worker nodes.

---

## Pull a nice image

```bash
udocker pull tensorflow/tensorflow:2.8.0-gpu
```

First we prepare the container and later we run the actual job, the creation of the container may take some time, thus we do it once initially.

---

<!-- _class: lead -->

# End of Hands On part III

![width:200px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)
