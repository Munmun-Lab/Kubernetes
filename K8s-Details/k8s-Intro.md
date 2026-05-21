# Introduction to Kubernetes — Complete Notes & Documentation

---

# What is Kubernetes?

## Definition

**Kubernetes (K8s)** is an open-source container orchestration platform used to:

* Deploy containers
* Manage containers
* Scale applications
* Automate operations
* Ensure high availability

It was originally developed by Google and is now maintained by Cloud Native Computing Foundation.

---

# Simple Understanding

Without Kubernetes:

```text
1 Server → Few Containers → Manual Management
```

With Kubernetes:

```text
Many Servers → Thousands of Containers → Automated Management
```

---

# Why Kubernetes?

| Feature               | Description                |
| --------------------- | -------------------------- |
| Automation            | Auto deployment & recovery |
| Scaling               | Auto scale applications    |
| High Availability     | Applications stay online   |
| Self-Healing          | Restart failed containers  |
| Load Balancing        | Distribute traffic         |
| Rolling Updates       | Update without downtime    |
| Portability           | Run anywhere               |
| Resource Optimization | Better CPU/RAM usage       |

---

# Real-World Problem Without Kubernetes

Imagine:

* 100 Docker containers
* Running on 20 servers
* One server crashes
* Traffic increases suddenly
* Application update needed

Manual management becomes difficult.

Kubernetes solves this automatically.

---

# Kubernetes History

## Evolution

```text
Traditional Deployment
        ↓
Virtual Machines
        ↓
Containers (Docker)
        ↓
Container Orchestration
        ↓
Kubernetes
```

---

# Google Borg → Kubernetes

| Technology | Description                        |
| ---------- | ---------------------------------- |
| Borg       | Internal Google container platform |
| Omega      | Improved version                   |
| Kubernetes | Open-source orchestration platform |

Google used Borg internally for years before Kubernetes.

---

# CNCF (Cloud Native Computing Foundation)

## What is CNCF?

Cloud Native Computing Foundation manages Kubernetes and other cloud-native tools.

---

# CNCF Popular Projects

| Tool       | Purpose                 |
| ---------- | ----------------------- |
| Kubernetes | Container orchestration |
| Prometheus | Monitoring              |
| Helm       | Package manager         |
| Envoy      | Proxy                   |
| Fluentd    | Logging                 |
| containerd | Container runtime       |
| ArgoCD     | GitOps                  |

---

# Kubernetes Architecture

## Main Architecture

```text
                    +----------------------+
                    |   Control Plane      |
                    |----------------------|
                    | API Server           |
                    | Scheduler            |
                    | Controller Manager   |
                    | etcd                 |
                    +----------+-----------+
                               |
              -----------------------------------
              |                |                |
      +-------+------+ +-------+------+ +-------+------+
      | Worker Node 1| | Worker Node 2| | Worker Node 3|
      |--------------| |--------------| |--------------|
      | kubelet      | | kubelet      | | kubelet      |
      | kube-proxy   | | kube-proxy   | | kube-proxy   |
      | Pods         | | Pods         | | Pods         |
      +--------------+ +--------------+ +--------------+
```

---

# Kubernetes Components

# 1. API Server

## Role

Main entry point of Kubernetes cluster.

All communication goes through API Server.

## Example

```bash
kubectl get pods
```

Command goes to API Server.

---

# 2. Scheduler

## Role

Decides:

```text
Which Pod runs on which Node
```

## Checks

* CPU
* Memory
* Node availability
* Affinity rules

---

# 3. Controller Manager

## Role

Maintains desired state.

Example:

```text
Desired Pods = 3
Current Pods = 2
```

Controller automatically creates 1 more Pod.

---

# 4. etcd

## Role

Key-value database storing cluster information.

Stores:

* Pods
* Nodes
* Secrets
* Configurations

---

# 5. kubelet

## Role

Agent running on worker node.

Responsibilities:

* Communicates with API server
* Runs containers
* Monitors Pods

---

# 6. kube-proxy

## Role

Handles networking and routing.

Provides:

* Service communication
* Load balancing

---

# Master Node vs Worker Node

| Master Node        | Worker Node       |
| ------------------ | ----------------- |
| Controls cluster   | Runs applications |
| API Server         | Pods              |
| Scheduler          | kubelet           |
| etcd               | kube-proxy        |
| Controller Manager | Container Runtime |

---

# Kubernetes Workflow

# Flowchart

```text
Developer
    ↓
kubectl command
    ↓
API Server
    ↓
Scheduler
    ↓
Worker Node Selected
    ↓
kubelet
    ↓
Container Runtime
    ↓
Pod Running
```

---

# Kubernetes Benefits

| Benefit      | Explanation                   |
| ------------ | ----------------------------- |
| Scalability  | Add/remove pods automatically |
| Self-Healing | Restart failed pods           |
| Portability  | Works on cloud/on-prem        |
| HA           | Multiple replicas             |
| Automation   | Less manual work              |
| Declarative  | YAML-based infrastructure     |

---

# Kubernetes vs Docker

| Kubernetes             | Docker              |
| ---------------------- | ------------------- |
| Orchestration platform | Container platform  |
| Manages clusters       | Creates containers  |
| Auto scaling           | No orchestration    |
| Self-healing           | Manual recovery     |
| Multi-node             | Single host focused |

---

# Relationship Between Docker & Kubernetes

```text
Docker → Creates Containers
Kubernetes → Manages Containers
```

---

# Kubernetes vs Docker Swarm

| Feature          | Kubernetes | Docker Swarm |
| ---------------- | ---------- | ------------ |
| Complexity       | High       | Simple       |
| Scalability      | Very High  | Medium       |
| Ecosystem        | Huge       | Smaller      |
| Enterprise Usage | Massive    | Limited      |
| Auto Scaling     | Advanced   | Basic        |
| Community        | Very Large | Smaller      |

---

# Kubernetes vs OpenShift

| Kubernetes            | OpenShift                |
| --------------------- | ------------------------ |
| Open-source           | Enterprise platform      |
| Requires manual setup | Ready-to-use             |
| Flexible              | Opinionated              |
| Community support     | Enterprise support       |
| Basic dashboard       | Advanced developer tools |

---

# Kubernetes Use Cases

# 1. Microservices

Example:

```text
Frontend
Backend
Database
Authentication
```

Each service runs in separate containers.

---

# 2. CI/CD

Integrates with:

* Jenkins
* GitHub Actions
* ArgoCD
* GitLab CI

---

# 3. Hybrid Cloud

Run workloads on:

* AWS
* Azure
* GCP
* On-Prem

---

# 4. Auto Scaling Applications

Example:

```text
Traffic increases
↓
Kubernetes creates more Pods
```

---

# 5. High Availability

If one node fails:

```text
Pods automatically move to healthy nodes
```

---

# Kubernetes Object Hierarchy

```text
Cluster
   ↓
Nodes
   ↓
Pods
   ↓
Containers
```

---

# Important Kubernetes Terminology

| Term       | Meaning                  |
| ---------- | ------------------------ |
| Cluster    | Group of nodes           |
| Node       | Server                   |
| Pod        | Smallest deployable unit |
| Container  | Application instance     |
| Deployment | Pod management           |
| Service    | Network access           |
| Namespace  | Logical separation       |
| Ingress    | External routing         |

---

# Kubernetes Installation Methods

| Method   | Usage                |
| -------- | -------------------- |
| Minikube | Local learning       |
| Kind     | Kubernetes in Docker |
| kubeadm  | Production setup     |
| EKS      | AWS managed          |
| AKS      | Azure managed        |
| GKE      | Google managed       |

---

# Install Minikube Example

## Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/stable/bin/linux/amd64/kubectl"

chmod +x kubectl

sudo mv kubectl /usr/local/bin/
```

---

# Install Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

---

# Start Cluster

```bash
minikube start
```

---

# Verify Cluster

```bash
kubectl get nodes
```

---

# First Kubernetes Example

# Create Deployment

```bash
kubectl create deployment nginx --image=nginx
```

---

# Check Pods

```bash
kubectl get pods
```

---

# Expose Deployment

```bash
kubectl expose deployment nginx --port=80 --type=NodePort
```

---

# View Services

```bash
kubectl get svc
```

---

# Scale Application

```bash
kubectl scale deployment nginx --replicas=3
```

---

# Check Scaling

```bash
kubectl get pods
```

---

# Kubernetes YAML Example

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx-deployment

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
      - name: nginx
        image: nginx:latest

        ports:
        - containerPort: 80
```

---

# Apply YAML

```bash
kubectl apply -f deployment.yaml
```

---

# Delete Deployment

```bash
kubectl delete deployment nginx
```

---

# Basic Kubernetes Commands

| Command                | Purpose           |
| ---------------------- | ----------------- |
| kubectl get pods       | List pods         |
| kubectl get nodes      | List nodes        |
| kubectl get svc        | List services     |
| kubectl describe pod   | Detailed pod info |
| kubectl logs           | View logs         |
| kubectl exec -it       | Access container  |
| kubectl apply -f       | Create resources  |
| kubectl delete -f      | Delete resources  |
| kubectl scale          | Scale app         |
| kubectl rollout status | Deployment status |

---

# Kubernetes Networking Flow

```text
User Request
     ↓
Service
     ↓
kube-proxy
     ↓
Pod
     ↓
Container
```

---

# Kubernetes Self-Healing Example

## Scenario

```text
Pod crashes
```

## Kubernetes Action

```text
Controller detects failure
↓
New Pod automatically created
```

---

# Kubernetes Rolling Update Flow

```text
Old Pod v1
      ↓
New Pod v2 Created
      ↓
Traffic Shifted
      ↓
Old Pod Removed
```

---

# Kubernetes Scaling Flow

```text
High Traffic
      ↓
HPA Detects CPU Usage
      ↓
More Pods Created
      ↓
Load Distributed
```

---

# Real Production Example

## E-Commerce Application

```text
Ingress
   ↓
Frontend Pods
   ↓
Backend API Pods
   ↓
Database
```

Features:

* Auto scaling
* High availability
* Monitoring
* Logging
* CI/CD

---

# Kubernetes Ecosystem

| Category     | Tools               |
| ------------ | ------------------- |
| Monitoring   | Prometheus, Grafana |
| Logging      | EFK, Loki           |
| GitOps       | ArgoCD              |
| Packaging    | Helm                |
| Service Mesh | Istio               |
| Security     | Falco, Kyverno      |

---

# Common Beginner Mistakes

| Mistake               | Solution           |
| --------------------- | ------------------ |
| Forgetting namespaces | Use `-n`           |
| Wrong labels          | Verify selectors   |
| Exposing wrong ports  | Check services     |
| No resource limits    | Add CPU/RAM limits |
| Ignoring logs         | Use `kubectl logs` |

---

# Best Practices

| Practice            | Why              |
| ------------------- | ---------------- |
| Use namespaces      | Isolation        |
| Use YAML            | Reusable configs |
| Set resource limits | Prevent overload |
| Use probes          | Health checks    |
| Use RBAC            | Security         |
| Use monitoring      | Visibility       |

---

# Kubernetes Learning Path

```text
Linux
  ↓
Docker
  ↓
YAML
  ↓
Kubernetes Basics
  ↓
Pods & Deployments
  ↓
Networking
  ↓
Storage
  ↓
Security
  ↓
Helm
  ↓
Monitoring
  ↓
Cloud Kubernetes
```

---

# Final Summary

Kubernetes is:

* A container orchestration platform
* Designed for automation
* Used for large-scale applications
* Core technology for DevOps & Cloud
* Widely used in:

  * Amazon Web Services
  * Microsoft
  * Google
  * VMware
  * Red Hat

