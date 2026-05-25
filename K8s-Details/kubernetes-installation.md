# Kubernetes Installation & Cluster Management

# What is Kubernetes Installation?

Kubernetes installation means setting up a Kubernetes cluster so containers can run, scale, communicate, and self-heal automatically.

A Kubernetes cluster contains:

| Component     | Purpose                        |
| ------------- | ------------------------------ |
| Control Plane | Manages cluster                |
| Worker Nodes  | Run applications               |
| Networking    | Pod communication              |
| Storage       | Persistent data                |
| Security      | Authentication & authorization |

---

# Kubernetes Installation Types

| Type                    | Best For                 | Example              |
| ----------------------- | ------------------------ | -------------------- |
| Local Kubernetes        | Learning & testing       | Minikube, Kind       |
| Production Self-Managed | Enterprise datacenter    | kubeadm              |
| Managed Kubernetes      | Cloud production         | EKS, AKS, GKE        |
| Bare Metal Kubernetes   | On-prem hardware         | kubeadm + MetalLB    |
| HA Kubernetes           | Critical production apps | Multi-master cluster |

---

# Kubernetes Deployment Models

```text
                 +----------------------+
                 |  Kubernetes Cluster  |
                 +----------------------+
                           |
        ------------------------------------------------
        |                     |                       |
   Local Cluster        Cloud Managed          On-Prem Cluster
  (Minikube/Kind)     (EKS/AKS/GKE)           (Bare Metal)
```

---

# 1. Minikube

# What is Minikube?

Minikube is a lightweight Kubernetes distribution that runs a single-node Kubernetes cluster locally.

Used mainly for:

* Learning Kubernetes
* Testing manifests
* CI/CD practice
* Development environments

---

# Minikube Architecture

```text
+----------------------+
|     Minikube VM      |
|----------------------|
| Control Plane        |
| Worker Node          |
| kubelet              |
| container runtime    |
+----------------------+
```

---

# Minikube Features

| Feature           | Description                        |
| ----------------- | ---------------------------------- |
| Single Node       | One-node cluster                   |
| Easy Setup        | Simple installation                |
| Local Environment | Runs on laptop                     |
| Multiple Drivers  | Docker, VirtualBox, HyperKit       |
| Addons            | Dashboard, ingress, metrics-server |

---

# Install Minikube

## Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl

sudo mv kubectl /usr/local/bin/
```

---

## Install Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

---

# Start Minikube

```bash
minikube start
```

---

# Verify Cluster

```bash
kubectl get nodes
```

---

# Minikube Important Commands

| Purpose        | Command                          |
| -------------- | -------------------------------- |
| Start cluster  | `minikube start`                 |
| Stop cluster   | `minikube stop`                  |
| Delete cluster | `minikube delete`                |
| Open dashboard | `minikube dashboard`             |
| Check status   | `minikube status`                |
| Enable ingress | `minikube addons enable ingress` |

---

# Minikube Pros & Cons

| Pros              | Cons                    |
| ----------------- | ----------------------- |
| Very easy         | Not production-ready    |
| Lightweight       | Single-node mostly      |
| Good for learning | Limited scaling         |
| Quick setup       | Performance limitations |

---

# 2. Kind (Kubernetes IN Docker)

# What is Kind?

Kind runs Kubernetes clusters using Docker containers as nodes.

Used mainly for:

* Kubernetes testing
* CI/CD pipelines
* Multi-node local clusters
* Kubernetes development

---

# Kind Architecture

```text
+--------------------------------+
| Docker Host                    |
|--------------------------------|
| kind-control-plane container   |
| kind-worker container          |
| kind-worker2 container         |
+--------------------------------+
```

---

# Install Kind

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64

chmod +x ./kind

sudo mv ./kind /usr/local/bin/kind
```

---

# Create Cluster

```bash
kind create cluster
```

---

# Multi-Node Cluster

```yaml
# cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
- role: worker
- role: worker
```

Create cluster:

```bash
kind create cluster --config cluster.yaml
```

---

# Kind Advantages

| Advantage             | Description            |
| --------------------- | ---------------------- |
| Fast                  | Very lightweight       |
| Multi-node            | Supports worker nodes  |
| Docker-based          | Easy CI/CD integration |
| Good testing platform | Ideal for pipelines    |

---

# Kind vs Minikube

| Feature     | Minikube     | Kind              |
| ----------- | ------------ | ----------------- |
| Backend     | VM/Container | Docker Containers |
| Multi-node  | Limited      | Excellent         |
| CI/CD Usage | Moderate     | Excellent         |
| Learning    | Excellent    | Excellent         |
| Speed       | Good         | Faster            |

---

# 3. kubeadm

# What is kubeadm?

kubeadm is the official Kubernetes bootstrap tool used to create production-grade Kubernetes clusters.

It installs:

* kube-apiserver
* etcd
* scheduler
* controller-manager
* kubelet

---

# kubeadm Architecture

```text
+----------------------+
| Control Plane Node   |
|----------------------|
| kube-apiserver       |
| scheduler            |
| controller-manager   |
| etcd                 |
+----------------------+

+----------------------+
| Worker Node          |
|----------------------|
| kubelet              |
| kube-proxy           |
| container runtime    |
+----------------------+
```

---

# kubeadm Prerequisites

| Requirement          | Details              |
| -------------------- | -------------------- |
| Linux Servers        | Ubuntu/RHEL          |
| Container Runtime    | containerd preferred |
| Swap Disabled        | Mandatory            |
| Network Connectivity | All nodes reachable  |
| Unique Hostnames     | Required             |

---

# Disable Swap

In Kubernetes `kubeadm` setup, **Disable Swap** means:

> Kubernetes requires Linux memory management to work directly with RAM.
> If **swap memory** is enabled, Kubernetes may not manage resources correctly.


# What is Swap?

Swap = disk space used as **extra virtual memory** when RAM becomes full.

Example:

* RAM full → Linux moves inactive memory pages to disk (`swap`)
* Disk is much slower than RAM


# Why Kubernetes disables it?

Kubernetes scheduler and kubelet depend on accurate memory usage.

If swap is enabled:

* Pods may use swap unexpectedly
* Memory metrics become inaccurate
* Node stability issues can happen
* Kubernetes may fail to schedule/manage pods properly

So `kubeadm` checks this and throws error if swap is ON.

---

# How to Disable Swap

### Temporary Disable

```bash
sudo swapoff -a
```

---

### Permanent Disable

Edit:

```bash
sudo vi /etc/fstab
```

Comment swap line:

```bash
# /swapfile none swap sw 0 0
```

or, 
```bash
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

Then reboot.

---

# Verify Swap Status

```bash
free -h
```

or

```bash
swapon --show
```

If no output → swap disabled.

---

# Install containerd (container runtime)

```bash
sudo apt update

sudo apt install -y containerd
```

---

# Install Kubernetes Packages (kubeadm/kubelet/kubectl

```bash
sudo apt install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl
```

---

# Initialize Control Plane

```bash
sudo kubeadm init \
--pod-network-cidr=192.168.0.0/16
```

---

# Configure kubectl

```bash
mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

# Install CNI Network Plugin

Example: Calico

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
```

---

# Join Worker Nodes

This command is used to **join a worker node** (or another control-plane node) to an existing Kubernetes cluster created using kubeadm.

```bash
kubeadm join <master-ip>:6443 \
--token <token> \
--discovery-token-ca-cert-hash sha256:<hash>
```

# What It Means

> “Connect this server to the Kubernetes control plane securely and become part of the cluster.”


# Command Breakdown

## 1. `kubeadm join`

Main command to join a node into cluster.

* Worker node registers with control plane
* kubelet starts communicating with API server
* Node becomes available for pod scheduling


## 2. `<master-ip>:6443`

Example:

```bash
192.168.1.10:6443
```

* IP of Kubernetes Control Plane (Master)
* `6443` = default secure Kubernetes API Server port

Worker node contacts this API endpoint.

---

# Kubernetes API Server

The API server is the brain entry point of cluster.

All components talk through it:

* kubectl
* scheduler
* kubelet
* controllers

---

## 3. `--token <token>`

Example:

```bash
--token abcdef.1234567890abcdef
```

Temporary authentication token generated by kubeadm.

Purpose:

* Verifies node is allowed to join cluster

Like:

> “Invitation code” for joining cluster.

---

# Token Properties

* Usually valid for 24 hours
* Can regenerate anytime

Check token:

```bash
kubeadm token list
```

Create new token:

```bash
kubeadm token create
```

---

## 4. `--discovery-token-ca-cert-hash  sha256:<hash>`

Example:

```bash
--discovery-token-ca-cert-hash sha256:abcd1234...
```

This is a security verification step.

Purpose:

* Confirms worker is connecting to the correct control plane
* Prevents MITM (Man-in-the-middle) attacks

# Run this command on the Kubernetes control plane: 

```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
openssl rsa -pubin -outform der 2>/dev/null | \
openssl dgst -sha256 -hex | sed 's/^.* //'
```

---

# Simple Understanding

Worker node asks:

> “How do I know this API server is genuine?”

Hash verifies:

* Control plane CA certificate fingerprint
* Secure trust establishment

---

# Visual Flow

```text
Worker Node
     |
     | kubeadm join
     |
     v
Control Plane API Server (6443)
     |
     | Token Authentication
     | CA Hash Verification
     |
     v
Node Registered in Cluster
```

---

# Real Example

```bash
kubeadm join 10.0.0.10:6443 \
--token q1w2e3.abcdef1234567890 \
--discovery-token-ca-cert-hash sha256:8c4f...
```

Meaning:

| Part             | Meaning                |
| ---------------- | ---------------------- |
| `10.0.0.10:6443` | Kubernetes API Server  |
| `token`          | Permission to join     |
| `sha256 hash`    | Verify trusted cluster |

---

# Where Do You Get This Command?

After running on master node:

```bash
kubeadm init
```

At the end, kubeadm automatically prints the join command.

```bash
kubeadm token create --print-join-command
```

Example output:

```bash
kubeadm join 192.168.1.10:6443 \
--token abcdef.1234567890abcdef \
--discovery-token-ca-cert-hash sha256:8c4f6d...
```

---

# Verify Node Joined

From control plane:

```bash
kubectl get nodes
```

Example:

```text
master-node   Ready
worker-node1  Ready
worker-node2  Ready
```

---

# Important Internal Actions During Join

When node joins:

* kubelet installed/configured
* certificates generated
* node registered in etcd
* CNI networking later connects pods
* scheduler can place workloads there


# Easy Analogy

| Kubernetes Concept | Real Life           |
| ------------------ | ------------------- |
| Control Plane      | Company HQ          |
| Worker Node        | Employee            |
| Token              | Joining invitation  |
| CA Hash            | ID verification     |
| kubeadm join       | Employee onboarding |

---

# kubeadm Workflow

```text
Install OS  -> Disable Swap(optional)
   ↓
Install container runtime
   ↓
Install kubeadm/kubelet/kubectl
   ↓
Initialize control plane
   ↓
Install CNI
   ↓
Join worker nodes
```

---

# 4. Managed Kubernetes

Managed Kubernetes means cloud providers manage:

* Control plane
* Upgrades
* High availability
* Security patches

You manage:

* Worker nodes
* Applications
* Networking policies
* Storage

---

# Amazon EKS

Amazon Elastic Kubernetes Service

## Features

| Feature          | Description         |
| ---------------- | ------------------- |
| AWS Integrated   | IAM, VPC, ELB       |
| HA Control Plane | Multi-AZ            |
| Managed Upgrades | AWS handles masters |
| Security         | IAM integration     |

---

# EKS Architecture

```text
AWS Managed Control Plane
           |
    ----------------
    |              |
Worker Nodes   Fargate
```

---

# Azure AKS

Azure Kubernetes Service

| Feature           | Description           |
| ----------------- | --------------------- |
| Azure Integration | Native Azure services |
| Auto Scaling      | Built-in              |
| AAD Integration   | Identity management   |
| Cost Efficient    | Managed masters       |

---

# Google GKE

Google Kubernetes Engine

| Feature             | Description          |
| ------------------- | -------------------- |
| Google Native       | Deep GCP integration |
| Autopilot Mode      | Fully managed        |
| Advanced Networking | Strong networking    |
| Auto Repair         | Self-healing nodes   |

---

# Managed Kubernetes Comparison

| Feature        | EKS     | AKS       | GKE       |
| -------------- | ------- | --------- | --------- |
| Cloud Provider | AWS     | Azure     | GCP       |
| Ease of Use    | Medium  | Easy      | Very Easy |
| Networking     | VPC CNI | Azure CNI | Native    |
| Pricing        | Higher  | Moderate  | Moderate  |
| Automation     | Good    | Good      | Excellent |

---

# 5. On-Prem Kubernetes (Bare Metal)

# What is Bare Metal Kubernetes?

Bare metal Kubernetes runs directly on physical servers without cloud providers.

Used for:

* Datacenters
* Private cloud
* Low latency workloads
* Regulatory compliance

---

# Bare Metal Architecture

```text
+-------------------+
| Physical Servers  |
+-------------------+
        |
+-------------------+
| Kubernetes Nodes  |
+-------------------+
```

---

# Common Bare Metal Tools

| Tool          | Purpose              |
| ------------- | -------------------- |
| kubeadm       | Cluster bootstrap    |
| MetalLB       | LoadBalancer support |
| NGINX Ingress | Ingress controller   |
| Ceph          | Storage              |
| Longhorn      | Persistent storage   |

---

# Bare Metal Challenges

| Challenge      | Description             |
| -------------- | ----------------------- |
| Networking     | Manual setup            |
| Load Balancing | No cloud LB             |
| Storage        | Must configure manually |
| HA Setup       | Complex                 |
| Monitoring     | Self-managed            |

---

# MetalLB

# What is MetalLB?

MetalLB provides LoadBalancer functionality for bare metal Kubernetes clusters.

---

# MetalLB Flow

```text
User Request
      ↓
External IP
      ↓
MetalLB
      ↓
Kubernetes Service
      ↓
Pods
```

---

# 6. HA Cluster Setup (Multi-Master)

# What is HA Kubernetes?

HA (High Availability) Kubernetes uses multiple control plane nodes to eliminate single point of failure.

---

# HA Architecture

```text
                 Load Balancer
                        |
        --------------------------------
        |              |               |
   Master-1       Master-2       Master-3
        |
   Worker Nodes
```

---

# HA Components

| Component          | Purpose                  |
| ------------------ | ------------------------ |
| Multiple Masters   | Redundancy               |
| Load Balancer      | API traffic distribution |
| External etcd      | Shared datastore         |
| Keepalived/HAProxy | VIP management           |

---

# HA Setup Methods

| Method        | Description         |
| ------------- | ------------------- |
| Stacked etcd  | etcd on masters     |
| External etcd | Separate etcd nodes |

---

# HA kubeadm Initialization

```bash
kubeadm init \
--control-plane-endpoint "LOADBALANCER_IP:6443" \
--upload-certs
```

---

# Add Additional Masters

```bash
kubeadm join <LB-IP>:6443 \
--control-plane \
--token <token>
```

---

# HA Advantages

| Advantage          | Description                     |
| ------------------ | ------------------------------- |
| No Single Failure  | Cluster survives master failure |
| Better Reliability | Production-ready                |
| Enterprise Grade   | Critical workloads              |

---

# 7. Cluster Upgrade

# Why Upgrade Kubernetes?

Upgrades provide:

* Security patches
* Bug fixes
* New features
* Better performance

---

# Upgrade Strategy

```text
Backup etcd
    ↓
Upgrade control plane
    ↓
Upgrade worker nodes
    ↓
Verify cluster health
```

---

# kubeadm Upgrade

# Check Upgrade Plan

```bash
kubeadm upgrade plan
```

---

# Upgrade Control Plane

```bash
sudo kubeadm upgrade apply v1.30.x
```

---

# Upgrade kubelet & kubectl

```bash
sudo apt install -y kubelet kubectl
```

Restart:

```bash
sudo systemctl restart kubelet
```

---

# Drain Worker Node

```bash
kubectl drain worker1 --ignore-daemonsets
```

---

# Uncordon Node

```bash
kubectl uncordon worker1
```

---

# Upgrade Best Practices

| Practice                   | Reason                  |
| -------------------------- | ----------------------- |
| Backup etcd first          | Recovery safety         |
| Upgrade one node at a time | Reduce downtime         |
| Test in staging            | Avoid production issues |
| Verify compatibility       | Prevent failures        |

---

# 8. Cluster Backup (etcd Backup)

# What is etcd?

etcd is Kubernetes’ distributed key-value database.

It stores:

* Cluster state
* Pods
* Secrets
* ConfigMaps
* Nodes
* Deployments

---

# etcd Architecture

```text
Kubernetes Components
          |
          ↓
        etcd
          |
   Cluster State Data
```

---

# Why Backup etcd?

| Reason              | Description         |
| ------------------- | ------------------- |
| Disaster Recovery   | Recover cluster     |
| Accidental Deletion | Restore resources   |
| Upgrade Safety      | Rollback capability |
| Data Protection     | Preserve state      |

---

# etcd Backup Command

```bash
ETCDCTL_API=3 etcdctl snapshot save backup.db \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key
```

---

# Verify Backup

```bash
etcdctl snapshot status backup.db
```

---

# Backup Best Practices

| Practice         | Description           |
| ---------------- | --------------------- |
| Automate backups | Use cron jobs         |
| Store remotely   | S3/NFS/object storage |
| Encrypt backups  | Protect secrets       |
| Regular testing  | Ensure restorability  |

---

# 9. Cluster Restore (Disaster Recovery)

# What is Disaster Recovery?

Disaster recovery restores Kubernetes after:

* Control plane failure
* etcd corruption
* Accidental deletion
* Datacenter outage

---

# Disaster Recovery Flow

```text
Failure Occurs
      ↓
Restore etcd snapshot
      ↓
Rebuild control plane
      ↓
Reconnect worker nodes
      ↓
Validate workloads
```

---

# Restore etcd Snapshot

```bash
ETCDCTL_API=3 etcdctl snapshot restore backup.db \
--data-dir=/var/lib/etcd-restore
```

---

# Update etcd Manifest

Edit:

```bash
/etc/kubernetes/manifests/etcd.yaml
```

Update:

```yaml
--data-dir=/var/lib/etcd-restore
```

---

# Disaster Recovery Best Practices

| Best Practice        | Purpose              |
| -------------------- | -------------------- |
| Frequent backups     | Reduce data loss     |
| Multi-region storage | Survive site failure |
| Test restores        | Ensure success       |
| Document procedures  | Faster recovery      |
| Monitor etcd health  | Prevent corruption   |

---

# Kubernetes Installation Learning Path

```text
Docker Basics
      ↓
Minikube
      ↓
Kind
      ↓
kubeadm
      ↓
Networking & Storage
      ↓
HA Clusters
      ↓
Managed Kubernetes
      ↓
Backup & Disaster Recovery
      ↓
Production Kubernetes
```

---

# Real-World Production Stack

| Layer      | Common Tools         |
| ---------- | -------------------- |
| Kubernetes | kubeadm/EKS/AKS/GKE  |
| Networking | Calico/Cilium        |
| Ingress    | NGINX                |
| Storage    | Ceph/Longhorn/EBS    |
| Monitoring | Prometheus + Grafana |
| Logging    | ELK/EFK              |
| CI/CD      | Jenkins/ArgoCD       |
| Security   | Falco/OPA/Kyverno    |

---

# Important Kubernetes Installation Concepts

| Concept           | Meaning                       |
| ----------------- | ----------------------------- |
| kubeadm           | Cluster bootstrap             |
| kubelet           | Node agent                    |
| kubectl           | CLI tool                      |
| CNI               | Container networking          |
| CRI               | Container runtime interface   |
| etcd              | Cluster database              |
| Control Plane     | Cluster brain                 |
| Worker Node       | Runs applications             |
| HA                | High availability             |
| Disaster Recovery | Restore cluster after failure |

---

# Recommended Practice Environment

| Level        | Recommended Tool        |
| ------------ | ----------------------- |
| Beginner     | Minikube                |
| Intermediate | Kind                    |
| Advanced     | kubeadm                 |
| Production   | EKS/AKS/GKE             |
| Enterprise   | HA kubeadm + Bare Metal |
