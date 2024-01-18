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

## In the beginning - I

ssh into your favorite HPC system's head node (user interface host), install udocker and make a directory for the tutorial:

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

In particular you will need the files and scripts in `tutorials/udocker-files/`

---

## Pull a nice image

```bash
udocker pull tensorflow/tensorflow:2.8.0-gpu
```

First we create and prepare the container and later we run the actual job, the creation of the container may take some time (a few minutes), thus we do it once initially. And we can use some fast/low resource queue.

Modify the script to suit your slurm user and partition settings:

<https://github.com/LIP-Computing/tutorials/blob/main/udocker-files/prep-cont.sh>

---

## Create the container and setup exec mode

In general just submit this script to slurm, we assume using GPU partition:

```bash
chmod 755 prep-cont.sh # if needed
sbatch prep-cont.sh
```

It creates a container:

```bash
udocker create --name=tf_gpu tensorflow/tensorflow:2.8.0-gpu
```

And sets the appropriate execution mode (F3) for tensorflow and the nvidia mode:

```bash
udocker setup --execmode=F3 --force tf_gpu
udocker setup --nvidia --force tf_gpu
```

---

## Run the container

Get the script and modify it the slurm partition:

<https://github.com/LIP-Computing/tutorials/blob/main/udocker-files/run-keras.sh>

```bash
udocker run -v $TUT_DIR/tensorflow:/home/user -w /home/user tf_gpu python3 keras_example_small.py
```

And, if all goes well you should see in the slurm-xxx.out something like this:

```text
2022-04-07 08:33:13.195400: I tensorflow/stream_executor/cuda/cuda_dnn.cc:368] Loaded cuDNN version 8100
600/600 [==============================] - 34s 3ms/step - loss: 1.4332 - accuracy: 0.5095
Epoch 2/5
600/600 [==============================] - 2s 3ms/step - loss: 1.0013 - accuracy: 0.6673
...
```

---

<!-- _class: lead -->

# End of Hands On part III

![width:200px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)
