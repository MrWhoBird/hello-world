#!/bin/bash
sudo -i
useradd ansadmin
passwd ansadmin
yum install ansible -y
yum install docker -y
systemctl enable docker
systemctl start docker

usermod -aG docker ansadmin
mkdir /opt/docker
chown -R ansadmin:ansadmin /opt/docker
cd /opt/docker

cat <<EOT>> ./Dockerfile
FROM tomcat:latest
RUN cp -R  /usr/local/tomcat/webapps.dist/*  /usr/local/tomcat/webapps
COPY ./*.war /usr/local/tomcat/webapps
EOT

cat <<EOT>> ./create-image-regapp.yml
---
- hosts: ansible
  tasks:
  - name: create docker image
    command: docker build -t devopst/regapp:latest .
    args:
      chdir: /opt/docker
  - name: push docker image
    command: docker push devopst/regapp:latest
EOT

cat <<EOT>> ./kube-deploy.yml
---
- hosts: k8s
  user: root
  tasks:
  - name: deploy regapp on k8s
    command: kubectl apply -f ./regapp-deploy.yml
  - name: create service for regapp
    command: kubectl apply -f ./regapp-service.yml
EOT

cat <<EOT>> ./docker-deployment-regapp.yml
---
- hosts: dockerhost
  tasks:
  - name: stop existing container
    command: docker stop regapp-server
    ignore_errors: yes

  - name: remove the container
    command: docker rm regapp-server
    ignore_errors: yes

  - name: remove image
    command: docker rmi devopst/regapp:latest
    ignore_errors: yes
    
  - name: create container
    command: docker run -d --name regapp-server -p 8082:8080 devopst/regapp:latest
EOT

cat <<EOT>> ./regapp-deploy.yml
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: devopst-regapp
  labels: 
     app: regapp

spec:
  replicas: 2 
  selector:
    matchLabels:
      app: regapp

  template:
    metadata:
      labels:
        app: regapp
    spec:
      containers:
      - name: regapp
        image: devopst/regapp
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
EOT

cat <<EOT>> ./regapp-service.yml
apiVersion: v1
kind: Service
metadata:
  name: devopst-service
  labels:
    app: regapp 
spec:
  selector:
    app: regapp 

  ports:
    - port: 8080
      targetPort: 8080

  type: LoadBalancer
EOT