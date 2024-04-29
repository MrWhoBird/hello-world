#!/bin/bash
sudo -i
useradd ansadmin
yum install ansible -y
yum install docker -y
systemctl enable docker
systemctl start docker
usermod -aG docker ansadmin
mkdir /opt/docker
chown -R ansadmin:ansadmin /opt/docker