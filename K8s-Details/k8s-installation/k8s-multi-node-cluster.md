# Kubernetes Multi-Node Cluster — Complete Guide

A **multi-node Kubernetes cluster** means Kubernetes runs across multiple servers (nodes) instead of a single machine.

This is the real production architecture used in:

* Cloud platforms
* Enterprises
* Data centers
* VMware environments
* Bare-metal deployments
* Hybrid cloud infrastructures

---

# 1. What is a Multi-Node Cluster?

A cluster contains:

| Component           | Purpose            |
| ------------------- | ------------------ |
| Control Plane Nodes | Manage the cluster |
| Worker Nodes        | Run applications   |
| Networking Layer    | Connect all nodes  |
| Storage Layer       | Persistent data    |
| Load Balancer       | HA API access      |

---

# Basic Architecture

```text id="p9pd4q"
                   Users / DevOps
                           |
                    kubectl / API
                           |
                  Load Balancer VIP
                           |
          -----------------------------------
          |                |               |
      Master-1         Master-2        Master-3
     Control Plane    Control Plane   Control Plane
          |                |               |
          -----------------------------------
                     etcd Cluster
                           |
    -------------------------------------------------
    |                     |                        |
 Worker-1             Worker-2                Worker-3
    |                     |                        |
  Pods                  Pods                     Pods
```

---

# 2. Why Multi-Node Cluster?

Single-node clusters are good for:

* Learning
* Testing
* Labs

But production requires:

| Requirement       | Why Multi-node Helps             |
| ----------------- | -------------------------------- |
| High Availability | One node failure won't stop apps |
| Scalability       | Add more worker nodes            |
| Fault Tolerance   | Workloads move automatically     |
| Load Distribution | Traffic spread across nodes      |
| Isolation         | Separate workloads               |

---

# 3. Node Types

---

# Control Plane Node

Manages cluster state.

Components:

| Component                | Purpose           |
| ------------------------ | ----------------- |
| kube-apiserver           | Main API          |
| etcd                     | Cluster database  |
| scheduler                | Assigns Pods      |
| controller-manager       | Desired state     |
| cloud-controller-manager | Cloud integration |

---

# Worker Node

Runs applications.

Components:

| Component         | Purpose         |
| ----------------- | --------------- |
| kubelet           | Node agent      |
| kube-proxy        | Networking      |
| Container Runtime | Runs containers |
| CNI Plugin        | Pod networking  |

---

# Worker Node Flow

```text id="1f4hvh"
Pod YAML
   |
API Server
   |
Scheduler
   |
Worker Node Selected
   |
kubelet
   |
Container Runtime
   |
Pod Running
```

---

# 4. Multi-Node Cluster Networking

All nodes communicate through CNI networking.

Requirements:

✅ Pod-to-Pod communication
✅ Cross-node routing
✅ DNS resolution
✅ Service discovery

---

# Cross Node Communication

```text id="zdfg80"
Pod A (Worker-1)
      |
   CNI Overlay
      |
Pod B (Worker-2)
```

---

# Common CNIs

| CNI     | Production Usage         |
| ------- | ------------------------ |
| Calico  | Most common              |
| Cilium  | eBPF advanced networking |
| Flannel | Simple labs              |
| Antrea  | Enterprise               |

---

# 5. Multi-Master (HA) Architecture

Production clusters usually use:

* 3 control plane nodes
* Odd number for etcd quorum

---

# HA Architecture

```text id="lg19ow"
              Load Balancer
                     |
     ---------------------------------
     |               |               |
 Control-1      Control-2       Control-3
     |               |               |
     -----------etcd quorum----------
```

---

# Why 3 Masters?

etcd uses quorum.

Formula:

Quorum = \lfloor \frac{n}{2} \rfloor + 1

Examples:

| Masters | Needed Quorum |
| ------- | ------------- |
| 1       | 1             |
| 3       | 2             |
| 5       | 3             |

---

# 6. Cluster Installation Methods

| Method       | Usage         |
| ------------ | ------------- |
| kubeadm      | Most common   |
| kops         | AWS           |
| Rancher RKE2 | Enterprise    |
| OpenShift    | Red Hat       |
| EKS/AKS/GKE  | Managed       |
| Kubespray    | Ansible-based |

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

# 22. Production Networking

Production usually includes:

| Component          | Purpose           |
| ------------------ | ----------------- |
| Ingress Controller | External traffic  |
| Load Balancer      | HA access         |
| Network Policies   | Security          |
| DNS                | Service discovery |
| Monitoring         | Observability     |

---

# 23. Storage in Multi-Node Cluster

Need distributed storage.

Options:

| Storage    | Usage             |
| ---------- | ----------------- |
| NFS        | Simple            |
| Longhorn   | Kubernetes-native |
| Ceph       | Enterprise        |
| EBS        | AWS               |
| Azure Disk | Azure             |

---

# 24. Cluster Scaling

---

# Add Worker Node

```bash
kubeadm join ...
```

---

# Remove Node

```bash
kubectl drain worker-1 --ignore-daemonsets

kubectl delete node worker-1
```

---

# 25. Upgrade Multi-Node Cluster

Order:

```text id="a1pjsa"
1. Control Plane
2. Worker Nodes
3. CNI
4. Addons
```

---

# Upgrade Flow

```text id="ptm8gd"
Drain Node
   |
Upgrade kubeadm
   |
Upgrade kubelet
   |
Restart Services
   |
Uncordon Node
```

---

# 26. Backup & Disaster Recovery

Most critical:

* etcd backup

---

# etcd Backup

```bash
ETCDCTL_API=3 etcdctl snapshot save backup.db
```

---

# Restore

```bash
etcdctl snapshot restore backup.db
```

---

# 27. Security Best Practices

| Practice            | Reason               |
| ------------------- | -------------------- |
| Use RBAC            | Access control       |
| Encrypt etcd        | Protect secrets      |
| Use NetworkPolicies | Restrict traffic     |
| Use TLS everywhere  | Secure communication |
| Regular upgrades    | Security patches     |

---

# 28. Monitoring Multi-Node Cluster

Common stack:

| Tool         | Purpose    |
| ------------ | ---------- |
| Prometheus   | Metrics    |
| Grafana      | Dashboards |
| Loki         | Logs       |
| Alertmanager | Alerts     |

---

# 29. Real Production Architecture

```text id="y0d8ly"
                 Internet
                     |
              Cloud Load Balancer
                     |
              NGINX Ingress
                     |
       --------------------------------
       |                              |
   Frontend Service             Backend Service
       |                              |
   Frontend Pods                 Backend Pods
       |                              |
   Worker Nodes                 Worker Nodes
                     |
                Stateful DB
```

---

# 30. Common Troubleshooting

---

# Node Not Ready

Check:

```bash
systemctl status kubelet
```

---

# Pod Pending

Possible:

* No resources
* Taints
* Storage issues

---

# CNI Failure

Check:

```bash
kubectl get pods -n kube-system
```

Look for:

* calico
* flannel
* cilium

---

# DNS Failure

Test:

```bash
nslookup kubernetes.default
```

---

# 31. Important Commands

---

# Cluster Info

```bash
kubectl cluster-info
```

---

# Node Details

```bash
kubectl describe node worker-1
```

---

# Resource Usage

```bash
kubectl top nodes
```

---

# Drain Node

```bash
kubectl drain worker-1 --ignore-daemonsets
```

---

# Uncordon

```bash
kubectl uncordon worker-1
```

---

# 32. Interview Questions

## Beginner

* Difference between master and worker?
* What is kubelet?
* Why disable swap?

---

## Intermediate

* How worker joins cluster?
* How scheduler selects nodes?
* How CNI works?

---

## Advanced

* Explain HA control plane
* Explain etcd quorum
* Difference between Calico and Cilium
* Explain cluster upgrade strategy

