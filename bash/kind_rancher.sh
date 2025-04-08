#!/bin/bash

# Ensure Homebrew is installed
# if ! command -v brew &> /dev/null
# then
#   echo "Homebrew not found, installing..."
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# fi

# # Install Docker if not already installed
# if ! command -v docker &> /dev/null
# then
#   echo "Docker not found, installing..."
#   brew install docker
# else
#   echo "Docker is already installed."
# fi

# # Install Kind if not already installed
# if ! command -v kind &> /dev/null
# then
#   echo "Kind not found, installing..."
#   brew install kind
# else
#   echo "Kind is already installed."
# fi

# # Install kubectl if not already installed
# if ! command -v kubectl &> /dev/null
# then
#   echo "kubectl not found, installing..."
#   brew install kubectl
# else
#   echo "kubectl is already installed."
# fi


# Add Rancher Helm repository
echo "Adding Rancher Helm repository..."
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

# Create a namespace for Rancher
echo "Creating namespace for Rancher..."
kubectl create namespace cattle-system

# cert-manager
echo "Adding Jetstack Helm repository..."
helm repo add jetstack https://charts.jetstack.io
helm repo update
echo "Installing cert-manager..."
# Install cert-manager using Helm
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Install Rancher using Helm
echo "Installing Rancher..."
helm install rancher rancher-latest/rancher \    
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set bootstrapPassword=admin \
  --set global.cattle.psp.enabled=false

# Wait for Rancher to be ready
echo "Waiting for Rancher to be ready..."
kubectl -n cattle-system rollout status deploy/rancher

sleep 60
# Check if Rancher is running
if kubectl -n cattle-system get pods | grep -q "rancher-"; then
  echo "Rancher is running."
else
  echo "Rancher is not running."
  exit 1
fi

# Expose Rancher via kubectl port-forward
echo "Exposing Rancher via kubectl port-forward..."
#node port
kubectl expose svc rancher --name=rancher --namespace cattle-system --port 80 --target-port 80 --type NodePort --dry-run=client -o yaml | kubectl apply -f -
kubectl expose svc rancher --name=rancher-https --namespace cattle-system --port 443 --target-port 443 --type NodePort --dry-run=client -o yaml | kubectl apply -f -

sleep 30

kubectl port-forward -n cattle-system svc/rancher 8080:80 8443:443

# Wait for Rancher to be available
echo "Waiting for Rancher to be available..."
timeout 300 bash -c "until nc -z localhost 8080; do sleep 1; done"

# Display Rancher URL
echo "Rancher is accessible at http://localhost:8080"

