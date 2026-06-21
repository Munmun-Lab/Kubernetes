# CoreDNS in Kubernetes – Detailed Explanation

## What is CoreDNS?

**CoreDNS** is the DNS server used by Kubernetes to provide **service discovery** inside the cluster.

Instead of remembering Pod IPs, applications communicate using names such as:

```bash
mysql.default.svc.cluster.local
```

CoreDNS converts these names into IP addresses.

---

# Why CoreDNS is Needed?

Imagine a cluster:

```text
Frontend Pod  ---> Backend Service ---> Backend Pods
```

The backend service IP may be:

```text
10.96.100.20
```

Instead of configuring:

```bash
http://10.96.100.20
```

Applications use:

```bash
http://backend
```

CoreDNS resolves:

```bash
backend
     ↓
10.96.100.20
```

This allows applications to continue working even if Pods restart and IPs change.

---

# CoreDNS Architecture

```text
+-------------------+
|   Application Pod |
+-------------------+
          |
          | DNS Query
          |
          v
+-------------------+
|     CoreDNS       |
+-------------------+
          |
          |
          +--> Kubernetes API
          |
          +--> External DNS Servers
                (Google DNS, Route53 etc.)
```

CoreDNS continuously watches Kubernetes resources:

* Services
* Endpoints
* Pods
* Namespaces

through the Kubernetes API.

---

# CoreDNS Deployment

Check CoreDNS:

```bash
kubectl get pods -n kube-system
```

Example:

```text
NAME                       READY
coredns-6d4b75cb6d-xf9tj   1/1
coredns-6d4b75cb6d-rm4vl   1/1
```

Typically:

* 2 replicas
* Runs in `kube-system`
* Managed as a Deployment

View deployment:

```bash
kubectl get deploy coredns -n kube-system
```

---

# CoreDNS Service

CoreDNS is exposed through a ClusterIP Service.

```bash
kubectl get svc -n kube-system
```

Example:

```text
NAME      TYPE       CLUSTER-IP
kube-dns  ClusterIP  10.96.0.10
```

Even though CoreDNS is used, the service name remains:

```text
kube-dns
```

This IP is configured in every pod.

---

# How DNS Resolution Works

## Example

Create service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
```

Application connects:

```bash
mysql
```

Flow:

```text
Application
    |
    v
Pod DNS Resolver
    |
    v
CoreDNS
    |
    v
Service Lookup
    |
    v
10.96.100.20
```

Returned to application.

---

# DNS Records Created by CoreDNS

## Service Record

Service:

```yaml
metadata:
  name: mysql
namespace: default
```

DNS Record:

```text
mysql.default.svc.cluster.local
```

Returns:

```text
10.96.100.20
```

---

## Namespace Scoped Lookup

Within same namespace:

```bash
mysql
```

works automatically.

Cross namespace:

```bash
mysql.database
```

or

```bash
mysql.database.svc.cluster.local
```

---

## Pod Records

Pod:

```text
10.244.1.5
```

DNS:

```text
10-244-1-5.default.pod.cluster.local
```

Less commonly used in production.

---

# DNS Search Domains

Inside a pod:

```bash
cat /etc/resolv.conf
```

Example:

```text
search default.svc.cluster.local
       svc.cluster.local
       cluster.local
```

This allows:

```bash
mysql
```

to automatically expand to:

```text
mysql.default.svc.cluster.local
```

---

# CoreDNS ConfigMap

View configuration:

```bash
kubectl -n kube-system get cm coredns -o yaml
```

Example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns

data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
    }
```

---

# Understanding Corefile Plugins

## kubernetes

```text
kubernetes cluster.local
```

Provides Kubernetes service discovery.

Example:

```bash
mysql.default.svc.cluster.local
```

resolved using Kubernetes API.

---

## forward

```text
forward . /etc/resolv.conf
```

Forwards external DNS queries.

Example:

```bash
google.com
```

CoreDNS forwards request to:

```text
8.8.8.8
or
VPC DNS
or
Corporate DNS
```

---

## cache

```text
cache 30
```

Caches DNS results for 30 seconds.

Benefits:

* Faster lookups
* Reduced API calls

---

## health

```text
health
```

Provides health endpoint.

Example:

```bash
http://localhost:8080/health
```

---

## reload

```text
reload
```

Automatically reloads configuration changes.

---

## errors

```text
errors
```

Logs DNS errors.

---

# DNS Resolution Example

Suppose:

```text
Namespace: ecommerce

Service: backend

ClusterIP: 10.96.5.20
```

Frontend pod requests:

```bash
backend
```

CoreDNS checks:

```text
backend.ecommerce.svc.cluster.local
```

Returns:

```text
10.96.5.20
```

Traffic flow:

```text
Frontend Pod
      |
      v
backend
      |
      v
CoreDNS
      |
      v
10.96.5.20
      |
      v
Backend Service
      |
      v
Backend Pods
```

---

# CoreDNS and External Websites

Pod:

```bash
curl google.com
```

Flow:

```text
Pod
 |
 v
CoreDNS
 |
 v
Forward Plugin
 |
 v
External DNS
 |
 v
Google IP
```

---

# How to Test CoreDNS

Create a temporary pod:

```bash
kubectl run test \
--image=busybox \
-it --rm -- sh
```

Inside pod:

```bash
nslookup kubernetes.default
```

Output:

```text
Server: 10.96.0.10

Name: kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

Test external DNS:

```bash
nslookup google.com
```

---

# Common CoreDNS Troubleshooting

### Check CoreDNS Pods

```bash
kubectl get pods -n kube-system
```

---

### View Logs

```bash
kubectl logs -n kube-system deploy/coredns
```

---

### Check Service

```bash
kubectl get svc -n kube-system kube-dns
```

---

### Verify DNS from Pod

```bash
kubectl exec -it nginx -- nslookup kubernetes.default
```

---

### Verify Endpoints

```bash
kubectl get endpoints -n kube-system kube-dns
```

---

# Enterprise Production Considerations

In production environments (EKS, AKS, GKE, OpenShift):

* Run **2–4 CoreDNS replicas** minimum.
* Use **Pod Anti-Affinity** to spread replicas across nodes.
* Monitor:

  * DNS latency
  * Query rate (QPS)
  * Cache hit ratio
  * Error rate
* Enable autoscaling for large clusters.
* Use **NodeLocal DNS Cache** for very large clusters (Netflix-scale environments) to reduce CoreDNS load.

Architecture:

```text
Pods
  |
  v
NodeLocal DNS Cache
  |
  v
CoreDNS
  |
  v
External DNS
```

---

# Interview Definition (Short)

**CoreDNS is the Kubernetes DNS server that provides service discovery by resolving Kubernetes Service and Pod names into IP addresses. It watches Kubernetes resources through the API server and answers internal DNS queries while forwarding external DNS requests to upstream DNS servers.**




Yes, **CoreDNS is considered part of the Kubernetes networking ecosystem**, but it is **not a CNI (Container Network Interface) component** like Calico, Cilium, or Flannel.

### Kubernetes Networking Components

```text
Kubernetes Networking
│
├── CNI Plugin (Calico/Cilium/Flannel)
│     ├── Pod-to-Pod Communication
│     ├── Pod-to-Service Communication
│     └── Network Policies
│
├── kube-proxy
│     └── Service Load Balancing
│
└── CoreDNS
      └── DNS-based Service Discovery
```

### What CoreDNS Does

CoreDNS provides **name resolution**.

Without CoreDNS:

```bash
curl http://10.96.100.20
```

With CoreDNS:

```bash
curl http://backend
```

CoreDNS translates:

```text
backend.default.svc.cluster.local
        ↓
10.96.100.20
```

### Does Application Traffic Pass Through CoreDNS?

No.

Traffic flow is:

```text
Application
     |
     | DNS Query
     v
CoreDNS
     |
     | Returns Service IP
     v
Application
     |
     | Actual HTTP/TCP Traffic
     v
Service (ClusterIP)
     |
     v
Backend Pods
```

CoreDNS only answers the DNS query and then gets out of the way.

### Relationship with CNI

Suppose:

```text
Frontend Pod ---> Backend Service
```

1. Frontend asks CoreDNS:

   ```text
   backend.default.svc.cluster.local ?
   ```

2. CoreDNS returns:

   ```text
   10.96.100.20
   ```

3. Frontend sends traffic to `10.96.100.20`.

4. kube-proxy routes traffic to backend Pods.

5. CNI (Calico/Cilium/etc.) carries packets between nodes.

```text
DNS Resolution  ---> CoreDNS
Service Routing ---> kube-proxy
Packet Transport ---> CNI
```

### Interview Answer

> CoreDNS is a Kubernetes networking component responsible for DNS-based service discovery. It resolves Service and Pod names to IP addresses. While it is part of the networking stack, it does not handle packet forwarding like Calico or Cilium; it only provides name resolution for communication within the cluster and to external domains.



