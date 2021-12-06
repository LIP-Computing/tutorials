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

This command will create a VM:

```bash
openstack server create --flavor svc1.s --key-name ${LOGNAME}-key \
    --network tutorial_net --image centos7-x86_64-raw ${LOGNAME}-server
```

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

You should get the server ID and the volume ID first:

```bash
openstack server show ${LOGNAME}-server
| id | b0121b07-4795-4dd8-94aa-35ba3bbfe3bf |

openstack volume show ${LOGNAME}-vol
| id | 2cba33d3-ed61-483a-8ef8-a1024ef84b2c |
```

Now you can issue the following command to attach the volume to the VM through the device `/dev/vdb`

```bash
openstack server add volume \
  b0121b07-4795-4dd8-94aa-35ba3bbfe3bf 2cba33d3-ed61-483a-8ef8-a1024ef84b2c
```

---

## Using the new volume - I

Enter the VM through ssh, and list the devices:

```bash
ssh centos@194.210.120.123
sudo -s
cat /proc/partitions 
major minor  #blocks  name

   8        0   41943040 sda
   8        1   41941999 sda1
   8       16  209715200 sdb
```

The newly attached volume is attached through the `/dev/sdb` device:

---

## Using the new volume - II

You can now format the device and mount it in some directory (`/data`):

```bash
mkfs.xfs /dev/sdb  # Format device in XFS

blkid              # Get device IDs
/dev/sda1: UUID="60d67439-baf0-4c8b-94a3-3f10a362e8fe" TYPE="xfs" 
/dev/sdb: UUID="1f039523-4c3c-4759-8e93-27cb96685d54" TYPE="xfs" 
```

---

## Using the new volume - III

Add device to fstab for on boot mount the filesystem

```bash
echo "UUID=1f039523-4c3c-4759-8e93-27cb96685d54  /data  xfs  defaults  0 0" \
  >> /etc/fstab

mkdir /data
mount /data

df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        40G  900M   40G   3% /
...
/dev/sdb        200G   33M  200G   1% /data
```

---

## Adding/using security groups

---

## Cleanup

To delete the server:

```bash
openstack server delete ${LOGNAME}-server
```

---

## Instantiating a VM with multiple ssh keys
