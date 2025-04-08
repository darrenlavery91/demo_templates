#!/bin/bash

# Check if 'kind' and 'kubectl' are installed
command -v kind >/dev/null 2>&1 || { echo "kind is not installed. Please install it first."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is not installed. Please install it first."; exit 1; }

# Install ArgoCD
echo "Installing ArgoCD in the Kind cluster..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Nginx Ingress Controller if not already installed
echo "Installing Nginx Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for Nginx Ingress Controller to be ready
echo "Waiting for Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=ingress-nginx \
  --timeout=120s

# Create Ingress resource for ArgoCD
echo "Creating Ingress resource for ArgoCD..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
EOF

# Update /etc/hosts file for local DNS resolution
echo "Updating /etc/hosts file to resolve argocd.local..."
if ! grep -q "argocd.local" /etc/hosts; then
  echo "127.0.0.1 argocd.local" | sudo tee -a /etc/hosts
fi

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --namespace argocd \
  --for=condition=available deployment/argocd-server \
  --timeout=120s

# Fetch the initial admin password
echo "Fetching ArgoCD initial admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Display login details
echo "ArgoCD is installed and running!"
echo "You can now access the ArgoCD Web UI at: https://argocd.local"
echo "Login with username 'admin' and password: $ARGOCD_PASSWORD"

# Reminder to the user to set up their cluster context (if needed)
echo "Note: ArgoCD will be configured to deploy to the same Kind cluster automatically."

# Check if the 'ingress-ready' label is set on the node
echo "Checking if the node has the 'ingress-ready=true' label..."
NODE_NAME=$(kubectl get nodes -o custom-columns=":metadata.name")

# Check if the label exists on the node
LABEL_EXISTS=$(kubectl get node $NODE_NAME --show-labels | grep -o "ingress-ready=true")

if [[ -z "$LABEL_EXISTS" ]]; then
  echo "Label 'ingress-ready=true' not found on node. Adding it..."
  kubectl label nodes $NODE_NAME ingress-ready=true || { echo "Failed to label node."; exit 1; }
else
  echo "Node already has the 'ingress-ready=true' label."
fi

# Wait for Ingress-NGINX pods to be scheduled and running
echo "Waiting for Ingress-NGINX controller pod to be running..."
kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx

echo "Setup Complete!"
