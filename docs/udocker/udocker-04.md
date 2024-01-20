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

## Before the beginning (slide deck 2)

Access the INCD advanced computing facility at Lisbon using ssh:

```bash
ssh -l <username> cirrus8.a.incd.pt
module load python/3.10.13
```

* The end user can download and execute udocker without system administrator intervention.
* Install from a released version: <https://github.com/indigo-dc/udocker/releases>:

```bash
wget https://github.com/indigo-dc/udocker/releases/download/1.3.10/udocker-1.3.10.tar.gz
tar zxvf udocker-1.3.10.tar.gz
export PATH=$HOME/udocker-1.3.10/udocker:$PATH
```

---
## In the beginning - I

Make a directory for the tutorial and set en variable of udocker to that dir:

```bash
mkdir udocker-tutorial
cd udocker-tutorial
export UDOCKER_DIR=$HOME/udocker-tutorial/.udocker
udocker version
```

Check that the `UDOCKER_DIR=$HOME/udocker-tutorial/.udocker` was created

```bash
echo $UDOCKER_DIR
ls -al $UDOCKER_DIR
```

---

## In the beginning - II

I assume that the compute/worker nodes mount your $HOME directory or, you can do this in some directory mounted in the compute/worker nodes.

Git pull the repository to get needed input files, in particular for the tensorflow/keras application:

```bash
git clone https://github.com/LIP-Computing/tutorials.git
```

In particular, you will need the files and scripts in `tutorials/udocker-files/`

```bash
cp -r tutorials/udocker-files .
```

---

## Pull a nice image

```bash
udocker pull tensorflow/tensorflow:2.11.0-gpu
```

First we create and prepare the container, later we run the actual job, the creation of the container may take some time (a few minutes), thus we do it once initially. And we can use some fast/low resource queue.

Modify the script `udocker-files/prep-cont.sh` to suit your slurm options and partition settings:

---

## Submit job to create the container

In general just submit this script to slurm, we assume using GPU partition:

```bash
cd udocker-files; chmod 755 prep-cont.sh # if needed
sbatch prep-cont.sh
```

Check job status with `squeue`

---

## Creates the container and setup exec mode

It creates a container:

```bash
udocker create --name=tf_gpu tensorflow/tensorflow:latest-gpu
```

And sets the appropriate execution mode (F3) for tensorflow and the nvidia mode:

```bash
udocker setup --nvidia --force tf_gpu
```

Check the output of the slurm job `cat slurm-NNNN.out`

---

## Run the container

Check the script `udocker-files/run-keras.sh` and modify it the slurm options and partition:

```bash
sbatch run-keras.sh
```

The script executes:

```bash
udocker run -v $TUT_DIR/udocker-files/tensorflow:/home/user -w /home/user tf_gpu python3 keras_2_small.py
```

---

## Job output

And, if all goes well you should see in the keras-xxx.out something like this:

```text

```

---

<!-- _class: lead -->

# End of Hands On part III

![width:200px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)
