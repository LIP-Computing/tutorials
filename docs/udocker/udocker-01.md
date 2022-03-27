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
