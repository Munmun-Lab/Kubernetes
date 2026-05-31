# Static Pods & Manual Scheduling in Kubernetes

These are two special concepts that bypass normal Kubernetes scheduling behavior.

---

# 1. Static Pods

## What is a Static Pod?

A Static Pod is a pod that is **created and managed directly by kubelet** on a node.

Normally:

```text
kubectl apply
      ↓
API Server
      ↓
Scheduler
      ↓
Node
      ↓
Pod Runs
```

Static Pod:

```text
Manifest File
(/etc/kubernetes/manifests)
         ↓
      Kubelet
         ↓
       Pod
```

No scheduler involved.

No deployment involved.

No replica set involved.

---

## How Static Pods Work

Kubelet continuously watches:

```bash
/etc/kubernetes/manifests/
```

Whenever a YAML file is added:

```text
nginx-static.yaml
       ↓
Kubelet detects it
       ↓
Creates container
       ↓
Pod starts
```

If YAML file is removed:

```text
Delete YAML
      ↓
Kubelet detects change
      ↓
Pod removed
```

---

## Real-Time Example

Login to control plane node:

```bash
sudo vi /etc/kubernetes/manifests/nginx-static.yaml
```

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: nginx-static

spec:
  containers:
  - name: nginx
    image: nginx
```

Save file.

Kubelet automatically creates pod.

Check:

```bash
kubectl get pods -A
```

Output:

```text
nginx-static-controlplane
```

---

## Where Are Static Pods Used?

### Kubernetes Control Plane

When you run:

```bash
kubeadm init
```

These files are created:

```bash
/etc/kubernetes/manifests/
```

```text
etcd.yaml

kube-apiserver.yaml

kube-controller-manager.yaml

kube-scheduler.yaml
```

Kubelet starts them as Static Pods.

---

## Why Static Pods?

Imagine API Server is down.

Can Scheduler create API Server Pod?

No.

Because Scheduler itself needs API Server.

Chicken-and-egg problem.

Solution:

```text
Node boots
      ↓
Kubelet starts
      ↓
Reads manifest
      ↓
Starts API Server
      ↓
Cluster becomes operational
```

---

## Static Pod Characteristics

| Feature             | Static Pod                |
| ------------------- | ------------------------- |
| Created by          | Kubelet                   |
| Managed by          | Kubelet                   |
| Scheduler used      | No                        |
| API Server required | No                        |
| Stored in etcd      | No                        |
| Manifest location   | /etc/kubernetes/manifests |
| Common use          | Control Plane             |

---

### Before Cluster Creation

When you install Kubernetes packages on a server, **kubelet is installed as a system service** and starts running before the cluster is fully operational.

```text
OS Boot
   ↓
systemd
   ↓
kubelet service starts
```

Check it:

```bash
systemctl status kubelet
```

---

### During `kubeadm init`

When you run:

```bash
kubeadm init
```

kubeadm does **not** create the control plane itself.

Instead, it:

1. Generates certificates
2. Generates configuration files
3. Creates Static Pod manifests

```text
/etc/kubernetes/manifests/
 ├─ kube-apiserver.yaml
 ├─ kube-scheduler.yaml
 ├─ kube-controller-manager.yaml
 └─ etcd.yaml
```

---

### Then Kubelet Takes Over

Kubelet is already running and watching:

```text
/etc/kubernetes/manifests/
```

When kubelet sees these files:

```text
kube-apiserver.yaml
kube-scheduler.yaml
...
```

it asks the container runtime (containerd/CRI-O) to start the containers.

```text
kubelet
   ↓
containerd
   ↓
Container Created
   ↓
Static Pod Running
```

---

### Complete Flow

```text
Install Kubernetes
       ↓
kubelet service starts
       ↓
kubeadm init
       ↓
Creates static pod YAML files
       ↓
/etc/kubernetes/manifests/
       ↓
kubelet detects files
       ↓
Starts etcd
       ↓
Starts API Server
       ↓
Starts Controller Manager
       ↓
Starts Scheduler
       ↓
Control Plane Ready
```

### Key Point

**kubelet exists before the cluster exists.**

Think of kubelet as the "caretaker" of the node:

```text
Server Starts
     ↓
Kubelet Starts
     ↓
Kubelet creates Control Plane Pods
     ↓
Cluster becomes available
```

### Easy Analogy

Imagine building a house:

```text
kubelet = Construction worker
kubeadm = Architect
Manifest files = Blueprint
Control Plane Pods = House
```

The architect (`kubeadm`) creates the blueprint (`*.yaml` files), but the worker (`kubelet`) actually builds and runs the house (control plane containers).
