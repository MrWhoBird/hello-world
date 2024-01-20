#!/bin/bash
sudo -i
wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade -y
yum install fontconfig java-17 -y
yum install jenkins -y
systemctl enable jenkins
systemctl start jenkins
yum install git -y