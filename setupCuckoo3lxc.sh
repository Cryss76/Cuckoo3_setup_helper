#!/bin/sh

# Create lxc-profile with macvlan
# Create lxc-container (Ubuntu 20.04 as recommended in the docs)
lxc launch images:ubuntu/focal cuckoo3
lxc exec cuckoo3 -- sh -c "useradd -m -s /bin/bash cuckoo"
lxc exec cuckoo3 -- sh -c "passwd cuckoo"
ssh-keygen -b 4096 -t rsa -f cuckoo3
lxc exec cuckoo3 -- sh -c "apt install -y openssh-server"
ip=$(lxc exec cuckoo3 -- sh -c "ip addr show eth0|grep -Eo 'inet [0-9.]+' | cut -d\  -f2")
ssh-copy-id -i cuckoo3 cuckoo@$ip
lxc exec cuckoo3 -- sh -c "gpasswd -a cuckoo sudo"
echo "[cuckoo3Container]" > hosts
echo $ip >> hosts
echo "" >> hosts
echo "[cuckoo3Container:vars]" >> hosts
echo "ansible_user=cuckoo" >> hosts
ansible-playbook -i hosts -K --private-key=cuckoo3 setup_cuckoo3_dependencies.yml

