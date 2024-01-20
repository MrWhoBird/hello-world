#!/bin/bash
sudo -i
yum install docker -y
systemctl enable docker
systemctl start docker
useradd dockeradmin
passwd dockeradmin
useradd ansadmin
passwd ansadmin
usermod -aG docker dockeradmin
mkdir /opt/docker
chown -R dockeradmin:dockeradmin /opt/docker
cd /opt/docker
cat <<EOT>> ./Dockerfile
FROM tomcat:latest
RUN cp -R  /usr/local/tomcat/webapps.dist/*  /usr/local/tomcat/webapps
COPY ./*.war /usr/local/tomcat/webapps
EOT
  cat <<EOT>> /etc/hostname
  docker-server
  EOT
  hostname docker-server
  exit 
  hostname docker-server