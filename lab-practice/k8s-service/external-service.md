In Kubernetes, “External” usually means making your application reachable **outside the cluster**.

There are multiple ways Kubernetes handles external access.

# Main External Access Methods in Kubernetes

| Method       | External Access      | Usage                       |
| ------------ | -------------------- | --------------------------- |
| ClusterIP    | ❌ No                 | Internal communication      |
| NodePort     | ✅ Yes                | Lab/testing                 |
| LoadBalancer | ✅ Yes                | Cloud production            |
| Ingress      | ✅ Yes                | Advanced production routing |
| ExternalName | External DNS mapping | Connect external services   |

---

# 1. ClusterIP (Internal Only)

```text id="j6xqnt"
Inside Cluster → Allowed
Outside Cluster → Not Allowed
```

Example:

```yaml id="jgj4r4"
type: ClusterIP
```

Used for:

* backend APIs
* database communication
* internal microservices

---

# 2. NodePort (External Access)

Kubernetes opens a port on every node.

```text id="gpx45r"
Browser
   ↓
NodeIP:30080
   ↓
Service
   ↓
Pods
```

Example:

```yaml id="m9ltpf"
type: NodePort
```

Access:

```text id="0ljhnl"
http://NODE-IP:30080
```

---

# 3. LoadBalancer (Cloud External Access)

Cloud provider creates external load balancer.

```text id="11s9tb"
Internet
   ↓
Cloud Load Balancer
   ↓
Service
   ↓
Pods
```

Example:

```yaml id="w3uh3j"
type: LoadBalancer
```

Mostly used on:

* Amazon Web Services
* Google Cloud
* Microsoft Azure

---

# 4. Ingress (Smart External Routing)

Ingress gives:

* domain-based routing
* HTTPS
* path-based routing

Example:

```text id="j6go5s"
example.com/api
example.com/app
```

Flow:

```text id="j7ru2z"
Internet
   ↓
Ingress Controller
   ↓
Services
   ↓
Pods
```

Production mostly uses:

```text id="cq3f2m"
Ingress + LoadBalancer
```

---

# 5. ExternalName Service

Used when Kubernetes needs to connect to an external service.

Example:

```text id="o2sywy"
Kubernetes App
      ↓
External Database
```

YAML:

```yaml id="z9jlwm"
apiVersion: v1
kind: Service

metadata:
  name: external-db

spec:
  type: ExternalName
  externalName: mydb.example.com
```

Kubernetes creates DNS mapping.

---

# Complete Big Picture

```text id="dtz98n"
                External User
                       ↓
       --------------------------------
       |            |                 |
   NodePort    LoadBalancer       Ingress
       ↓            ↓                 ↓
               Kubernetes Services
                       ↓
                     Pods
```

---

# External Traffic Flow Example

```text id="lm70yc"
User Browser
    ↓
Public IP / Domain
    ↓
Kubernetes Service
    ↓
Pod
    ↓
Container
```

---

# External vs Internal

| Feature      | Internal | External |
| ------------ | -------- | -------- |
| ClusterIP    | ✅        | ❌        |
| NodePort     | ✅        | ✅        |
| LoadBalancer | ✅        | ✅        |
| Ingress      | ✅        | ✅        |

---

# Important Beginner Understanding

## Pod is never directly exposed

Usually:

```text id="6v2uvm"
External User
   ↓
Service
   ↓
Pod
```

NOT:

```text id="wm99h9"
External User → Pod Directly
```

Because Pods are temporary.

---

# Common External Access Commands

## View services

```bash id="mwic11"
kubectl get svc
```

## Expose deployment externally

### NodePort

```bash id="6cqv1m"
kubectl expose deployment nginx \
--type=NodePort \
--port=80
```

### LoadBalancer

```bash id="mdw9ju"
kubectl expose deployment nginx \
--type=LoadBalancer \
--port=80
```

---

# External IP Check

```bash id="9lsnuh"
kubectl get svc
```

Example:

```text id="xig6iw"
NAME         TYPE           EXTERNAL-IP
nginx        LoadBalancer   35.x.x.x
```

---

# Real Production Architecture

```text id="8y6w1f"
Internet
   ↓
DNS
   ↓
Load Balancer
   ↓
Ingress Controller
   ↓
Services
   ↓
Pods
```

---

# Quick Memory Trick

```text id="dnf55d"
ClusterIP    → Internal only
NodePort     → External via Node IP
LoadBalancer → External via Cloud
Ingress      → Smart external routing
```
