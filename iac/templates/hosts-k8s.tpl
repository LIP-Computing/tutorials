[k8s_master]
${pub_ip} ansible_user=centos

[k8s_node]
%{ for ip in priv_ip ~}
${ip} ansible_user=centos
%{ endfor ~}

[k8s_node:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q centos@${pub_ip}"'

[all:vars]
ansible_python_interpreter=/bin/python3
