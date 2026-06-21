# Kubernetes Storage & Volumes

| Topic         | Details                 |
| ------------- | ----------------------- |
| Volumes       | Persistent storage      |
| emptyDir      | Temporary storage       |
| hostPath      | Host storage            |
| PV            | Persistent Volume       |
| PVC           | Persistent Volume Claim |
| StorageClass  | Dynamic provisioning    |
| CSI Drivers   | Storage integration     |
| NFS Storage   | Shared storage          |
| Ceph Storage  | Distributed storage     |
| Cloud Storage | AWS EBS, Azure Disk     |


## Definition

**Kubernetes Volume** is a storage mechanism that allows containers in a Pod to store and share data. Unlike container storage, which is lost when a container restarts, Kubernetes volumes can persist data and make it available across container restarts or Pod recreations.

### Why Storage is Needed?

Without volumes:

* Data is stored inside the container.
* Data is lost when the container restarts or is deleted.

With volumes:

* Data survives container restarts.
* Multiple containers can share data.
* Applications can use persistent storage.

---

# Kubernetes Storage Components

| Topic         | Definition                                       | Use Case                      |
| ------------- | ------------------------------------------------ | ----------------------------- |
| Volumes       | Storage attached to a Pod                        | Store application data        |
| emptyDir      | Temporary storage created with Pod               | Cache, temporary files        |
| hostPath      | Uses node's local filesystem                     | Testing, local development    |
| PV            | Cluster storage resource                         | Persistent data               |
| PVC           | Request for storage by application               | Database storage              |
| StorageClass  | Defines storage provisioning method              | Dynamic storage creation      |
| CSI Driver    | Interface between Kubernetes and storage systems | Connect cloud/NAS/SAN storage |
| NFS Storage   | Shared network storage                           | Shared files across Pods      |
| Ceph Storage  | Distributed storage platform                     | Enterprise storage            |
| Cloud Storage | AWS EBS, Azure Disk, GCP PD                      | Cloud-native storage          |

---

# 1. Kubernetes Volume

### Definition

A Volume is storage attached to a Pod that exists for the Pod's lifetime.

### Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-volume
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: web-storage

  volumes:
  - name: web-storage
    emptyDir: {}
```

### Architecture

```text
Pod
 ├── Container 1
 ├── Container 2
 └── Volume
```

Both containers can access the same volume.

---

# 2. emptyDir Volume

### Definition

Temporary storage created when a Pod starts and deleted when the Pod is removed.

### Characteristics

✅ Shared between containers

✅ Fast access

❌ Data lost when Pod is deleted

### Example

```yaml
volumes:
- name: cache-volume
  emptyDir: {}
```

### Use Cases

* Cache files
* Temporary logs
* Scratch space
* Data sharing between containers

### Lifecycle

```text
Pod Starts
    ↓
emptyDir Created
    ↓
Data Written
    ↓
Pod Deleted
    ↓
Data Lost
```

---

# 3. hostPath Volume

### Definition

Mounts a directory from the Kubernetes worker node into a Pod.

### Example

```yaml
volumes:
- name: host-storage
  hostPath:
    path: /data
```

### Architecture

```text
Worker Node
 └── /data
      ↓
     Pod
```

### Use Cases

* Local development
* Log collection
* Monitoring agents

### Limitation

If Pod moves to another node:

```text
Node1 Data ≠ Node2 Data
```

Therefore, not recommended for production workloads.

---

# 4. Persistent Volume (PV)

### Definition

A cluster-wide storage resource created by administrators.

### Example

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-demo
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/pv
```

### Think of PV As

```text
Storage Disk
     ↓
Persistent Volume
```

### Benefits

* Independent of Pod lifecycle
* Reusable
* Persistent

---

# 5. Persistent Volume Claim (PVC)

### Definition

A request for storage made by applications.

### Example

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-demo
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### Relationship

```text
Application
     ↓
PVC
     ↓
PV
     ↓
Storage
```

### Verification

```bash
kubectl get pvc
kubectl get pv
```

---

# 6. StorageClass

### Definition

Automates storage creation without manually creating PVs.

### Traditional Method

```text
Admin Creates PV
        ↓
Application Creates PVC
```

### Dynamic Provisioning

```text
StorageClass
      ↓
PVC Created
      ↓
PV Auto Created
```

### Example

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: ebs.csi.aws.com
```

### Verify

```bash
kubectl get storageclass
```

---

# 7. CSI Driver (Container Storage Interface)

### Definition

Standard interface allowing Kubernetes to communicate with storage systems.

### Architecture

```text
Kubernetes
     ↓
CSI Driver
     ↓
Storage System
```

### Common CSI Drivers

| Platform | CSI Driver            |
| -------- | --------------------- |
| AWS      | EBS CSI Driver        |
| Azure    | Azure Disk CSI Driver |
| GCP      | GCE PD CSI Driver     |
| NFS      | NFS CSI Driver        |
| Ceph     | Ceph CSI Driver       |

### Example

AWS EBS CSI Driver provisions EBS volumes automatically when a PVC is created.

---

# 8. NFS Storage

### Definition

Network File System provides shared storage accessible by multiple Pods.

### Architecture

```text
           NFS Server
          /shared-data
         ↙     ↓     ↘
      Pod1   Pod2   Pod3
```

### Access Mode

```text
ReadWriteMany (RWX)
```

### Example

```yaml
volumes:
- name: nfs-volume
  nfs:
    server: 10.0.0.10
    path: /exports
```

### Use Cases

* Shared files
* CMS applications
* Web content
* Shared uploads

---

# 9. Ceph Storage

### Definition

Distributed storage platform providing block, file, and object storage.

### Architecture

```text
        Ceph Cluster
      ↙     ↓      ↘
   OSD1   OSD2   OSD3
      ↘     ↓      ↙
      Kubernetes
```

### Benefits

✅ Highly available

✅ Scalable

✅ Fault tolerant

✅ Production-grade

### Common Deployment

```text
Kubernetes + Rook Operator + Ceph
```

### Use Cases

* Databases
* Enterprise workloads
* Private Cloud

---

# 10. Cloud Storage

## AWS EBS

### Characteristics

```text
Volume Type: Block Storage
Access Mode: RWO
```

Architecture:

```text
EKS Pod- > PVC -> AWS EBS CSI -> EBS Volume
```


## Azure Disk

```text
AKS Pod -> PVC -> Azure Disk CSI -> Managed Disk
```


## GCP Persistent Disk

```text
GKE Pod -> PVC -> PD CSI Driver -> Persistent Disk
```


# Access Modes Explained

| Access Mode | Meaning                        |
| ----------- | ------------------------------ |
| RWO         | ReadWriteOnce (One Node)       |
| ROX         | ReadOnlyMany                   |
| RWX         | ReadWriteMany (Multiple Nodes) |
| RWOP        | ReadWriteOncePod               |

### Example

```text
RWO
Pod1 → Volume
Pod2 ✖
```

```text
RWX
Pod1 ✓
Pod2 ✓
Pod3 ✓
```

---

# Complete PV-PVC Workflow

```text
Step 1
StorageClass Created
        ↓
Step 2
PVC Created
        ↓
Step 3
StorageClass Provisions PV
        ↓
Step 4
PVC Bound to PV
        ↓
Step 5
Pod Uses PVC
        ↓
Step 6
Application Stores Data
```

---

# Production Best Practices

| Best Practice                          | Why                          |
| -------------------------------------- | ---------------------------- |
| Use StorageClass                       | Automatic provisioning       |
| Use CSI Drivers                        | Vendor-supported integration |
| Avoid hostPath in Production           | Node dependency              |
| Use RWX only when needed               | Better performance           |
| Enable Volume Snapshots                | Backup and recovery          |
| Use Separate StorageClass per workload | Better management            |
| Monitor storage utilization            | Prevent outages              |
| Encrypt storage volumes                | Security                     |
| Use StatefulSets for databases         | Stable storage mapping       |
| Test restore procedures regularly      | Disaster recovery            |

---

# Short Summary 

**Volume:** Storage attached to a Pod.

**emptyDir:** Temporary storage deleted with Pod.

**hostPath:** Uses worker node storage.

**PV:** Actual storage resource in Kubernetes.

**PVC:** Storage request by application.

**StorageClass:** Dynamic storage provisioning.

**CSI Driver:** Connects Kubernetes with storage systems.

**NFS:** Shared network storage (RWX).

**Ceph:** Distributed enterprise storage.

**Cloud Storage:** AWS EBS, Azure Disk, GCP Persistent Disk integrated through CSI drivers.

### One-Line Memory Trick

```text
Pod → PVC → PV → StorageClass → CSI Driver → Storage Backend
```
