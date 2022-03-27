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

# udocker

## *be anywhere*

<https://github.com/indigo-dc/udocker>

Mario David <david@lip.pt>
Jorge Gomes <jorge@lip.pt>

---

## Scientific computing and containers

Running applications across infrastructures may require considerable effort

* Computers
  * Several computing systems
  * Laptops, Desktops, Farms, Cloud, HPC

* OSes
  * Several operating systems
  * Linux flavors, Distribution versions

* Environments
  * Specific computing environments
  * Compilers, Libraries, Customizations

* Applications
  * Multiple applications often combined
 * Portability, Maintainability, Reproducibility

**Need a consistent portable way of running applications**

---

## Scientific computing and containers

Running applications across infrastructures may require considerable effort

* Computers
  * Several computing systems
  * Laptops, Desktops, Farms, Cloud, HPC

* OSes
  * Several operating systems
  * Linux flavors, Distribution versions

* Environments
  * Specific computing environments
  * Compilers, Libraries, Customizations

* Applications
  * Multiple applications often combined
 * Portability, Maintainability, Reproducibility

**Need a consistent portable way of running applications**

---

## Containers for batch processing

* Challenges of batch systems?
  * Integrate it with the batch system (how to start/stop etc) ?
  * Respect batch system policies (such as quotas/limits) ?
  * Respect batch system actions (job delete/kill) ?
  * Collect accounting ?

* Can we execute in a more basic way?
  * Can we download container images ?
  * Can we run without a layered filesystem ?
  * Can we run them as normal user ?
  * Can we still enforce container metadata ?

---

## udocker: Introduction - I

* Run applications encapsulated in docker containers:
  * without using docker 
  * without using (root) privileges
  * without system administrators intervention
  * without additional system software
  * does not require Linux namespaces

* Run:
  * as a normal user
  * with the normal process controls and accounting
  * in interactive or batch systems

---

## udocker: Introduction - II

udocker is open source

Developed under the Indigo-Datacloud, DEEP Hybrid-Datacloud, EOSC-Synergy and BigHPC projects

<https://github.com/indigo-dc/udocker>

<https://github.com/indigo-dc/udocker/tree/master>

<https://github.com/indigo-dc/udocker/tree/devel>

Documentation: <https://indigo-dc.github.io/udocker/>

---

## udocker: CLI

Run time to execute docker containers:

search
pull
images
create
rmi
ps
rm
run
login
logout
load
save
import
export
setup
clone
verify
Inspect
mkrepo

---

# udocker: How does it work ...

---

## Programing languages and OS

* Implemented
  * python, C, C++, go

* Can run:
  * CentOS 6, CentOS 7, Fedora >= 23
  * Ubuntu 14.04, Ubuntu 16.04
  * Any distro that supports python 2.6 and 2.7

* Components:
  * Command line interface docker like
  * Pull of containers from Docker Hub
  * Local repository of images and containers
  * Execution of containers with modular engines

---

## udocker: pull - Images

* Layers and metadata are pulled with DockerHub REST API.

* Image metadata is interpreted to identify the layers.

* Layers are stored in the use home directory under `${UDOCKER_DIR}/.udocker/layers` 
  so that can be share by multiple images.

---

## udocker: Create containers

* Are produced from the layers by flattening them.

* Each layer is extracted on top of the previous.

* Whiteouts  are respected, protections are changed.

* The obtained directory trees are stored under `${UDOCKER_DIR}/.udocker/containers`
  in the user home directory.

---

## udocker: Run container

Execution: chroot-like.

---

## udocker: Execution engines

udocker supports several techniques to achieve the equivalent to a chroot without using privileges:

  * They are selected per container id via execution modes

| Mode  | Base        | Description |
| :---: | :---------: | :---------: |
| P1    | PRoot       | PTRACE accelerated (with SECCOMP filtering): *DEFAULT* |
| P2    | PRoot       | PTRACE non-accelerated (without SECCOMP filtering) |
| R1    | runC        | rootless unprivileged using user namespaces |
| F1    | Fakechroot  | with loader as argument and LD_LIBRARY_PATH |
| F2    | Fakechroot  | with modified loader, loader as argument and LD_LIBRARY_PATH |
| F3    | Fakechroot  | modified loader and ELF headers of binaries + libs changed |
| F4    | Fakechroot  | modified loader and ELF headers dynamically changed |
| S1    | Singularity | where locally installed using chroot or user namespaces |

---

## udocker: PRoot engine

* PRoot uses PTRACE to intercept system calls

* Pathnames are modified before the call
  * To expand container pathnames into host pathnames

* Pathnames are modified after the call
  * To shrink host pathnames to container pathnames

---

## udocker: PRoot engine (P1 and P2)

* The P1 mode uses PTRACE + SECCOMP filtering, to limit the interception to the set of calls
  that manipulate pathnames:
  * We developed code to make it work on recent kernels
  * P1 is the udocker default mode

* The P2 mode uses only PTRACE -> therefore tracing all calls

* The impact of tracing depends on the system call frequency

---

## udocker: Fakechroot engine

* Fakechroot  is a library to provide chroot-like behaviour.

* Uses the Linux loader LD_PRELOAD mechanism to;
  * intercept library calls that manipulate pathnames.
  * change the pathnames  similarly to PRoot.

* It was conceived to support debootstrap in debian

* The OS in the host and in the chroot must be the same;
  * as the loader inside the chroot will by default load libraries from the host
    system directories,
  * the loaders are statically linked and the pathnames inside are absolute and non changeable.


---

## udocker: Fakechroot engine

* The loaders search for libraries:
  * If the pathname has a `/` they are directly loaded.
  * If the pathname does not contain `/` (no directory specified) a search path or location can be 
    obtained from:
    1. DT RPATH dynamic section attribute of the ELF executable.
    2. LD LIBRARY PATH environment variable.
    3. DT RUNPATH dynamic section attribute of the ELF executable.
    4. cache file /etc/ld.so.cache.
    5. default paths such as /lib64, /usr/lib64, /lib, /usr/lib.

* The location of the loader itself is encoded in the executables ELF header

---

## udocker: Fakechroot engine (F1)

* The loader is encoded in the ELF header of executable;
  * is the executable that loads libraries and calls the actual executable,
  * also act as library providing functions and symbols

* Is essential that executables in the container are run with the loader inside of the container 
  instead of the host loader

---

## udocker: Fakechroot engine (F1)

* The mode F1 enforces the loader:
  * Passes it as 1st argument in exec* and similar calls shifting argv.
  * The loader starts first gets the executable pathname and its arguments from
    argv and launches it.
  * Enforcement of locations is performed by filling in LD_LIBRARY_PATH with the library locations. * In the container and also extracted from the container `ld.so.cache`.

---

## udocker: Fakechroot engine (F2)

* The mode F2 changes the loader binary within the container:
  * A copy of the container loader is made.
  * The loader binary is then edited by udocker.
  * The loading from host locations `/lib`, `/lib64` etc is disabled.
  * The loading using the host ld.so.cache is disabled.
  * `LD_LIBRARY_PATH` is renamed to `LD_LIBRARY_REAL`.

---

## udocker: Fakechroot engine (F2)

* Upon execution:
  * Invocation is performed as in mode F1.
  * The `LD_LIBRARY_REAL` is filled with library locations from the container and its
    `ld.so.cache`.
  * Changes made by the user to `LD_LIBRARY_PATH` are intercepted and pathnames adjusted to 
    container locations and inserted in `LD_LIBRARY_REAL`.

---

## udocker: Fakechroot engine (F3 and F4)

* The mode F3 changes binaries both executables and libraries:
  * The PatchELF tool was heavily modified to enable easier change of:
    * Loader location in ELF headers of executables.
    * Library path locations inside executables and libraries.

* When modes F3 or F4 are selected the executables and libraries are edited:
  * The loader location is change to point to the container.
  * The libraries location if absolute are changed to point to container.
  * The libraries search paths inside the binaries are changed to point to container locations.

---

## udocker: Fakechroot engine (F3 and F4)

* The loader no longer needs to be passed as first argument.

* The libraries are always fetched from container locations.

* The LD_LIBRARY_REAL continues to be used in F3 and F4.

* The mode F4 adds dynamic editing of executables and libraries.

* This is useful with libraries or executables are added to the container or created as
  result of a compilation.

---

## udocker: Fakechroot engine (F3 and F4)

* Containers in modes F3 and F4 cannot be transparently moved across different systems:
  * The absolute pathnames to the container locations will likely differ.
  * In this case convert first to another mode before transfer.
  * Or at arrival use: `setup --execmode=Fn --force`.

---

## udocker: runC engine (R1)

* runC is a tool to spawn containers according to the Open Containers Initiative (OCI)
  specification:
  * In a very recent release 1.0 candidate 3, runC supports unprivileged namespaces using the
    user namespace.
  * Unprivileged namespaces have many limitations but allow execution in a container Docker like
    environment.
  * Only run as root is supported.
  * Available devices are limited.

* We added conversion of Docker metadata to OCI.

* udocker can produce an OCI spec and run the containers with runC transparently.

---

# udocker: Running applications ...

---

## udocker & Lattice QCD

OpenQCD is a very advanced code to run lattice simulations

Scaling performance as a function of the cores for the computation of application
of the Dirac operator to a spinor field.

udocker & Lattice QCD

OpenQCD is a very advanced code to run lattice simulations

Scaling performance as a function of the cores for the computation of application of the Dirac operator to a spinor field.

Using OpenMPI

udocker in P1 mode

![width:600px](imgs/scaling.png)

---

## udocker & udocker & Molecular dynamics

Gromacs is widely used both in biochemical and non-biochemical systems. 

udocker P mode have lower performance, udocker F mode same as Docker.

Using CUDA and OpenMP

![width:600px](imgs/ratio-gromacs.png)

---

## udocker & Phenomenology

MasterCode connects several complex codes. Hard to deploy. 

Scanning through large parameter spaces. High Throughput Computing.

C++, Fortran, many authors, legacy code.

Performance Degradation (*udocker in P1 mode*)
  
| Environment | Compiling | Running |
| :---------: | :-------: | :-----: |
| HOST        |  0% |   0% |
| DOCKER      | 10% | 1.0% |
| udocker     |  7% | 1.3% |
| VirtualBox  | 15% | 1.6% |
| KVM         |  5% | 2.6% |

---

# udocker: Next ...

---

## udocker: What’s next

* Increase automation for MPI/infiniband applications:
  * OpenMPI and MPICH.

* Better translation of “volume” directories.

* Command line interface enhancements.

* Improve root emulation.

---

## Other container technologies

* Singularity (LBL) - udocker currently supports it as execution mode

* Charliecloud (LANL) - devels contacted Jorge: can udocker have a mode for it?
  "Merge" the udocker, CLI functionality with underlying charlicloud engine?

* Shifter (NERSC) - at the moment no plans on any type of usage/integration in udocker. 

* Podman (RedHat)
