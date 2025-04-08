#!/bin/bash

# Define the namespace
namespace="flux-system"

# Create the namespace
kubectl create namespace $namespace

# Apply Flux Deployment and Service manifest
kubectl apply -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml

echo "Flux has been deployed in the $namespace namespace."
