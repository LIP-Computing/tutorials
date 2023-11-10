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

## Advanced technical details

<https://github.com/indigo-dc/udocker>

Mario David <david@lip.pt>
Jorge Gomes <jorge@lip.pt>

![width:150px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)

---

## Programing languages and OS

* Implemented
  * python, C, C++, go

* Can run:
  * CentOS 6, CentOS 7, RHEL 8 or RHEL 9 (compatible distros)
  * Ubuntu >= 16.04
  * Any distro that supports python 2.7 and >= 3.6

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
| *P1*    | PRoot       | PTRACE accelerated (with SECCOMP filtering): *DEFAULT* |
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

## udocker: PRoot engine (P1 and P2)

* PRoot uses PTRACE to intercept system calls

* Pathnames are modified before the call
  * To expand container pathnames into host pathnames
  * `/bin/ls` to `/home/user/.udocker/containers/CONTAINER-NAME/ROOT/bin/ls`

* If pathnames are returned they are modified after the call
  * To shrink host pathnames to container pathnames
  * `/home/user/.udocker/containers/CONTAINER-NAME/ROOT/bin/ls` to `/bin/ls`

---

## udocker: PRoot engine (P1 and P2)

* The P1 mode uses PTRACE + SECCOMP filtering, to limit the system call interception to the set of calls that manipulate pathnames:
  * We fixed it to work on recent kernels, contributed upstream
  * P1 is the udocker default mode

* The P2 mode uses PTRACE without SECCOMP
  * Therefore traces all system calls and can be slower

* The impact of tracing depends on the system call frequency
  * Applications that are heavily threaded or pathname intensive can be impacted

---

## udocker: runC/crun engine (R1) - I

* runC and crun are tools to spawn containers according to the Open Containers Initiative (OCI) specification:
  * They support unprivileged namespaces using the *user namespace*.
  * User namespaces have several limitations but allow execution without privileges.
  * Within the Rn modes you can only run in the container as a less privileged root.
  * Access to the host devices is limited.

---

## udocker: runC/crun engine (R1) - II

* To support runC/crun in udocker:
  * We added conversion of Docker metadata to the OCI spec format.
  * udocker can produce an OCI spec and run the containers with runC/crun transparently.
  * While runC is written in go, crun is written in C and is generally faster.
  * Depending on the host system udocker selects crun or runC.
  * crun provides support for the kernel cgroups version 2 which became required in some distributions.

---

## udocker: runC/crun engine (R2 and R3)

* The R2 and R3 execution modes are nested:
  * These modes make use of P1 or P2 from inside the R engine.
  * It is used to overcome some of the *user namespace* limitations.
  * They are not generally necessary.
  * All limitations of the P1 and P2 modes also apply to R2 and R3.

* The Pn modes require a tmp directory that is writable.

```bash
udocker run  -v /tmp myContainerId
```

---

## udocker: Fakechroot engine - I

* Fakechroot is a library to provide chroot-like behaviour.
  * It was conceived to support debootstrap in debian
  * It has been heavily modified to support Linux containers with udocker


* Uses the Linux loader LD_PRELOAD mechanism to;
  * Intercept calls to the `libc.so` functions that manipulate pathnames.
  * Translates the pathnames before and after the call similarly to PRoot.
  * Does not work with statically compiled executables.


---

## udocker: Fakechroot engine - II

* Why had to modify fakechroot heavily to execute containers ?
  * With the original fakechroot executables must match the host loader and libc.
  * Shared libraries are loaded from the host not the container.
  * Causing symbol mismatches and application crash.

* Why is this ?
  * The absolute path to the loader `ld.so` is encoded in the ELF header of all executables.
  * Loaders are statically linked and the pathnames inside are absolute and non changeable.
  * Absolute paths to libraries may also exist in the ELF headers of executables and libraries.

---

## udocker: Fakechroot engine - III

* The shared library loader `ld.so` searches for libraries:
  * If the pathname has a `/` they are directly loaded (*PROBLEM*).
  * If the pathname does not contain `/` a search path or location can be obtained from:
    1. DT_RPATH dynamic section attribute of the ELF executable (*PROBLEM*).
    2. LD_LIBRARY_PATH environment variable (this can be easily set).
    3. DT_RUNPATH dynamic section attribute of the ELF executable (*PROBLEM*).
    4. cache file /etc/ld.so.cache (*PROBLEM*).
    5. default paths such as /lib64, /usr/lib64, /lib, /usr/lib (*PROBLEM*).

---

## udocker: Fakechroot engine (F1) - I

* The loader `ld.so` is encoded in the ELF header of executables;
  * the loader is the executable that loads libraries and calls the actual executable,
  * also acts as a library providing functions to dynamically load other libraries.
  * the loader is provided and tightly coupled with the libc.

* Is essential that executables in the container are run with the loader from the container 
  * as symbols and functions will not match 
  * binaries, libc, other libs and ld.so must match

---

## udocker: Fakechroot engine (F1) - II

* The mode F1 enforces the use of the loader provided by the container:
  * Passes it as 1st argument in *exec* and similar system calls shifting argv.
  * Like this executables are always started by the loader of the container
  * The loader starts first gets the executable pathname and its arguments from argv and launches it.

* Enforcement of library locations:
  * Is performed by filling in LD_LIBRARY_PATH with the container paths.
  * Uses library paths extracted from the container `ld.so.cache`.

* If the ELF headers of binaries contain absolute paths then host libraries may endup being loaded.

---

## udocker: Fakechroot engine (F2) - I

* The mode F2 modifies the loader binary within the container:
  * A copy of the container loader is made.
  * The loader binary is then edited by udocker.
  * The loading from host locations `/lib`, `/lib64` etc is disabled.
  * The loading using the host ld.so.cache is disabled.
  * `LD_LIBRARY_PATH` is renamed to `LD_LIBRARY_REAL`.

---

## udocker: Fakechroot engine (F2) - II

* Upon execution:
  * Invocation is performed as in mode F1.
  * The `LD_LIBRARY_REAL` is filled with library paths from the container and its `ld.so.cache`.
  * Changes made by the user to `LD_LIBRARY_PATH` are intercepted 
    * the pathnames are adjusted to container locations and inserted in `LD_LIBRARY_REAL`.

---

## udocker: Fakechroot engine (F3 and F4) - I

* The mode F3 modifies binaries both executables and libraries:
  * The PatchELF tool was heavily modified to enable easier change of:
    * Loader location in ELF headers of executables.
    * Library path locations inside executables and libraries.

* With F3 or F4 the container executables and libraries are edited with PatchELF:
  * The loader location is changed to point to the container.
  * The libraries location if absolute are changed to point to the container.
  * The libraries search paths inside the binaries are changed to point to container locations.

---

## udocker: Fakechroot engine (F3 and F4) - II

* The loader no longer needs to be passed as first argument.

* The libraries are always fetched from container locations.

* The LD_LIBRARY_REAL continues to be used in F3 and F4.

* The mode F4 adds dynamic editing of executables and libraries.
  * This is useful with libraries or executables are added to the container or created as result of a compilation.

---

## udocker: Fakechroot engine (F3 and F4) - III

* Containers in modes F3 and F4 cannot be transparently moved across different systems:
  * The absolute pathnames to the container locations will likely differ.
  * In this case convert first to another mode before transfer.
  * Or at arrival use: `setup --execmode=Fn --force`.

---

<!-- _class: lead -->

# Thank you!

## Questions ?

<udocker@lip.pt>

![width:200px](imgs/lip-udocker-logos.png)
![width:1200px](imgs/funding-by-log.png)
