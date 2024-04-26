#!/bin/bash
sudo -i
yum install docker -y
systemctl enable docker
systemctl start docker
useradd dockeradmin
useradd ansadmin
usermod -aG docker dockeradmin
mkdir /opt/docker
chown -R dockeradmin:dockeradmin /opt/docker