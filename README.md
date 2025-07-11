## Purpose of This Repository

This repository is designed to help you **quickly build sandbox environments** for learning and experimenting with Kubernetes using [KIND (Kubernetes IN Docker)](https://kind.sigs.k8s.io/). It's your own personal lab to test tools, architectures, and CI/CD workflows in a safe, disposable environment.

---

## What's Included

* **Kind Builder**
  Standalone setup for spinning up local Kubernetes clusters with KIND.

* **Kind + Rancher**
  KIND cluster wrapped with Rancher for UI-based Kubernetes management.

* **KRO (Kubernetes Runtime Operator)**
  Article: [Understanding KRO](https://medium.com/@lavery91/understanding-kro-16d8514746f6)

* **vClusters (Virtual Kubernetes Clusters)**
  Article: [Understanding vClusters](https://medium.com/@lavery91/understanding-vclusters-virtual-kubernetes-clusters-129c1c2e198b)

* **Databases**
  Pre-configured examples for MongoDB, Redis, and PostgreSQL.

* **Monitoring Stack**
  Includes Prometheus, Grafana, and Alertmanager for observability.

* **Load Balancers**
  Nginx and HAProxy configurations for routing and traffic control.

* **CI/CD Tools**
  Integrations for Jenkins, ArgoCD, and Semaphore to automate deployments.

---

## Constantly Evolving

I'm always experimenting and adding new tools or improvements.
Feel free to contribute! Fork the repo, create a branch, and submit your changes via pull request.

I have only tested this really on MACOS, but if you are using windows, best would be to run ansible from WSL.

Happy building! 🛠️

---

## Ansible Installation & Kind Cluster Setup Guide

### Prerequisites

Please ensure **either Podman Desktop** or **Docker** is installed and running on your system. Please also make sure you are logged in. 

---

### Ansible Installation

#### For macOS (via Homebrew):

1. Install Homebrew (if not already installed):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Install Ansible:

   ```bash
   brew install ansible
   ```

#### For Windows (via Chocolatey):

1. Install Chocolatey (if not already installed):
   Open PowerShell **as Administrator** and run:

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; `
   [System.Net.ServicePointManager]::SecurityProtocol = `
   [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. Install Ansible:

   ```powershell
   choco install ansible -y
   ```
Note for Windows users: Try use WSL2 + Ubuntu and run ansible inside WSL

---

### Running the Kind Cluster

To spin up your Kubernetes kind cluster, run the following Ansible playbook:

```bash
sudo ansible-playbook kind_build.yaml
```
Note here please install Kind:
```bash
# For Intel Macs
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-darwin-amd64
# For M1 / ARM Macs
[ $(uname -m) = arm64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-darwin-arm64
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind

# For windows
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.29.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe

# Linux
# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```
ref: https://kind.sigs.k8s.io
---

### Example: Installing a Component

Once the cluster is running, you can install additional services:

```bash
ansible-playbook install_argocd2.yml
```

> Replace `install_argocd2.yml` with your desired installation playbook.

---

### Destroying the Kind Cluster

To tear down the kind cluster and remove associated builds:

```bash
sudo ansible-playbook destroy_kind_build.yaml
```


