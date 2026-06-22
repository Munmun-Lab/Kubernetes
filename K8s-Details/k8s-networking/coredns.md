# CoreDNS in Kubernetes – Detailed Notes & Explanation

---

## 1. What is CoreDNS?

**Description:**

CoreDNS is the default DNS server deployed in Kubernetes clusters. It provides **service discovery**, allowing applications to communicate using service names instead of IP addresses.

**Why important?**

* Pod IPs are dynamic and can change after restarts.
* Service names remain constant.
* Applications don't need to know backend IP addresses.

**Example:**

Instead of:

```bash
mysql.default.svc.cluster.local -> 10.96.100.20
```

applications can simply use:

```bash
mysql
```

and CoreDNS resolves it automatically.

---

## 2. Why CoreDNS is Needed?

**Description:**

In Kubernetes, Pods are constantly created, deleted, and recreated. Every time a Pod is recreated, it may receive a different IP address.

CoreDNS provides a stable name-to-IP mapping so applications continue working without configuration changes.

### Without CoreDNS

```text
Frontend ---> 10.96.100.20
```

Application must know the IP.

### With CoreDNS

```text
Frontend ---> backend
```

CoreDNS resolves:

```text
backend
  ↓
10.96.100.20
```

**Benefit:**

Applications become portable and resilient to infrastructure changes.

---

## 3. CoreDNS Architecture

**Description:**

CoreDNS acts as the DNS server for the entire Kubernetes cluster.

It continuously watches:

* Services
* Endpoints
* Pods
* Namespaces

through the Kubernetes API Server.

### Workflow

```text
Application Pod
      |
      | DNS Query
      v
CoreDNS
      |
      +--> Kubernetes API
      |
      +--> External DNS
```

**Key Point:**

CoreDNS maintains an updated view of cluster resources and responds to DNS requests accordingly.

---

## 4. CoreDNS Deployment

**Description:**

CoreDNS is deployed automatically when a Kubernetes cluster is created (kubeadm, EKS, AKS, GKE, OpenShift).

### Characteristics

* Runs in `kube-system`
* Managed as a Deployment
* Usually deployed with 2 replicas for high availability

### Verify

```bash
kubectl get pods -n kube-system
```

**Purpose of multiple replicas:**

If one CoreDNS pod fails, DNS resolution continues through the remaining replicas.

---

## 5. CoreDNS Service

**Description:**

Applications do not directly talk to CoreDNS Pods.

Instead, they communicate through a Kubernetes Service named:

```text
kube-dns
```

### Example

```bash
kubectl get svc -n kube-system
```

Output:

```text
kube-dns   ClusterIP   10.96.0.10
```

### Why Service?

The service provides:

* Stable IP
* Load balancing across CoreDNS Pods
* High availability

Every Pod uses this IP for DNS lookups.

---

## 6. How DNS Resolution Works

**Description:**

When an application requests a service name, the query is sent to CoreDNS.

### Flow

```text
Application
     |
     v
Pod Resolver
     |
     v
CoreDNS
     |
     v
Service Lookup
     |
     v
ClusterIP Returned
```

### Example

Application:

```bash
curl http://mysql
```

CoreDNS returns:

```text
10.96.100.20
```

Application then sends traffic directly to the Service IP.

---

## 7. DNS Records Created by CoreDNS

### Service Records

**Description:**

Every Kubernetes Service automatically gets a DNS record.

Example Service:

```yaml
name: mysql
namespace: default
```

DNS name:

```text
mysql.default.svc.cluster.local
```

Returns:

```text
10.96.100.20
```

---

### Namespace Scoped Lookup

**Description:**

Pods can access services within the same namespace using only the service name.

Same namespace:

```bash
mysql
```

Different namespace:

```bash
mysql.database
```

Full DNS:

```bash
mysql.database.svc.cluster.local
```

---

### Pod Records

**Description:**

CoreDNS can also create DNS entries for Pods.

Example:

```text
Pod IP: 10.244.1.5
```

DNS:

```text
10-244-1-5.default.pod.cluster.local
```

**Usage:**

Rarely used in production because Pod IPs frequently change.

---

## 8. DNS Search Domains

**Description:**

Every Pod receives DNS search paths through `/etc/resolv.conf`.

### Check

```bash
cat /etc/resolv.conf
```

Example:

```text
search default.svc.cluster.local
       svc.cluster.local
       cluster.local
```

### Result

When application requests:

```bash
mysql
```

Kubernetes automatically expands to:

```text
mysql.default.svc.cluster.local
```

No need to type the full name.

---

## 9. CoreDNS ConfigMap

**Description:**

CoreDNS configuration is stored inside a ConfigMap called:

```text
coredns
```

### View Configuration

```bash
kubectl get cm coredns -n kube-system -o yaml
```

The main configuration file is called:

```text
Corefile
```

This file controls CoreDNS behavior and plugins.

---

## 10. Understanding Corefile Plugins

### Kubernetes Plugin

```text
kubernetes cluster.local
```

**Purpose:**

Provides DNS records for Kubernetes Services and Pods.

Example:

```bash
mysql.default.svc.cluster.local
```

Resolved using Kubernetes API data.

---

### Forward Plugin

```text
forward . /etc/resolv.conf
```

**Purpose:**

Handles DNS requests for external websites.

Example:

```bash
google.com
```

CoreDNS forwards the request to:

* Corporate DNS
* Cloud DNS
* Google DNS
* VPC DNS

---

### Cache Plugin

```text
cache 30
```

**Purpose:**

Stores DNS responses for 30 seconds.

Benefits:

* Faster responses
* Lower API Server load
* Reduced external DNS queries

---

### Health Plugin

```text
health
```

**Purpose:**

Exposes health status of CoreDNS.

Useful for:

* Kubernetes probes
* Monitoring tools
* Load balancer health checks

---

### Reload Plugin

```text
reload
```

**Purpose:**

Automatically reloads CoreDNS configuration when ConfigMap changes.

No manual restart required.

---

### Errors Plugin

```text
errors
```

**Purpose:**

Logs DNS failures and troubleshooting information.

Very useful during incident investigation.

---

## 11. DNS Resolution Example

Suppose:

```text
Namespace: ecommerce
Service: backend
ClusterIP: 10.96.5.20
```

Frontend application requests:

```bash
backend
```

CoreDNS converts it to:

```text
backend.ecommerce.svc.cluster.local
```

Returns:

```text
10.96.5.20
```

Application then sends traffic to the Service.

---

## 12. CoreDNS and External Websites

**Description:**

CoreDNS is not limited to Kubernetes resources.

It also resolves internet domains.

### Example

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

## 13. How to Test CoreDNS

### Create Test Pod

```bash
kubectl run test --image=busybox -it --rm -- sh
```

### Test Internal DNS

```bash
nslookup kubernetes.default
```

Expected:

```text
kubernetes.default.svc.cluster.local
```

### Test External DNS

```bash
nslookup google.com
```

**Purpose:**

Confirms CoreDNS can resolve both internal and external names.

---

## 14. Common CoreDNS Troubleshooting

### Check CoreDNS Pods

```bash
kubectl get pods -n kube-system
```

**Verify:** Pods are Running and Ready.

---

### View Logs

```bash
kubectl logs -n kube-system deploy/coredns
```

**Verify:** DNS errors, plugin failures, API connectivity issues.

---

### Check Service

```bash
kubectl get svc -n kube-system kube-dns
```

**Verify:** ClusterIP exists.

---

### Test DNS from Application Pod

```bash
kubectl exec -it nginx -- nslookup kubernetes.default
```

**Verify:** DNS works from workload pods.

---

### Check Endpoints

```bash
kubectl get endpoints -n kube-system kube-dns
```

**Verify:** Service points to CoreDNS Pods.

---

## 15. Enterprise Production Considerations

### Multiple Replicas

Deploy:

```text
2–4 CoreDNS Pods
```

Provides redundancy and high availability.

---

### Pod Anti-Affinity

Spread replicas across nodes.

```text
Node1 -> CoreDNS Pod1
Node2 -> CoreDNS Pod2
```

Prevents node failure from affecting all DNS servers.

---

### Monitor DNS Metrics

Track:

* DNS latency
* Queries per second (QPS)
* Error rates
* Cache hit ratio

DNS issues can impact the entire cluster.

---

### Enable Autoscaling

Large clusters generate high DNS traffic.

Use:

```text
Horizontal Pod Autoscaler (HPA)
```

to scale CoreDNS automatically.

---

### NodeLocal DNS Cache

Used in large enterprise environments.

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

Benefits:

* Reduced CoreDNS load
* Lower DNS latency
* Better scalability

---

## 16. CoreDNS vs kube-proxy vs CNI

| Component             | Responsibility     |
| --------------------- | ------------------ |
| CoreDNS               | DNS Resolution     |
| kube-proxy            | Service Routing    |
| Calico/Cilium/Flannel | Packet Transport   |
| API Server            | Cluster Management |

### Request Flow

```text
Application
      |
      | DNS Lookup
      v
CoreDNS
      |
      | Service IP Returned
      v
Application
      |
      | HTTP/TCP Traffic
      v
kube-proxy
      |
      v
Backend Pod
      |
      v
CNI Network
```

---

## Interview Summary

**CoreDNS is the DNS server used by Kubernetes for service discovery. It watches Services, Endpoints, Pods, and Namespaces through the Kubernetes API and resolves service names into IP addresses. CoreDNS handles internal cluster DNS queries and forwards external DNS requests to upstream DNS servers. It is part of the Kubernetes networking stack but does not route traffic; actual packet forwarding is handled by kube-proxy and the CNI plugin.**
