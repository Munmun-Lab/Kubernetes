# Kubernetes Cluster Architecture

## 📌 What is Kubernetes Cluster Architecture?

A Kubernetes cluster is a group of machines (nodes) working together to run containerized applications.

It consists of:

| Component        | Purpose                          |
| ---------------- | -------------------------------- |
| Control Plane    | Brain of Kubernetes              |
| Worker Nodes     | Run application containers       |
| Networking Layer | Communication between components |
| Storage Layer    | Persistent storage management    |

---

# High-Level Kubernetes Architecture

```text
                    +----------------------------------+
                    |         Control Plane            |
                    |----------------------------------|
                    | kube-apiserver                  |
                    | kube-scheduler                  |
                    | kube-controller-manager         |
                    | etcd                            |
                    +----------------------------------+
                               |
                               |
                    --------------------------------
                    |                              |
          +-------------------+         +-------------------+
          |    Worker Node 1  |         |   Worker Node 2   |
          |-------------------|         |-------------------|
          | kubelet           |         | kubelet           |
          | kube-proxy        |         | kube-proxy        |
          | Container Runtime |         | Container Runtime |
          | Pods              |         | Pods              |
          +-------------------+         +-------------------+
```

---

# Kubernetes Cluster Components

| Layer           | Components                                      |
| --------------- | ----------------------------------------------- |
| Control Plane   | API Server, Scheduler, Controller Manager, etcd |
| Node Components | kubelet, kube-proxy, Container Runtime          |
| Extensions      | CNI, CSI, CRI                                   |
| Workloads       | Pods, Deployments, Services                     |

---

# 1️⃣ Control Plane

## 📌 Definition

The Control Plane manages the entire Kubernetes cluster.

It makes decisions like:

* Where pods run
* Maintaining desired state
* Scaling
* Monitoring node health

---

# Control Plane Components

| Component               | Role                 |
| ----------------------- | -------------------- |
| kube-apiserver          | Main entry point     |
| kube-scheduler          | Selects node for pod |
| kube-controller-manager | Runs controllers     |
| etcd                    | Stores cluster state |

---

# Control Plane Flow

```text
User --> kubectl --> kube-apiserver
                         |
                         v
                  kube-scheduler
                         |
                         v
                 Worker Node Selected
                         |
                         v
                    kubelet
                         |
                         v
                    Pod Created
```

---

# 2️⃣ kube-apiserver

## 📌 Definition

The API Server is the heart of Kubernetes.

All communication goes through it.

---

## Responsibilities

| Function              | Description             |
| --------------------- | ----------------------- |
| Authentication        | Verifies users          |
| Authorization         | RBAC checks             |
| API Handling          | Accepts REST requests   |
| Cluster Communication | Connects all components |

---

## Example

```bash
kubectl get pods
```

This command talks to:

```text
kubectl --> kube-apiserver
```

---

## Common Ports

| Port | Usage          |
| ---- | -------------- |
| 6443 | Kubernetes API |

---

# 3️⃣ kube-scheduler

## 📌 Definition

The Scheduler decides:

> Which worker node should run a pod.

---

## Scheduling Factors

| Factor             | Description         |
| ------------------ | ------------------- |
| CPU availability   | Resource check      |
| Memory             | Free RAM            |
| Affinity Rules     | Pod placement       |
| Taints/Tolerations | Special node rules  |
| Node Labels        | Targeted scheduling |

---

## Scheduler Workflow

```text
Pod Created
    |
    v
Scheduler Checks:
- CPU
- Memory
- Policies
    |
    v
Best Node Selected
```

---

## Example

```yaml
nodeSelector:
  disktype: ssd
```

Scheduler places pod on SSD node.

---

# 4️⃣ kube-controller-manager

## 📌 Definition

Runs background controllers.

Controllers continuously compare:

```text
Desired State vs Actual State
```

---

# Important Controllers

| Controller             | Function           |
| ---------------------- | ------------------ |
| Deployment Controller  | Maintains replicas |
| Node Controller        | Checks node health |
| Replication Controller | Ensures pod count  |
| Endpoint Controller    | Service endpoints  |

---

## Example

If deployment requires:

```text
3 Pods
```

But only:

```text
2 Pods Running
```

Controller creates:

```text
1 Additional Pod
```

---

# 5️⃣ etcd

## 📌 Definition

Distributed key-value database.

Stores entire cluster state.

---

# Stores Information About

| Data        | Example        |
| ----------- | -------------- |
| Pods        | Pod configs    |
| Secrets     | Credentials    |
| Nodes       | Cluster nodes  |
| ConfigMaps  | Configurations |
| Deployments | Desired state  |

---

# Important Notes

| Point              | Details                    |
| ------------------ | -------------------------- |
| Critical Component | Cluster fails without etcd |
| Consistency        | Strong consistency         |
| Backup Required    | Very important             |

---

## etcd Architecture

```text
+----------------+
|     etcd       |
|----------------|
| Cluster State  |
| Configurations |
| Secrets        |
+----------------+
```

---

# 6️⃣ Worker Node

## 📌 Definition

Worker Nodes run application workloads.

---

# Worker Node Components

| Component         | Role            |
| ----------------- | --------------- |
| kubelet           | Node agent      |
| kube-proxy        | Networking      |
| Container Runtime | Runs containers |
| Pods              | Applications    |

---

# Worker Node Architecture

```text
+--------------------------------+
|          Worker Node           |
|--------------------------------|
| kubelet                        |
| kube-proxy                     |
| Container Runtime              |
|--------------------------------|
| Pod A                          |
| Pod B                          |
+--------------------------------+
```

---

# 7️⃣ kubelet

## 📌 Definition

Agent running on every node.

Communicates with Control Plane.

---

# Responsibilities

| Task           | Description        |
| -------------- | ------------------ |
| Pod Creation   | Starts containers  |
| Health Checks  | Monitors pods      |
| Reports Status | Sends node updates |
| Volume Mounts  | Attaches storage   |

---

# kubelet Workflow

```text
API Server Sends Pod Spec
          |
          v
      kubelet
          |
          v
 Container Runtime
          |
          v
    Pod Running
```

---

# kubelet Commands

## Check kubelet status

```bash
systemctl status kubelet
```

---

## Restart kubelet

```bash
sudo systemctl restart kubelet
```

---

# 8️⃣ kube-proxy

## 📌 Definition

Handles Kubernetes networking.

Provides Service networking and load balancing.

---

# Responsibilities

| Function       | Description           |
| -------------- | --------------------- |
| Service IPs    | Virtual IP management |
| Load Balancing | Traffic distribution  |
| Network Rules  | iptables/ipvs         |

---

# kube-proxy Flow

```text
User Request
      |
      v
 Kubernetes Service
      |
      v
 kube-proxy
      |
      v
 Pod Selected
```

---

# Proxy Modes

| Mode     | Description      |
| -------- | ---------------- |
| iptables | Default          |
| IPVS     | High performance |

---

# 9️⃣ CRI — Container Runtime Interface

## 📌 Definition

Standard interface between Kubernetes and container runtime.

---

# Supported Runtimes

| Runtime           | Description          |
| ----------------- | -------------------- |
| containerd        | Most popular         |
| CRI-O             | Kubernetes optimized |
| Docker Shim (old) | Deprecated           |

---

# CRI Architecture

```text
Kubernetes
    |
    v
   CRI
    |
    v
Container Runtime
    |
    v
Containers
```

---

# Check Runtime

```bash
crictl info
```

---

# 🔟 CNI — Container Network Interface

## 📌 Definition

Provides pod networking.

Allows pods to communicate.

---

# Popular CNI Plugins

| Plugin  | Description     |
| ------- | --------------- |
| Calico  | Network policy  |
| Flannel | Simple overlay  |
| Cilium  | eBPF networking |
| Weave   | Easy setup      |

---

# CNI Workflow

```text
Pod Created
    |
    v
CNI Plugin Assigns:
- IP Address
- Routes
- Networking Rules
```

---

# Check CNI

```bash
kubectl get pods -n kube-system
```

Look for:

```text
calico
flannel
cilium
```

---

# 1️⃣1️⃣ CSI — Container Storage Interface

## 📌 Definition

Standard storage interface for Kubernetes.

Allows external storage integration.

---

# Storage Examples

| Storage     | Example       |
| ----------- | ------------- |
| Cloud       | AWS EBS       |
| SAN         | Fibre Channel |
| NAS         | NFS           |
| Distributed | Ceph          |

---

# CSI Architecture

```text
Kubernetes
    |
    v
   CSI
    |
    v
Storage Driver
    |
    v
Persistent Volume
```

---

# Persistent Storage Flow

```text
Pod
 |
 v
PVC (PersistentVolumeClaim)
 |
 v
PV (PersistentVolume)
 |
 v
Storage Backend
```

---

# Important Kubernetes Objects

| Object     | Purpose                  |
| ---------- | ------------------------ |
| Pod        | Smallest deployable unit |
| Deployment | Pod management           |
| Service    | Networking               |
| ConfigMap  | Configuration            |
| Secret     | Sensitive data           |
| Namespace  | Isolation                |

---

# Complete Kubernetes Request Flow

```text
1. User creates Deployment
        |
        v
2. kube-apiserver receives request
        |
        v
3. etcd stores desired state
        |
        v
4. Scheduler selects node
        |
        v
5. kubelet receives instruction
        |
        v
6. Container Runtime starts container
        |
        v
7. CNI assigns networking
        |
        v
8. CSI attaches storage
        |
        v
9. kube-proxy exposes networking
        |
        v
10. Application Running
```

---

# Kubernetes Networking Model

## Rules

| Rule              | Meaning              |
| ----------------- | -------------------- |
| Pod-to-Pod        | Direct communication |
| Node-to-Pod       | Allowed              |
| Service-to-Pod    | Load balanced        |
| Every Pod Gets IP | Unique IP            |

---

# Important Ports

| Component          | Port      |
| ------------------ | --------- |
| kube-apiserver     | 6443      |
| etcd               | 2379-2380 |
| kubelet            | 10250     |
| kube-scheduler     | 10259     |
| controller-manager | 10257     |

---

# Important kubectl Commands

## Cluster Info

```bash
kubectl cluster-info
```

---

## Nodes

```bash
kubectl get nodes
```

---

## Pods

```bash
kubectl get pods -A
```

---

## Describe Node

```bash
kubectl describe node <node-name>
```

---

## View System Pods

```bash
kubectl get pods -n kube-system
```

---

## Check Component Status

```bash
kubectl get componentstatus
```

---

# Kubernetes Architecture Summary Table

| Component          | Purpose              |
| ------------------ | -------------------- |
| kube-apiserver     | API entry point      |
| kube-scheduler     | Pod placement        |
| controller-manager | Maintains state      |
| etcd               | Cluster database     |
| kubelet            | Node agent           |
| kube-proxy         | Networking           |
| CRI                | Runtime interface    |
| CNI                | Networking interface |
| CSI                | Storage interface    |

---

# Real-World Kubernetes Example

## Scenario

Deploy:

```text
Nginx Application with 3 replicas
```

---

## Workflow

```text
kubectl apply -f deployment.yaml
        |
        v
API Server receives request
        |
        v
etcd stores deployment config
        |
        v
Scheduler selects worker nodes
        |
        v
kubelet starts containers
        |
        v
CNI assigns IPs
        |
        v
kube-proxy exposes service
        |
        v
Application accessible
```

https://images.openai.com/static-rsc-4/3kD6rxLuX4avmcFxE7GX2RnUmhxt9fk8pkL_w-FwmCo2oAX4nQrpfr_QJMpBe_eD6-9A8x2qNxdPXL8_I4tX7ge521eyGGZtt-WJsFYyixucbU6VHQWeEzjfzC6S7AlEmfKZv8oihSDv3nfS0koe5ZHvBeINmj-Vg8zj1QBtctE?purpose=inline

---

# Architecture Design Best Practices

| Best Practice         | Reason                     |
| --------------------- | -------------------------- |
| HA Control Plane      | Avoid single point failure |
| Backup etcd           | Disaster recovery          |
| Use CNI Policies      | Security                   |
| Monitor kubelet       | Node health                |
| Use CSI Storage       | Persistent data            |
| Separate Worker Pools | Workload isolation         |

---

# Production Cluster Architecture

```text
                Load Balancer
                       |
         --------------------------------
         |              |               |
   Control Plane1  Control Plane2  Control Plane3
         |              |               |
                 etcd Cluster
                       |
        ---------------------------------
        |               |               |
     Worker1         Worker2         Worker3
```

---

# Key Interview Questions

| Question                        | Short Answer             |
| ------------------------------- | ------------------------ |
| What is Control Plane?          | Cluster management layer |
| What is kubelet?                | Node agent               |
| What is etcd?                   | Cluster database         |
| Difference between CNI and CSI? | Networking vs Storage    |
| What is CRI?                    | Runtime interface        |
| Role of kube-proxy?             | Service networking       |

---

# Final Kubernetes Architecture Flow

```text
kubectl
   |
   v
API Server
   |
   +--> etcd
   |
   +--> Scheduler
   |
   +--> Controller Manager
   |
   v
Worker Nodes
   |
   +--> kubelet
   +--> kube-proxy
   +--> CRI Runtime
   +--> Pods
```
