# What is NodePort in Kubernetes?

A **NodePort** is a Kubernetes Service type used to expose your application outside the cluster.

Normally Pods are internal.
NodePort opens a port on every Kubernetes node so external users can access the application.

---

# Simple Real-Life Flow

```text
User Browser
     ↓
Node IP + Port
     ↓
Kubernetes NodePort Service
     ↓
Pod
     ↓
Application
```

Example:

```text
http://192.168.1.10:30080
```

Here:

* `192.168.1.10` → Kubernetes Node IP
* `30080` → NodePort
* Traffic goes to Pod internally

---

# Kubernetes Service Types

| Type         | Usage                        |
| ------------ | ---------------------------- |
| ClusterIP    | Internal only                |
| NodePort     | External access via Node IP  |
| LoadBalancer | Cloud external load balancer |
| ExternalName | DNS mapping                  |

NodePort is commonly used for:

* Labs
* Learning Kubernetes
* Testing applications
* Kind clusters
* Minikube

---

# Architecture

```text
                Kubernetes Cluster

+--------------------------------------------------+

 Node 1
 +----------------------------------------------+
 | NodePort : 30080                             |
 |                                              |
 |   Service                                    |
 |      ↓                                       |
 |   Pod (nginx)                                |
 +----------------------------------------------+

 Node 2
 +----------------------------------------------+
 | NodePort : 30080                             |
 +----------------------------------------------+

+--------------------------------------------------+
```

Kubernetes opens the same NodePort on all nodes.

---

# Example — Create Deployment

```yaml id="u0d3n9"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy

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
        ports:
        - containerPort: 80
```

Apply:

```bash id="db4d5r"
kubectl apply -f deployment.yaml
```

---

# Create NodePort Service

```yaml id="j3t6zp"
apiVersion: v1
kind: Service

metadata:
  name: nginx-nodeport

spec:
  type: NodePort

  selector:
    app: nginx

  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

Apply:

```bash id="a4p1he"
kubectl apply -f nodeport.yaml
```

---

# Important Ports Understanding

| Field      | Meaning            |
| ---------- | ------------------ |
| port       | Service port       |
| targetPort | Pod container port |
| nodePort   | External node port |

Flow:

```text
Browser → NodePort(30080)
         → Service Port(80)
         → Pod Port(80)
```

---

# Check Service

```bash id="e9x1vd"
kubectl get svc
```

Example output:

```text
NAME               TYPE       CLUSTER-IP      PORT(S)
nginx-nodeport     NodePort   10.96.20.10    80:30080/TCP
```

Meaning:

```text
80        → Service Port
30080     → External NodePort
```

---

# Access Application

## For Kind Cluster

Get node IP:

```bash id="d4r9pn"
kubectl get nodes -o wide
```

or use:

```bash id="h5v1sj"
docker ps
```

Then:

```text
http://localhost:30080
```

or:

```text
http://<NODE-IP>:30080
```

---

# NodePort Range

Default NodePort range:

```text
30000 - 32767
```

If not specified:

```yaml id="fh7m2r"
nodePort: 30080
```

Kubernetes automatically assigns one.

---

# Commands You’ll Use

Create service directly:

```bash id="w3k8mj"
kubectl expose deployment nginx-deploy \
--type=NodePort \
--port=80
```

Check services:

```bash id="b2x8kf"
kubectl get svc
```

Describe service:

```bash id="z8m2hq"
kubectl describe svc nginx-nodeport
```

Delete service:

```bash id="u2r4nx"
kubectl delete svc nginx-nodeport
```

---

# Difference Between ClusterIP and NodePort

| Feature            | ClusterIP | NodePort |
| ------------------ | --------- | -------- |
| Internal access    | Yes       | Yes      |
| External access    | No        | Yes      |
| Uses Node IP       | No        | Yes      |
| Browser accessible | No        | Yes      |

---

# Real Beginner Understanding

Think:

```text
Pod = Application room
Service = Reception desk
NodePort = Building main gate open to public
```

Without NodePort:

```text
Only internal people can access
```

With NodePort:

```text
Outside world can access application
```

---

# Verify End-to-End

## 1 Create deployment

```bash id="s1q9wr"
kubectl create deployment nginx --image=nginx
```

## 2 Expose deployment

```bash id="w6p2ty"
kubectl expose deployment nginx \
--type=NodePort \
--port=80
```

## 3 Check service

```bash id="r8k5vz"
kubectl get svc
```

## 4 Open in browser

```text
http://localhost:<NODEPORT>
```

Example:

```text
http://localhost:31245
```

---

# Important Interview Question

## Does NodePort open on all nodes?

Yes.

Kubernetes opens that port on every worker node.

---

# Production Note

NodePort is mostly for:

* Testing
* Labs
* Internal usage

Production usually uses:

* Ingress
* LoadBalancer
* API Gateway

instead of directly exposing NodePort.
