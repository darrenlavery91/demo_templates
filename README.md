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

---

### Running the Kind Cluster

To spin up your Kubernetes kind cluster, run the following Ansible playbook:

```bash
sudo ansible-playbook kind_build.yaml
```

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


