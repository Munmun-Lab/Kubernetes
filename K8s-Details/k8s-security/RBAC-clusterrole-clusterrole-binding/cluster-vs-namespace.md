# Kubernetes Namespace-Level vs Cluster-Level Resources

Understanding which resources belong to a **namespace** and which belong to the **entire cluster** is important for RBAC and administration.

| Resource                    | Scope     | Description                    |
| --------------------------- | --------- | ------------------------------ |
| Pod                         | Namespace | Smallest deployable unit       |
| Deployment                  | Namespace | Manages pod replicas           |
| ReplicaSet                  | Namespace | Maintains pod count            |
| StatefulSet                 | Namespace | Stateful applications          |
| DaemonSet                   | Namespace | Runs pod on every node         |
| Job                         | Namespace | One-time task                  |
| CronJob                     | Namespace | Scheduled task                 |
| Service                     | Namespace | Exposes application            |
| Ingress                     | Namespace | HTTP/HTTPS routing             |
| ConfigMap                   | Namespace | Configuration data             |
| Secret                      | Namespace | Sensitive data                 |
| PersistentVolumeClaim (PVC) | Namespace | Storage request                |
| ServiceAccount              | Namespace | Pod identity                   |
| Role                        | Namespace | Namespace-specific permissions |
| RoleBinding                 | Namespace | Assigns Role                   |
| NetworkPolicy               | Namespace | Controls pod traffic           |
| ResourceQuota               | Namespace | Resource limits                |
| LimitRange                  | Namespace | Resource constraints           |

---

# Cluster-Level Resources

These resources belong to the entire cluster and are not tied to any namespace.

| Resource                       | Scope   | Description                     |
| ------------------------------ | ------- | ------------------------------- |
| Node                           | Cluster | Worker machine                  |
| Namespace                      | Cluster | Logical isolation boundary      |
| PersistentVolume (PV)          | Cluster | Storage resource                |
| ClusterRole                    | Cluster | Cluster-wide permissions        |
| ClusterRoleBinding             | Cluster | Assigns ClusterRole             |
| StorageClass                   | Cluster | Storage provisioning            |
| CustomResourceDefinition (CRD) | Cluster | Custom Kubernetes API           |
| MutatingWebhookConfiguration   | Cluster | Admission controller            |
| ValidatingWebhookConfiguration | Cluster | Admission controller            |
| PriorityClass                  | Cluster | Pod scheduling priority         |
| APIService                     | Cluster | API extension                   |
| RuntimeClass                   | Cluster | Container runtime configuration |
| VolumeSnapshotClass            | Cluster | Snapshot configuration          |

---

# Easy Way to Remember

### Namespace Resources

These are usually **application-related resources**:

```text
Pods
Deployments
Services
Ingress
Secrets
ConfigMaps
PVCs
Jobs
CronJobs
```

Think:

```text
Application lives inside a namespace
```

---

### Cluster Resources

These are usually **infrastructure-related resources**:

```text
Nodes
Namespaces
StorageClasses
ClusterRoles
ClusterRoleBindings
PersistentVolumes
CRDs
```

Think:

```text
Infrastructure belongs to the entire cluster
```

---

# How to Verify

### List Namespace Resources

```bash
kubectl api-resources --namespaced=true
```

Sample Output:

```text
pods
services
deployments
configmaps
secrets
```

---

### List Cluster Resources

```bash
kubectl api-resources --namespaced=false
```

Sample Output:

```text
nodes
namespaces
persistentvolumes
storageclasses
clusterroles
clusterrolebindings
```

---

# RBAC Mapping

| Resource Type      | RBAC Object Used                 |
| ------------------ | -------------------------------- |
| Namespace Resource | Role + RoleBinding               |
| Cluster Resource   | ClusterRole + ClusterRoleBinding |

