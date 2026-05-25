# Cluster Upgrade

## Enterprise Kubernetes Cluster Upgrade Flow

This upgrade process is broadly applicable across enterprise Kubernetes distributions such as:

* Red Hat OpenShift
* Rancher
* VMware Tanzu Kubernetes Grid
* Amazon Elastic Kubernetes Service
* Azure Kubernetes Service
* Google Kubernetes Engine
* Mirantis Kubernetes Engine
* SUSE Rancher Prime
* kubeadm
* Kubespray

Even though commands differ, the enterprise upgrade lifecycle remains mostly the same.

---

# High-Level Upgrade Strategy

```text id="f2j5z0"
Backup → Compatibility Check → Upgrade Control Plane →
Upgrade Worker Nodes → Upgrade Addons →
Validation → Monitoring -> Cleanup
```
## Check current cluster version

Check versions:

```bash id="bh5xvd"
kubectl version
```

Check node versions:

```bash id="4fd9p2"
kubectl get nodes
```

Check cluster info:

```bash id="h1qvkl"
kubectl cluster-info
```

---

# 1. Understand Kubernetes Version Skew Policy

Before upgrade:

Check supported version jumps.

Usually:

* Upgrade one minor version at a time

Example:

```text id="mp0yuh"
1.27 → 1.28 → 1.29
```

Avoid:

```text id="n0hzy6"
1.27 → 1.30
```

---

# 2. Read Release Notes & Compatibility

Very important in enterprise environments.

Check:

* Deprecated APIs
* Removed features
* CRD compatibility
* Networking changes
* CSI/CNI support
* Ingress compatibility
* Helm chart compatibility

## Read Upgrade Compatibility Matrix

Very important step.

Verify:

| Check                             | Why                        |
| --------------------------------- | -------------------------- |
| Kubernetes supported upgrade path | Avoid skipped versions     |
| CNI compatibility                 | Networking stability       |
| CSI/storage compatibility         | Persistent volume safety   |
| Ingress controller support        | Traffic routing            |
| Helm chart compatibility          | App stability              |
| Runtime support                   | containerd / CRI-O support |

---

# 3. Take Full Backups

Critical step.

---

## Backup etcd

Most important backup.

```text id="e7w1dx"
etcd = Kubernetes brain/database
```

Contains:

* Cluster state
* Nodes
* Secrets
* Deployments
* Configurations

Example:

```bash id="w2x9ne"
etcdctl snapshot save backup.db
```

---

## Backup Kubernetes Resources

```bash id="5qjlwm"
kubectl get all --all-namespaces -o yaml > cluster-backup.yaml
```

---

## Backup Important Resources

Export:

* YAML manifests
* Helm values
* CRDs
* Secrets
* PV snapshots
* Ingress configs
* Storage configs
* Certificates
* Terraform/IaC
* Monitoring configs
* GitOps repos

---

# 4. Check Cluster Health

Before upgrade ensure:

```bash id="3lk6eb"
kubectl get nodes
kubectl get pods -A
kubectl get csr
kubectl top nodes
kubectl get events
```

Validate:

* No failed pods
* No pending pods
* No disk pressure
* No memory pressure
* etcd healthy
* All nodes Ready

---

# 5. Verify Ecosystem Compatibility

Very important in enterprise.

---

## Validate:

| Component      | Check                               |
| -------------- | ----------------------------------- |
| CNI            | Calico/Cilium/Flannel compatibility |
| CSI            | Storage driver support              |
| Ingress        | NGINX/HAProxy/Traefik support       |
| Monitoring     | Prometheus/Grafana compatibility    |
| Service Mesh   | Istio/Linkerd compatibility         |
| Backup Tool    | Velero compatibility                |
| Security Tools | Falco/OPA/Kyverno support           |

---

# 6. Upgrade Control Plane First

Always upgrade control plane before workers.

---

# Components Upgraded

| Component               | Role           |
| ----------------------- | -------------- |
| kube-apiserver          | API endpoint   |
| kube-controller-manager | Controllers    |
| kube-scheduler          | Scheduling     |
| etcd                    | Database       |
| kubeadm                 | Bootstrap tool |


# Generic Upgrade Flow

```text id="wj3ffw"
Drain control-plane node
→ Upgrade Kubernetes binaries
→ Restart services
→ Validate API server
→ Uncordon node
```

---

# Drain Node

```bash id="9px2tp"
kubectl drain <node> --ignore-daemonsets
```

Purpose:

* safely evict workloads

---

# Upgrade Packages

Depending on distribution:

* kubeadm
* kubelet
* kubectl
* managed service APIs

---

# Uncordon

```bash id="rjlj6l"
kubectl uncordon <node>
```

---

# HA Enterprise Flow

In multi-master setup:

```text id="q7o93x"
Master-1 → Master-2 → Master-3
```

One at a time.

Reason:

* Maintain quorum
* Maintain API availability

---

# 7. Upgrade Worker Nodes

Worker nodes upgraded gradually.

---

# Enterprise Standard Process

Per node:

```text id="hhivgt"
Cordoning
→ Draining
→ Upgrade packages
→ Restart services
→ Uncordon
```

---

# Cordoning

Prevent new pods:

```bash id="r8aehw"
kubectl cordon <node>
```

---

# Drain Node

Move workloads safely:

```bash id="i0n0dy"
kubectl drain <node> --ignore-daemonsets
```

```bash id="l6m9zv"
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
```

---

# Upgrade Node Components

Upgrade:

* kubelet
* kubectl
* runtime dependencies

---

# Restart Services

```bash id="ehx6mk"
systemctl restart kubelet
```

---

# Bring Node Back

```bash id="mof7ic"
kubectl uncordon <node>
```

---

# Repeat Rolling Upgrade

Do one worker at a time.

Enterprise reason:

* Avoid outage
* Maintain HA
* Maintain application availability

---

# 8. Upgrade Cluster Addons

Very commonly forgotten.

---

# Upgrade:

| Addon              | Examples         |
| ------------------ | ---------------- |
| DNS                | CoreDNS          |
| Network Plugin     | Calico/Cilium    |
| kube-proxy         | Node networking  |
| CNI plugin         | Pod networking   |
| Metrics Server     | Resource metrics |
| Ingress Controller | NGINX/Traefik    |
| CSI Drivers        | Storage plugins  |
| Cert-manager       | Certificates     |

---

# 9. Validate Cluster After Upgrade

---

## Node Validation

```bash id="5rx9np"
kubectl get nodes
```

---

## Pod Validation

```bash id="i4g0q4"
kubectl get pods -A
```

---

## API Validation

```bash id="xv8u25"
kubectl version
```

```bash id="rqmb6l"
kubectl api-resources
```

---

## Test Application Deployment

```bash id="4lccbd"
kubectl create deployment nginx --image=nginx
```

---

## Application Validation

Check:

* Application login
* APIs
* Database connectivity
* Ingress traffic
* Storage mounts

---

# 10. Monitor Cluster Carefully

After upgrade monitor:

* CPU
* Memory
* Network
* Pod restarts
* API latency
* etcd latency
* Node readiness

Usually for:

* 24–48 hours in production

---

# 11. Cleanup Old Resources

Remove:

* deprecated APIs
* unused images
* old node packages
* old snapshots if policy allows

---

# 12. Rollback Strategy

Always prepare rollback:

```text id="a0k3p3"
Backup etcd
→ Restore previous node image/snapshot
→ Downgrade binaries if supported
→ Restore workloads
```

---

# Enterprise Best Practices

## Use Staging First

Never directly upgrade production.

Flow:

```text id="9v6rjf"
DEV → QA → UAT → PROD
```

---

# Use Maintenance Window

Production upgrades usually happen:

* Weekend
* Night hours
* Low traffic period

---

# Use Automation

Enterprise tools:

* Ansible
* GitOps
* ArgoCD
* Terraform
* Cluster API

---

# Upgrade Order (Golden Rule)

```text id="8g6ktd"
etcd
→ Control Plane
→ Worker Nodes
→ Addons
→ Applications
```

---

# Important Enterprise Risks

| Risk                | Impact           |
| ------------------- | ---------------- |
| API Deprecation     | Apps fail        |
| CNI mismatch        | Network outage   |
| CSI incompatibility | Storage failure  |
| etcd corruption     | Cluster failure  |
| Ingress mismatch    | Traffic outage   |
| Version skew        | Node instability |

---

# Real Enterprise Example

```text id="ow7ofv"
Current Cluster: 1.27
Target Cluster : 1.28

1. Backup etcd
2. Validate addons
3. Upgrade masters one-by-one
4. Upgrade workers rolling method
5. Upgrade Calico + CoreDNS
6. Validate applications
7. Monitor
```

---

# Simplified Visual Architecture

```text id="u1n4hk"
                +------------------+
                |  Load Balancer   |
                +------------------+
                          |
          ---------------------------------
          |               |               |
    Control Plane1  Control Plane2  Control Plane3
          |
    Upgrade Sequentially
          |
    ---------------------
    |         |         |
 Worker1   Worker2   Worker3
    |
 Rolling Upgrade
```

---

# Core Enterprise Principle

> Kubernetes upgrades are not just “package upgrades.”

They are:

* Infrastructure upgrades
* Platform upgrades
* API lifecycle upgrades
* Application compatibility upgrades
* Operational risk management activities

