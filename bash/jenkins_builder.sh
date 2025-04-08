#!/bin/bash

# Define the namespace
namespace="jenkins"

# Create the namespace
kubectl create namespace $namespace

# Apply Jenkins Deployment and Service manifest
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: $namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
        env:
        - name: JAVA_OPTS
          value: "-Djenkins.install.runSetupWizard=false"
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  namespace: $namespace
spec:
  selector:
    app: jenkins
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: NodePort
EOF

echo "Jenkins has been deployed in the $namespace namespace."
