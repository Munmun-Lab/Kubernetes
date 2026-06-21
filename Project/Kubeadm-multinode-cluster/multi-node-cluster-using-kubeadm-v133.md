# Project: Install Multi-Node Kubernetes Cluster (1 Control Plane + 2 Workers) on AWS EC2 using kubeadm (Kubernetes v1.33)

## Kubernetes v1.33 Multi-Node Cluster Setup Using kubeadm on AWS EC2

This project covers:
- AWS VM Deployment
- Install Container Runtime
- Install kubeadm, kubelet, kubectl
- Initialize Kubernetes Cluster
- Join Worker Nodes
- Install Calico CNI
- Verify Cluster Health

### 1. AWS EC2 Setup

Create 3 Ubuntu 24.04 EC2 instances:

| Node    | Hostname    | Type      | OS           | IP Address | Node Type
| ------- | ----------- | --------- | ------------ | ---------- | ------------- |
| Master  | k8s-master  | t3.medium | Ubuntu 24.04 | 10.0.1.10  | Control Plane |
| Worker1 | k8s-worker1 | t3.medium | Ubuntu 24.04 | 10.0.1.11  | Worker Node   |
| Worker2 | k8s-worker2 | t3.medium | Ubuntu 24.04 | 10.0.1.12  | Worker Node   |


### Security Group Rules

#### Master Node

| Port       | Protocol | Purpose            |
| ---------- | -------- | ------------------ |
| 22         | TCP      | SSH                |
| 6443       | TCP      | Kubernetes API     |
| 2379-2380  | TCP      | etcd               |
| 10250      | TCP      | Kubelet            |
| 10257      | TCP      | Controller Manager |
| 10259      | TCP      | Scheduler          |
| 30000-32767| TCP      | NodePort Services  |
| 179        | TCP      | Calico BGP         |

#### Worker Nodes

| Port        | Protocol | Purpose           |
| ----------- | -------- | ----------------- |
| 22          | TCP      | SSH               |
| 10250       | TCP      | Kubelet           |
| 30000-32767 | TCP      | NodePort Services |
| 179         | TCP      | Calico BGP        |


### Connect to All Nodes

ssh -i mykey.pem ubuntu@<public-ip>

### Set Hostname

| Master  | sudo hostnamectl set-hostname k8s-master  |
| ------- | ----------------------------------------- |
| Worker1 | sudo hostnamectl set-hostname k8s-worker1 |
| ------- | ----------------------------------------- |
| Worker2 | sudo hostnamectl set-hostname k8s-worker2 |

### Update host file

Run on all nodes to update /etc/hosts file

sudo nano /etc/hosts

add: 
10.0.1.10 k8s-master
10.0.1.11 k8s-worker1
10.0.1.12 k8s-worker2


### Disable Source/Destination Check

For all EC2 instances:

```text
EC2 → Instances
→ Networking
→ Change Source/Destination Check
→ Disable
```

---

# 2. Disable Swap

Run on ALL nodes.

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

Verify:   free -h
Expected: Swap: 0B

---

# 3. Kernel Modules & Sysctl

## Load Required Modules

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

## Configure Sysctl - sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#Verify that the br_netfilter, overlay modules are loaded by running the following commands:
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1 in  sysctl config by running the following command:
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.ipv4.ip_forward
```

Expected: = 1

---

# 4. Install containerd (container runtime)

Run on ALL nodes.

```bash
# Download containerd:
curl -LO https://github.com/containerd/containerd/releases/download/v1.7.27/containerd-1.7.27-linux-amd64.tar.gz

# Extract:
sudo tar Cxzvf /usr/local containerd-1.7.27-linux-amd64.tar.gz

# Download service file:
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

# Create directory
sudo mkdir -p /usr/local/lib/systemd/system

# Move the containerd services to newly created directory
sudo mv containerd.service /usr/local/lib/systemd/system/

# Create config:
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Enable SystemdCgroup:
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml

# Start service:
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Verify that containerd service is up & running
systemctl status containerd
```

---

# 5. Install runc

Run on ALL nodes.

```bash
curl -LO https://github.com/opencontainers/runc/releases/download/v1.2.5/runc.amd64

sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Verify runc is running & version
runc --version
```

---

# 6. Install CNI Plugins

Run on ALL nodes.

```bash
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz

sudo mkdir -p /opt/cni/bin

sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.2.tgz

# Verify CNI get installed & Pod screated
ls /opt/cni/bin
```

---

# 7. Install kubeadm, kubelet and kubectl (v1.33)

Run on ALL nodes.

```bash
#I nstall prerequisites:
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Create keyring:
sudo mkdir -p /etc/apt/keyrings

# Add Kubernetes repository:
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' \
| sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install packages:
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Lock versions:
sudo apt-mark hold kubelet kubeadm kubectl

# Verify versions:
kubeadm version
kubelet --version
kubectl version --client
```

---

# 8. Configure crictl

Run on ALL nodes.

```bash
sudo crictl config runtime-endpoint unix:///run/containerd/containerd.sock

# Verify:
crictl info
```

---

# 9. Initialize Master

Run ONLY on Master Node.

```bash
# Get private IP:
hostname -I
# Example: 172.31.89.68

# Initialize cluster:
sudo kubeadm init \
--pod-network-cidr=192.168.0.0/16 \
--apiserver-advertise-address=172.31.89.68 \
--node-name=k8s-master

# Expected:
Your Kubernetes control-plane has initialized successfully

# Save the generated join command from console including the token
# Example:
kubeadm join 172.31.89.68:6443 \
--token xxxxx \
--discovery-token-ca-cert-hash sha256:xxxxx
```

---

# 10. Prepare & Configure kubeconfig

```bash
# Run on Master.
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify:
kubectl get nodes

# Expected:
k8s-master   NotReady

# k8s-master not ready, and this is normal before Calico installation.
```

---

# 11. Install Calico

```bash
# Install Tigera Operator:
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/tigera-operator.yaml

# Download custom resources:
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/custom-resources.yaml

# Apply:
kubectl apply -f custom-resources.yaml

# Verify:
kubectl get pods -A

> Wait until all Calico pods are Running.
```
---

### Perform the below steps on both the worker nodes

- Perform steps 1-8 on both the worker nodes

---

# 12. Join Worker Nodes

Run on BOTH worker nodes.

```bash
# Use the join command generated during initialization in step 9 on the Master node which is similar to below:
sudo kubeadm join 172.31.89.68:6443 \
--token xxxxx \
--discovery-token-ca-cert-hash sha256:xxxxx

# If lost:
kubeadm token create --print-join-command
```

---

# 13. Validation

Check nodes:

```bash
kubectl get nodes

# Expected:
NAME           STATUS   ROLES
k8s-master     Ready    control-plane
k8s-worker1    Ready    <none>
k8s-worker2    Ready    <none>
```

---

## Check System Pods

```bash
kubectl get pods -A

# Expected pods: All should be show Running
etcd
kube-apiserver
kube-controller-manager
kube-scheduler
coredns
calico-node
calico-kube-controllers
```

---

## Test Deployment

```bash
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3
kubectl get pods -o wide
```

We can see pods distributed across both worker nodes.

---

## Useful Verification Commands

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl cluster-info
kubectl get events -A
sudo systemctl status kubelet
sudo systemctl status containerd
crictl ps
```

### Final Expected Result

Cluster Name: Kubernetes v1.33

Control Plane: 1
Worker Nodes: 2

Runtime:
  - containerd
  - runc

Networking:
  - CNI Plugins
  - Calico

Status:
  - All Nodes Ready
  - All Pods Running



