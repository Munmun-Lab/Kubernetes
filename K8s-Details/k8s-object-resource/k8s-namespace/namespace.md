A **Namespace** in Kubernetes is like a **separate room inside the same Kubernetes cluster**. It helps you organize and isolate resources.

### Real-Life Example

Imagine your company has **one Kubernetes cluster** shared by three teams:

| Team             | Namespace |
| ---------------- | --------- |
| Development Team | dev       |
| Testing Team     | test      |
| Production Team  | prod      |

All teams can deploy an application named `nginx`, but they won't conflict because they are in different namespaces.

```
Kubernetes Cluster
│
├── Namespace: dev
│   └── nginx pod
│
├── Namespace: test
│   └── nginx pod
│
└── Namespace: prod
    └── nginx pod
```

---

## Why Use Namespaces?

### Without Namespace

If two teams create a pod named `nginx`:

```bash
kubectl run nginx --image=nginx
kubectl run nginx --image=nginx
```

Second command fails because the pod name already exists.

---

### With Namespace

Team Dev:

```bash
kubectl create namespace dev

kubectl run nginx \
--image=nginx \
-n dev
```

Team Test:

```bash
kubectl create namespace test

kubectl run nginx \
--image=nginx \
-n test
```

Now both pods can exist:

```bash
kubectl get pods -n dev
```

Output:

```text
nginx
```

```bash
kubectl get pods -n test
```

Output:

```text
nginx
```

Same pod name, different namespaces.

---

## Common Namespaces

```bash
kubectl get namespaces
```

Output:

```text
NAME              STATUS
default           Active
kube-system       Active
kube-public       Active
kube-node-lease   Active
```

### Meaning

| Namespace       | Purpose                                             |
| --------------- | --------------------------------------------------- |
| default         | Your applications go here if no namespace specified |
| kube-system     | Kubernetes system components                        |
| kube-public     | Publicly readable resources                         |
| kube-node-lease | Node heartbeat information                          |

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

Check:

```bash
kubectl get pods -n dev
```

---

## Namespace YAML Example

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

Create it:

```bash
kubectl apply -f namespace.yaml
```

---

## Deployment in Namespace

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: dev
spec:
  replicas: 2
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
        image: nginx
```

Deploy:

```bash
kubectl apply -f deployment.yaml
```

---

## Switch Default Namespace

Instead of writing `-n dev` every time:

```bash
kubectl config set-context --current --namespace=dev
```

Now:

```bash
kubectl get pods
```

shows pods from `dev` namespace automatically.

---

## In Simple

> A Namespace is a logical partition inside a Kubernetes cluster used to organize and isolate resources among different teams, environments, or applications. Multiple resources with the same name can exist in different namespaces.

### Easy Memory Trick

Think of a Kubernetes cluster as an **apartment building**:

* Cluster = Building
* Namespace = Flat (Apartment)
* Pods = People living inside the flat

Two people named "Rahul" can live in different flats without conflict. Similarly, two pods named `nginx` can exist in different namespaces.
