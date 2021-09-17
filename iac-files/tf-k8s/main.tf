resource "openstack_compute_instance_v2" "k8s_master" {
  name            = "k8s_master"
  image_name      = var.image
  flavor_name     = var.flavor_k8s_master
  key_pair        = var.keypair
  security_groups = ["default"]

  network {
    name = var.priv_net
  }
}

resource "openstack_compute_instance_v2" "k8s_node" {
  name            = "k8s_node_${count.index}"
  image_name      = var.image
  flavor_name     = var.flavor_k8s_master
  key_pair        = var.keypair
  security_groups = ["default"]
  count           = var.nnodes

  network {
    name = var.priv_net
  }
}

resource "openstack_networking_floatingip_v2" "k8s_master" {
  pool = var.pub_net
}

resource "openstack_compute_floatingip_associate_v2" "k8s_master" {
  floating_ip = openstack_networking_floatingip_v2.k8s_master.address
  instance_id = openstack_compute_instance_v2.k8s_master.id
}

output "pub_ip" {
  value = "${openstack_networking_floatingip_v2.k8s_master.address}"
}

output "priv_ip" {
  value =["${openstack_compute_instance_v2.k8s_node[*].network[0].fixed_ip_v4}"]
}

resource "local_file" "AnsibleInventory" {
  content = templatefile("../templates/hosts-k8s.tpl",
    {
      pub_ip = openstack_networking_floatingip_v2.k8s_master.address,
      priv_ip = openstack_compute_instance_v2.k8s_node[*].network[0].fixed_ip_v4
    }
  )
  filename = "../ansible/hosts-k8s"
}
