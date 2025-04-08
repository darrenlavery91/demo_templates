#!/bin/bash

# Check if 'kind' and 'kubectl' are installed
# command -v kind >/dev/null 2>&1 || { echo "kind is not installed. Please install it first."; exit 1; }
# command -v kubectl >/dev/null 2>&1 || { echo "kubectl is not installed. Please install it first."; exit 1; }

# # Set up Kind Cluster
# echo "Creating Kind cluster 'argocd-cluster'..."
# kind create cluster --name argocd-cluster

# Wait for cluster to be fully initialized
# echo "Waiting for Kind cluster to be ready..."
# kubectl cluster-info --context kind-argocd-cluster

# Install ArgoCD
echo "Installing ArgoCD in the Kind cluster..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose ArgoCD's Web UI
echo "Setting up port forwarding to access ArgoCD Web UI..."
kubectl port-forward svc/argocd-server -n argocd 9090:443 &

# Wait for port-forward to initialize
echo "Waiting for ArgoCD Web UI to be accessible at https://localhost:9090"
sleep 80

# Fetch the initial admin password
echo "Fetching ArgoCD initial admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Display login details
echo "ArgoCD is installed and running!"
echo "You can now access the ArgoCD Web UI at: https://localhost:9090"
echo "Login with username 'admin' and password: $ARGOCD_PASSWORD"

# Instructions for the user
echo "To access the ArgoCD Web UI, open your browser and navigate to https://localhost:9090."
echo "Login with the username 'admin' and the password above."

# Reminder to the user to set up their cluster context (if needed)
echo "Note: ArgoCD will be configured to deploy to the same Kind cluster automatically."

echo "Setup Complete!"

