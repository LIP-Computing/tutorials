---
marp: true
theme: default
paginate: true
---
# Openstack CLI tutorial

Based on Openstack Stein

Mario David <david@lip.pt>
Jorge Gomes <jorge@lip.pt>

---

## Pre-requisites

* Install Openstack command line clients in your laptop or desktop, either
  with pip or from packages:
  * <https://docs.openstack.org/mitaka/user-guide/common/cli_install_openstack_command_line_clients.html>

* Set the Openstack environment variables, an rc shell file can be
  obtained from the Openstack dashboard, that are your credentials
  to access Openstack through the CLI.

---

## Access to Openstack through the CLI

The openstack credentials for your user, so you can set the
environment variables with:

```bash
source os-tut.sh
```

This will set the following environment variables:

```bash
OS_PROJECT_DOMAIN_NAME=Default
OS_USER_DOMAIN_NAME=Default
OS_PROJECT_NAME=tutorial
OS_USERNAME=<USERNAME>
OS_PASSWORD=<PASSWORD>
OS_AUTH_URL=https://stratus.ncg.ingrid.pt:5000/v3
OS_IDENTITY_API_VERSION=3
OS_IMAGE_API_VERSION=2
```

---

## Testing the access to openstack

From here on you should be able to do the rest of the tutorial. Test with:

```bash
openstack project list
```

---

## Create an ssh keypair

The access to VM instances is done through an ssh key pair, where your public
key is inserted into the VM, when it is instantiated.

To create an ssh keypair, you should issue the following command:

```bash
ssh-keygen
```

By default it generates an RSA 2048 bit key that is stored in your `$HOME/.ssh/`
directory, you should set a strong `passphrase`

`.ssh/id_rsa` is your ssh private key, and `.ssh/id_rsa.pub` is your ssh public
key.

---

## List keypairs

You can list all keypairs already in openstack:

```bash
openstack keypair list
```

Set the following environment variable for ease of use in the tutorial:

```bash
export LOGNAME=myname
```

The next step is to insert your ssh public key in openstack, you should be careful
to choose a keypair name that does not yet exist:

```bash
openstack keypair create --public-key .ssh/id_rsa.pub ${LOGNAME}-key
```

---

## Instantiate a VM - I

In order to instantiate a VM, the following information is needed:

* The image name
* The flavor name
* The network name
* The keypair name

---

## Instantiate a VM - II

List images and choose one:

```bash
openstack image list
```

List flavors and choose one:

```bash
openstack flavor list
```

List all networks:

```bash
openstack network list
```

---

## Check the quota for the project

To check what is the quota - maximum amount of resources available in your project:

```bash
openstack quota show
```

---

## Create a virtual machine

Now you can create a server, note the name of the server should not exist, the
list of servers can be checked with:

```bash
openstack server list
```

This command will create a VM with root filesystem in the Openstack compute node:

```bash
openstack server create --flavor svc1.s --key-name ${LOGNAME}-key \
    --network tutorial_net --image centos7-x86_64-raw ${LOGNAME}-server
```

(Check later how to create a VM with a root filesystem as cinder volume)

---

## Check the status of VM

The status of the newly created server:

```bash
openstack server show ${LOGNAME}-server
```

Where the following attributes can be checked:

```bash
| OS-EXT-STS:power_state      | Running    |
| OS-EXT-STS:vm_state         | active     |
```

At this point the VM only has a private IP, and is not accessible from a public
network:

```bash
| addresses  | tutorial_net=192.168.1.157 
```

---

## Associate a floating public IP with the VM

In the previous slide you have listed the available networks, it includes
the public network called `public_net`, you can create a public IP with:

```bash
openstack floating ip create public_net
```

It will show in particular the attribute:

```bash
| floating_ip_address | 194.210.120.123
```

Get the server ID with:

```bash
openstack server show ${LOGNAME}-server -f value -c id
```

---

## Associate floating IP to VM

Now you can associate the floating public IP with the server:

```bash
openstack server add floating ip <SERVER_ID> 194.210.120.123
```

Now you can confirm that this floating public IP has been associated to your VM:

```bash
openstack server show ${LOGNAME}-server
    
| addresses  | tutorial_net=192.168.1.157, 194.210.120.123
```

---

## Accessing the VM

Since the base image of the VM is Centos7, the default user is `centos`,
for ubuntu base images the default user is `ubuntu`.

You can now access the VM with ssh:

```bash
ssh centos@194.210.120.123
```

---

## Creating a Cinder volume

If you need a large volume for data, you should create a Cinder volume that it can
later be attached to the VM, and formatted to you preferred filesystem.

To create a 200 GB Cinder volume, issue the following command:

```bash
openstack volume create --size 200 ${LOGNAME}-vol
```

Show the newly created volume

```bash
openstack volume show ${LOGNAME}-vol
```

---

## Attach the volume to the VM


---

## Cleanup

To delete the server:

```bash
openstack server delete ${LOGNAME}-server
```

---

## Instantiating a VM with multiple ssh keys


