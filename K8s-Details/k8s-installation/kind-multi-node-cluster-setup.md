# Create KIND Multi-Node Kubernetes Cluster (Short Steps)

KIND = Kubernetes IN Docker
It runs Kubernetes clusters using Docker containers.

---

# 1. Install Docker

Verify:

```bash
docker --version
```

Official site: [Docker](https://www.docker.com/?utm_source=chatgpt.com)

---

# 2. Install KIND

Official site: [KIND](https://kind.sigs.k8s.io/?utm_source=chatgpt.com)

## macOS

```bash
brew install kind
```

## Linux

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64

chmod +x ./kind

sudo mv ./kind /usr/local/bin/kind
```

Verify:

```bash
kind --version
```

---

# 3. Install kubectl

Official site: [kubectl Install Guide](https://kubernetes.io/docs/tasks/tools/?utm_source=chatgpt.com)

Verify:

```bash
kubectl version --client
```

---

# 4. Create Multi-Node Cluster Config

Create file:

```bash
vim kind-multi-node.yaml
```

Add:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
- role: worker
- role: worker
```

---

# 5. Create Cluster

```bash
kind create cluster --name multi-node-cluster --config kind-multi-node.yaml
```

---

# 6. Verify Cluster

## Check Nodes

```bash
kubectl get nodes
```

Expected:

```text
NAME                                STATUS   ROLES
multi-node-cluster-control-plane    Ready    control-plane
multi-node-cluster-worker           Ready    worker
multi-node-cluster-worker2          Ready    worker
```

---

# 7. Check Docker Containers

```bash
docker ps
```

You will see Kubernetes nodes running as Docker containers.

---

# 8. Deploy Test App

```bash
kubectl create deployment nginx --image=nginx
```

Scale:

```bash
kubectl scale deployment nginx --replicas=3
```

Check Pods:

```bash
kubectl get pods -o wide
```

You’ll see Pods distributed across worker nodes.

---

# 9. Delete Cluster

```bash
kind delete cluster --name multi-node-cluster
```

---

# Simple Architecture

```text
Docker Host
   |
---------------------------------
|              |               |
Control Plane  Worker-1      Worker-2
```

---

# Useful KIND Commands

## List Clusters

```bash
kind get clusters
```

## Export kubeconfig

```bash
kind export kubeconfig --name multi-node-cluster
```

## Load Local Docker Image

```bash
kind load docker-image myapp:v1 --name multi-node-cluster
```

---

# Production Note

KIND is mainly for:

* Learning
* Testing
* CI/CD pipelines
* Local Kubernetes labs

Not recommended for production workloads.
