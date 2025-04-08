#!/bin/bash

# Define the namespace
namespace="doom"

# Create the namespace
kubectl create namespace $namespace

# Apply Semaphore Deployment and Service manifest
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: doom-game-config
  namespace: $namespace
data:
  index.html: |
    "<h1>Welcome to Doom Game!</h1>"
  404.html: |
    "<h1>Page not found in Doom Game</h1>"
  nginx.conf: |
    user  nginx;
    worker_processes  1;
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;

    events {
        worker_connections  1024;
    }

    http {
        sendfile        on;
        server {
          listen       80;
          server_name  localhost;

          location / {
              root   /usr/share/nginx/html;
              index  index.html index.htm;
          }

          error_page 404 /404.html;
          error_page   500 502 503 504  /50x.html;
          location = /50x.html {
              root   /usr/share/nginx/html;
          }
        }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: doom-game
  namespace: $namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: doom-game
  template:
    metadata:
      labels:
        app: doom-game
    spec:
      containers:
      - name: doom-game
        image: callumhoughton22/doom-in-docker:0.1
        ports:
        - containerPort: 8080
        env:
        - name: DISPLAY
          value: ":0"
      - name: nginx
        image: nginx:1.21.6  # Or any nginx version you prefer
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: "/usr/share/nginx/html/"
        - name: config
          mountPath: "/etc/nginx/"
      volumes:
      - name: html
        configMap:
          name: doom-game-config
          items:
            - key: index.html
              path: index.html
            - key: 404.html
              path: 404.html
      - name: config
        configMap:
          name: doom-game-config
          items:
            - key: nginx.conf
              path: nginx.conf
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: doom-game-ingress
  namespace: $namespace
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: doom-game.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: doom-game-service
            port:
              number: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: doom-game-service
  namespace: $namespace
spec:
  selector:
    app: doom-game
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
EOF

echo "Semaphore has been deployed in the $namespace namespace."
