---
marp: true
theme: default
paginate: true
---

# udocker tutorial

## Tutorial 02 - Hands on, the CLI

Mario David <david@lip.pt>
Jorge Gomes <jorge@lip.pt>

---

## What udocker is not

* Not appropriate to run services:
  * In most cases you need root privileges for this.
  * You have Docker (or other container techs) for this.

* Build docker images:
  * You have Docker for this.
  * Use you (Lap/Des)top with Docker, for this.

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


