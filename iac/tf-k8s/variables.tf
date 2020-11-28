variable "keypair" {
  type    = string
  default = "mdavid"
}

variable "image" {
  type    = string
  default = "centos8-x86_64-raw"
}

variable "pub_net" {
  type    = string
  default = "public_net"
}

variable "priv_net" {
  type    = string
  default = "incd"
}

variable "flavor_k8s_master" {
  type    = string
  default = "svc1.s"
}

variable "flavor_k8s_node" {
  type    = string
  default = "svc1.m"
}

variable "nnodes" {
  type    = number
  default = 2
}

variable "ns" {
  type    = set(string)
  default = ["0", "1"]
}
