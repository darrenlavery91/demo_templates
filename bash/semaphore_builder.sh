#!/bin/bash

# Define the namespace
namespace="semaphore"

# Create the namespace
kubectl create namespace $namespace

# Apply Semaphore Deployment and Service manifest
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: semaphore
  namespace: $namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: semaphore
  template:
    metadata:
      labels:
        app: semaphore
    spec:
      containers:
      - name: semaphore
        image: semaphoreui/semaphore:v2.12.17
        ports:
        - containerPort: 3000
        env:
        - name: SEMAPHORE_DB_DIALECT
          value: "bolt"
        - name: SEMAPHORE_ADMIN
          value: "admin"
        - name: SEMAPHORE_ADMIN_PASSWORD
          value: "changeme"
        - name: SEMAPHORE_ADMIN_NAME
          value: "Admin"
        - name: SEMAPHORE_ADMIN_EMAIL
          value: "admin@localhost"
---
apiVersion: v1
kind: Service
metadata:
  name: semaphore-service
  namespace: $namespace
spec:
  selector:
    app: semaphore
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
  type: NodePort
EOF

echo "Semaphore has been deployed in the $namespace namespace."
