# What is LoadBalancer in Kubernetes?

A **LoadBalancer Service** exposes your application to external users using a cloud provider’s load balancer.

It is the most common way to expose applications in cloud Kubernetes environments like:

* Amazon Web Services
* Google Cloud
* Microsoft Azure

---

# Simple Understanding

```text id="yw09m8"
Internet User
      ↓
Cloud Load Balancer
      ↓
Kubernetes Service
      ↓
Pods
```

Think:

```text id="k27mbe"
LoadBalancer = Smart traffic controller
```

It distributes incoming traffic across multiple Pods.

---

# Why LoadBalancer is Needed

Without LoadBalancer:

```text id="lz3bh1"
User → Single Server
```

Problem:

* Server overload
* Failure risk
* No scaling

With LoadBalancer:

```text id="6fqdr4"
User
 ↓
Load Balancer
 ↓    ↓    ↓
Pod1 Pod2 Pod3
```

Traffic distributes automatically.

---

# Kubernetes Service Types Recap

| Type         | Access                |
| ------------ | --------------------- |
| ClusterIP    | Internal only         |
| NodePort     | External via Node IP  |
| LoadBalancer | External via Cloud LB |

---

# Architecture

```text id="uy1v9f"
                    Internet
                        ↓
              Cloud Load Balancer
                        ↓
                Kubernetes Service
                        ↓
              +------------------+
              ↓        ↓        ↓
            Pod1     Pod2     Pod3
```

---

# Example Deployment

```yaml id="xh8gku"
apiVersion: apps/v1
kind: Deployment

metadata:
  name: nginx-deploy

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
        image: nginx
        ports:
        - containerPort: 80
```

Apply:

```bash id="2y3o0r"
kubectl apply -f deployment.yaml
```

---

# LoadBalancer Service YAML

```yaml id="q9i2u5"
apiVersion: v1
kind: Service

metadata:
  name: nginx-loadbalancer

spec:
  type: LoadBalancer

  selector:
    app: nginx

  ports:
  - port: 80
    targetPort: 80
```

Apply:

```bash id="k98l7x"
kubectl apply -f loadbalancer.yaml
```

---

# Check Service

```bash id="h1v4zj"
kubectl get svc
```

Example output:

```text id="v4q4v9"
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP
nginx-loadbalancer     LoadBalancer   10.96.15.20    35.200.x.x
```

Important:

```text id="2dd85p"
EXTERNAL-IP
```

This is public IP created by cloud provider.

---

# Access Application

```text id="l1m2ku"
http://35.200.x.x
```

Users can now access application from internet.

---

# Internal Working

When you create:

```yaml id="utq8g0"
type: LoadBalancer
```

Kubernetes automatically:

1. Creates ClusterIP
2. Creates NodePort
3. Requests cloud load balancer

Flow:

```text id="8djlwm"
Internet
   ↓
Cloud Load Balancer
   ↓
NodePort
   ↓
Pods
```

---

# Important Cloud Requirement

LoadBalancer works properly mainly in cloud environments:

* Amazon Web Services
* Google Cloud
* Microsoft Azure

---

# What About Kind or Minikube?

In local clusters:

```text id="lq3n2s"
EXTERNAL-IP = pending
```

because no real cloud load balancer exists.

---

# For Local Kubernetes

Usually use:

* NodePort
* Ingress
* MetalLB

instead.

---

# Example with Kind

```bash id="sj1f1k"
kubectl get svc
```

Output:

```text id="2l6jql"
EXTERNAL-IP   <pending>
```

This is normal in Kind.

---

# LoadBalancer vs NodePort

| Feature          | NodePort | LoadBalancer    |
| ---------------- | -------- | --------------- |
| External access  | ✅        | ✅               |
| Uses cloud LB    | ❌        | ✅               |
| Public IP        | ❌        | ✅               |
| Production ready | Limited  | Yes             |
| Manual port      | Yes      | No need usually |

---

# Real Production Flow

```text id="jlwm3w"
Users
  ↓
AWS ELB / ALB
  ↓
Ingress / Service
  ↓
Application Pods
```

---

# Important Interview Question

## Does LoadBalancer create NodePort internally?

Yes.

Kubernetes internally creates:

```text id="5i0fkv"
LoadBalancer
    ↓
NodePort
    ↓
Pods
```

---

# Quick Command Method

Create deployment:

```bash id="j8g94k"
kubectl create deployment nginx --image=nginx
```

Expose as LoadBalancer:

```bash id="ryo6uv"
kubectl expose deployment nginx \
--type=LoadBalancer \
--port=80
```

Check:

```bash id="8lu0h2"
kubectl get svc
```

---

# Real Beginner Understanding

Think:

```text id="xehw2k"
ClusterIP    = Office internal phone
NodePort     = Direct building gate
LoadBalancer = Main company reception system
```

---

# Important Production Concepts

LoadBalancer often works with:

* Ingress Controllers
* DNS
* SSL/TLS
* WAF
* Auto Scaling

---

# Final Memory Trick

```text id="rq8z0n"
ClusterIP   → Internal
NodePort    → External via Node
LoadBalancer → External via Cloud LB
```
