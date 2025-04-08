#!/bin/bash

# Set variables
namespace="monitoring"
prometheus_host="prometheus.public_darren"
alertmanager_host="alertmanager.public_darren"
grafana_host="grafana.public_darren"

# Check if Kind is installed
if ! command -v kind &> /dev/null
then
  echo "Kind is not installed! Please install it first."
  exit 1
fi

# Get running Kind clusters
kind_clusters=$(kind get clusters)

if [ -z "$kind_clusters" ]; then
  echo "No Kind clusters are running. Start a Kind cluster before running this script."
  exit 1
fi

# Create monitoring namespace if it doesn't exist
kubectl create namespace $namespace || echo "Namespace $namespace already exists."

# Add Helm repositories for Prometheus and Grafana
echo "Adding Helm repositories for Prometheus and Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus stack using Helm
echo "Installing Prometheus stack using Helm..."
helm install prometheus prometheus-community/kube-prometheus-stack --namespace $namespace

# Wait for Prometheus pods to be ready
echo "Waiting for Prometheus pods to be ready..."
kubectl wait --namespace $namespace --for=condition=ready pod --selector=app.kubernetes.io/name=prometheus --timeout=180s

# Install Grafana using Helm
echo "Installing Grafana using Helm..."
helm install grafana grafana/grafana --namespace $namespace --set service.type=ClusterIP

# Wait for Grafana pod to be ready
echo "Waiting for Grafana pod to be ready..."
kubectl wait --namespace $namespace --for=condition=ready pod --selector=app.kubernetes.io/name=grafana --timeout=180s

# Create Ingress for Prometheus, Alertmanager, and Grafana
echo "Creating Ingress for Prometheus, Alertmanager, and Grafana..."
cat <<EOF > /tmp/monitoring-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring-ingress
  namespace: $namespace
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
    - host: $prometheus_host
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus-kube-prometheus-prometheus
                port:
                  number: 9090
    - host: $alertmanager_host
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus-kube-prometheus-alertmanager
                port:
                  number: 9093
    - host: $grafana_host
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  number: 3000
EOF

# Apply Ingress configuration
echo "Applying Ingress for monitoring services..."
kubectl apply -f /tmp/monitoring-ingress.yaml

# Get the Kind cluster IP
kind_ip=$(podman inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)

if [ -z "$kind_ip" ]; then
  echo "Failed to retrieve Kind cluster IP."
  exit 1
fi

# Update /etc/hosts with the monitoring domain names
echo "Updating /etc/hosts to map monitoring domains..."
echo "$kind_ip $prometheus_host $alertmanager_host $grafana_host" | sudo tee -a /etc/hosts > /dev/null

echo "Monitoring stack (Prometheus, Grafana, and Alertmanager) deployed successfully!"
echo "You can access Prometheus at http://$prometheus_host, Alertmanager at http://$alertmanager_host, and Grafana at http://$grafana_host."
