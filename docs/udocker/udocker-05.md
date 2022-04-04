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
    table {
        font-size: 22px;
    }
</style>

<!-- _class: lead -->

![width:1000px](imgs/udocker-project-logos.png)

# udocker - *be anywhere*

## udocker technical details

<https://github.com/indigo-dc/udocker>

Mario David <david@lip.pt>
Jorge Gomes <jorge@lip.pt>

---

## Programing languages and OS

* Implemented
  * python, C, C++, go

* Can run:
  * CentOS 6, CentOS 7, RHEL8 (compatible distros)
  * Ubuntu >= 16.04
  * Any distro that supports python 2.6, 2.7 and >= 3.6

---

## Components

* Command line interface docker like
* Pull of containers from Docker Hub
* Local repository of images and containers
* Execution of containers with modular engines

---

## udocker: Execution engines - I

udocker supports several techniques to achieve the equivalent to a chroot without using privileges, to execute containers.

They are selected per container id via execution modes.

---

## udocker: Execution engines - II

| Mode  | Base        | Description |
| :---: | :---------: | :---------: |
| P1    | PRoot       | PTRACE accelerated (with SECCOMP filtering): *DEFAULT* |
| P2    | PRoot       | PTRACE non-accelerated (without SECCOMP filtering) |
| R1    | runC/Crun   | rootless unprivileged using user namespaces |
| R2    | runC/Crun   | rootless unprivileged using user namespaces + P1 |
| R3    | runC/Crun   | rootless unprivileged using user namespaces + P2 |
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

## udocker: runC/crun engine (R1) - I

* runC is a tool to spawn containers according to the Open Containers Initiative (OCI) specification:
  * runC supports unprivileged namespaces using the user namespace.
  * Unprivileged namespaces have many limitations but allow execution in a container Docker like environment.
  * Only run as root is supported.
  * Available devices are limited.

---

## udocker: runC/crun engine (R1) - II

* We added conversion of Docker metadata to OCI.

* udocker can produce an OCI spec and run the containers with runC transparently.

* While runC is written in go, crun is written in C and is generally faster.

* crun provides support for the kernel cgroups version 2 which became required in some distributions.

---

## udocker: runC/crun engine (R2 and R3)

* These execution modes are nested:
  * They use P1 or P2 inside the R engine

* The Pn modes require a tmp directory that is writable.

```bash
udocker --allow-root run  -v /tmp myContainerId
```

---

## udocker: Fakechroot engine - I

* Fakechroot  is a library to provide chroot-like behaviour.

* Uses the Linux loader LD_PRELOAD mechanism to;
  * intercept library calls that manipulate pathnames.
  * change the pathnames  similarly to PRoot.

* It was conceived to support debootstrap in debian

---

## udocker: Fakechroot engine - II

* The OS in the host and in the chroot must be the same;
  * as the loader inside the chroot will by default load libraries from the host
    system directories,
  * the loaders are statically linked and the pathnames inside are absolute and non changeable.

* The location of the loader itself is encoded in the executables ELF header

---

## udocker: Fakechroot engine - III

* The loaders search for libraries:
  * If the pathname has a `/` they are directly loaded.
  * If the pathname does not contain `/` (no directory specified) a search path or location can be 
    obtained from:
    1. DT RPATH dynamic section attribute of the ELF executable.
    2. LD LIBRARY PATH environment variable.
    3. DT RUNPATH dynamic section attribute of the ELF executable.
    4. cache file /etc/ld.so.cache.
    5. default paths such as /lib64, /usr/lib64, /lib, /usr/lib.

---

## udocker: Fakechroot engine (F1) - I

* The loader is encoded in the ELF header of executable;
  * is the executable that loads libraries and calls the actual executable,
  * also act as library providing functions and symbols

* Is essential that executables in the container are run with the loader inside of the container 
  instead of the host loader

---

## udocker: Fakechroot engine (F1) - II

* The mode F1 enforces the loader:
  * Passes it as 1st argument in exec* and similar calls shifting argv.
  * The loader starts first gets the executable pathname and its arguments from argv and launches it.
  * Enforcement of locations is performed by filling in LD_LIBRARY_PATH with the library locations.
  * In the container and also extracted from the container `ld.so.cache`.

---

## udocker: Fakechroot engine (F2) - I

* The mode F2 changes the loader binary within the container:
  * A copy of the container loader is made.
  * The loader binary is then edited by udocker.
  * The loading from host locations `/lib`, `/lib64` etc is disabled.
  * The loading using the host ld.so.cache is disabled.
  * `LD_LIBRARY_PATH` is renamed to `LD_LIBRARY_REAL`.

---

## udocker: Fakechroot engine (F2) - II

* Upon execution:
  * Invocation is performed as in mode F1.
  * The `LD_LIBRARY_REAL` is filled with library locations from the container and its
    `ld.so.cache`.
  * Changes made by the user to `LD_LIBRARY_PATH` are intercepted and pathnames adjusted to 
    container locations and inserted in `LD_LIBRARY_REAL`.

---

## udocker: Fakechroot engine (F3 and F4) - I

* The mode F3 changes binaries both executables and libraries:
  * The PatchELF tool was heavily modified to enable easier change of:
    * Loader location in ELF headers of executables.
    * Library path locations inside executables and libraries.

* When modes F3 or F4 are selected the executables and libraries are edited:
  * The loader location is change to point to the container.
  * The libraries location if absolute are changed to point to container.
  * The libraries search paths inside the binaries are changed to point to container locations.

---

## udocker: Fakechroot engine (F3 and F4) - II

* The loader no longer needs to be passed as first argument.

* The libraries are always fetched from container locations.

* The LD_LIBRARY_REAL continues to be used in F3 and F4.

* The mode F4 adds dynamic editing of executables and libraries.

* This is useful with libraries or executables are added to the container or created as
  result of a compilation.

---

## udocker: Fakechroot engine (F3 and F4) - III

* Containers in modes F3 and F4 cannot be transparently moved across different systems:
  * The absolute pathnames to the container locations will likely differ.
  * In this case convert first to another mode before transfer.
  * Or at arrival use: `setup --execmode=Fn --force`.
