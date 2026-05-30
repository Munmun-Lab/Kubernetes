In Kubernetes, a **Namespace** is a logical partition inside a cluster that helps organize and isolate resources.

Think of a Kubernetes cluster as a large office building:

* **Cluster** = Entire building
* **Namespace** = Different departments/floors (HR, Finance, IT)
* **Pods, Services, Deployments** = Employees and equipment inside each department

---

## Why Use Namespaces?

### 1. Resource Organization

Separate applications and teams.

Example:

```text
dev
test
staging
prod
```

### 2. Resource Isolation

Resources in one namespace are separate from another namespace.

Example:

```text
dev/nginx-pod
prod/nginx-pod
```

Both pods can have the same name because they are in different namespaces.

### 3. Access Control

Using RBAC, you can allow users to access only specific namespaces.

Example:

```text
Developer → dev namespace
Admin → all namespaces
```

### 4. Resource Quotas

Limit CPU, Memory, and Storage per namespace.

---

## Default Namespaces

Run:

```bash
kubectl get ns
```

Typical output:

```text
default
kube-system
kube-public
kube-node-lease
```

### default

User applications go here if no namespace is specified.

### kube-system

Contains Kubernetes system components.

Examples:

* CoreDNS
* kube-proxy
* metrics-server

### kube-public

Publicly readable resources.

### kube-node-lease

Stores node heartbeat information.

---

## Create Namespace

```bash
kubectl create namespace dev
```

Verify:

```bash
kubectl get ns
```

---

## Deploy Pod in Namespace

```bash
kubectl run nginx \
--image=nginx \
-n dev
```

View pods:

```bash
kubectl get pods -n dev
```

---

## Namespace YAML

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

Create:

```bash
kubectl apply -f namespace.yaml
```

---

## Get Resources from All Namespaces

```bash
kubectl get pods -A
```

or

```bash
kubectl get pods --all-namespaces
```

Example:

```text
NAMESPACE      NAME
default        my-app
dev            nginx
kube-system    coredns
```

---

## Set Default Namespace for Current Context

Check current context:

```bash
kubectl config current-context
```

Set namespace:

```bash
kubectl config set-context --current --namespace=dev
```

Verify:

```bash
kubectl config view --minify | grep namespace
```

Now you can run:

```bash
kubectl get pods
```

instead of:

```bash
kubectl get pods -n dev
```

---

## Delete Namespace

```bash
kubectl delete namespace dev
```

⚠️ Deleting a namespace deletes **all resources** inside it:

* Pods
* Services
* Deployments
* ConfigMaps
* Secrets

---

## Quick Commands for CKA Exam

```bash
kubectl get ns

kubectl create ns dev

kubectl get pods -n dev

kubectl get pods -A

kubectl run nginx --image=nginx -n dev

kubectl config set-context --current --namespace=dev

kubectl delete ns dev
```

### Simple Flow

```text
Cluster
│
├── default
│   ├── Pod
│   ├── Service
│   └── Deployment
│
├── dev
│   ├── Pod
│   └── Service
│
└── prod
    ├── Pod
    ├── Service
    └── Deployment
```

A namespace does **not** create a separate cluster. It only creates a logical boundary inside the same Kubernetes cluster.
