# 7. kubeadm Multi-Node Cluster Setup

Most important for interviews + labs.

---

# Lab Example

| Node     | IP           |
| -------- | ------------ |
| master-1 | 192.168.1.10 |
| worker-1 | 192.168.1.11 |
| worker-2 | 192.168.1.12 |

---

# Minimum Requirements

| Resource | Recommendation     |
| -------- | ------------------ |
| CPU      | 2+                 |
| RAM      | 2–4 GB             |
| OS       | Ubuntu/RHEL        |
| Swap     | Disabled           |
| Network  | Open communication |

---

# 8. Common Ports

| Port        | Purpose    |
| ----------- | ---------- |
| 6443        | API Server |
| 2379-2380   | etcd       |
| 10250       | kubelet    |
| 30000-32767 | NodePort   |

---

# 9. Pre-Installation Steps

## Disable Swap

```bash
sudo swapoff -a
```

Permanent:

```bash
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

---

# Enable Kernel Modules

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

---

# Sysctl Settings

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
```

Apply:

```bash
sudo sysctl --system
```

---

# 10. Install Container Runtime

Usually:

* containerd
* CRI-O

---

# Install containerd

```bash
sudo apt install -y containerd
```

Configure:

```bash
containerd config default | sudo tee /etc/containerd/config.toml
```

Restart:

```bash
sudo systemctl restart containerd
```

---

# 11. Install Kubernetes Packages

```bash
sudo apt install -y kubeadm kubelet kubectl
```

Hold versions:

```bash
sudo apt-mark hold kubeadm kubelet kubectl
```

---

# 12. Initialize Control Plane

```bash
sudo kubeadm init \
--pod-network-cidr=10.244.0.0/16
```

---

# After Initialization

Setup kubectl:

```bash
mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

# 13. Install CNI Plugin

Example Flannel:

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

Or Calico:

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
```

---

# 14. Join Worker Nodes

Master generates join command:

```bash
kubeadm token create --print-join-command
```

Run on workers:

```bash
sudo kubeadm join ...
```

---

# Worker Join Flow

```text id="a8t4j3"
Worker Node
    |
Join Token
    |
API Server Authentication
    |
Certificates Issued
    |
Node Registered
```

---

# 15. Verify Cluster

## Nodes

```bash
kubectl get nodes
```

Expected:

```text id="5grg4u"
master-1   Ready
worker-1   Ready
worker-2   Ready
```

---

# Check Pods

```bash
kubectl get pods -A
```

---

# 16. How Scheduling Works

Scheduler selects node based on:

| Factor   | Example             |
| -------- | ------------------- |
| CPU      | Available resources |
| Memory   | Free RAM            |
| Taints   | Restrictions        |
| Affinity | Placement rules     |
| Labels   | Target nodes        |

---

# Scheduling Flow

```text id="n2h5eh"
Pod Created
    |
Scheduler Checks Nodes
    |
Best Node Selected
    |
kubelet Starts Pod
```

---

# 17. Pod Distribution Across Nodes

```text id="7o7r35"
Worker-1
   |- Pod A
   |- Pod B

Worker-2
   |- Pod C
   |- Pod D
```

---

# 18. Node Failure Scenario

If Worker-1 fails:

```text id="yifm3m"
Worker-1 DOWN
      |
Pods become unavailable
      |
Controller detects failure
      |
Pods recreated on Worker-2
```

---

# 19. Important Multi-Node Concepts

---

# Node Labels

```bash
kubectl label nodes worker-1 env=prod
```

---

# Taints

Prevent scheduling.

```bash
kubectl taint nodes worker-1 dedicated=db:NoSchedule
```

---

# Tolerations

Allow Pods onto tainted nodes.

---

# Node Affinity

Control Pod placement.

---

# 20. High Availability Control Plane

Production clusters use:

| Component          | HA Method            |
| ------------------ | -------------------- |
| API Server         | Load balancer        |
| etcd               | Multi-member cluster |
| Scheduler          | Active leader        |
| Controller Manager | Leader election      |

---

# 21. etcd in Multi-Node Cluster

etcd stores:

* Pods
* Services
* Secrets
* ConfigMaps
* Cluster state

---

# etcd HA Rules

Always use odd numbers:

✅ 1
✅ 3
✅ 5

Avoid:

❌ 2
❌ 4

---

# etcd Failure Example

```text id="1n0e86"
3-member etcd
     |
1 node fails
     |
2 remain
     |
Cluster still works
```

---
