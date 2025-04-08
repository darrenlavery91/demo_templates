# Deploying NGINX Ingress Controller in Kubernetes

## Overview
This setup deploys the NGINX Ingress Controller in a Kubernetes cluster. The Ingress Controller allows external access to services inside the cluster, routing traffic based on defined Ingress rules.

## Prerequisites
Ensure you have the following installed:
- A running Kubernetes cluster
- `kubectl` configured to access the cluster
- (Optional) A cloud provider that supports LoadBalancers, or use `NodePort` for on-prem setups

## Deployment Steps

### 1. Create the Namespace
Create a namespace to isolate the Ingress Controller:
```sh
kubectl apply -f namespace.yaml
```

### 2. Deploy the NGINX Ingress Controller
Deploy the Ingress Controller using a Kubernetes Deployment:
```sh
kubectl apply -f deployment.yaml
```

### 3. Create a Service to Expose the Ingress Controller
Apply the Service manifest to expose the controller:
```sh
kubectl apply -f service.yaml
```
- If using a cloud provider, the LoadBalancer will assign an external IP.
- If on-prem, change the `type` to `NodePort` and access via a node’s IP and assigned port.

### 4. Deploy an Example Ingress Resource
To route traffic to an internal service, apply an Ingress rule:
```sh
kubectl apply -f ingress.yaml
```

### 5. Create a ServiceAccount (Optional for RBAC-enabled clusters)
Run the following command to create the required ServiceAccount:
```sh
kubectl apply -f serviceaccount.yaml
```

## How It Works
1. The **Ingress Controller** listens for Ingress resources and routes traffic accordingly.
2. The **Service** exposes the Ingress Controller on a LoadBalancer or NodePort.
3. The **Ingress Resource** defines routing rules, mapping domain names to internal services.
4. The **ServiceAccount** (if needed) ensures the controller has necessary permissions.

## Verifying the Setup
- Check if the controller is running:
  ```sh
  kubectl get pods -n ingress-nginx
  ```
- Get the external IP of the LoadBalancer:
  ```sh
  kubectl get svc -n ingress-nginx
  ```
- Test access via a web browser or `curl`:
  ```sh
  curl -H "Host: nginx.public_darren" http://<EXTERNAL_IP>
  ```

## Cleanup
To remove the deployment:
```sh
kubectl delete namespace ingress-nginx
```

This will remove all related resources.