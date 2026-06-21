Installing a **CSI (Container Storage Interface) Driver** on Kubernetes depends on the storage backend (AWS EBS, EFS, Azure Disk, Azure Files, GCE PD, Ceph, NetApp, etc.), but the overall process is similar.

## CSI Installation Workflow

```text
Step 1: Create Kubernetes Cluster
          ↓
Step 2: Install CSI Driver
          ↓
Step 3: Create StorageClass
          ↓
Step 4: Create PVC
          ↓
Step 5: CSI Driver Provisions Storage
          ↓
Step 6: Pod Uses PVC
```



# Step 1: Verify Cluster

```bash
# Check cluster health:
kubectl get nodes
kubectl get pods -A

# Expected:
NAME       STATUS   ROLES
master     Ready    control-plane
worker1    Ready
worker2    Ready
```


# Step 2: Install CSI Driver

The CSI driver is usually deployed as:

| Component   | Purpose                                     |
| ----------- | ------------------------------------------- |
| Controller  | Creates/deletes volumes                     |
| Node Plugin | Mounts volumes on nodes                     |
| Sidecars    | Provisioner, Attacher, Resizer, Snapshotter |


## Example: AWS EBS CSI Driver

```bash
# Install via Helm:
helm repo add aws-ebs-csi-driver \
https://kubernetes-sigs.github.io/aws-ebs-csi-driver

helm repo update

# Install driver:
helm install aws-ebs-csi-driver \
aws-ebs-csi-driver/aws-ebs-csi-driver \
-n kube-system

# Verify:
kubectl get pods -n kube-system

# Example:
ebs-csi-controller-xxxxx    Running
ebs-csi-node-yyyyy          Running
```



# Step 3: Verify CSI Driver Registration

```bash
kubectl get csidrivers

# Output:
NAME
ebs.csi.aws.com
```

This confirms Kubernetes recognizes the CSI driver.



# Step 4: Create StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
parameters:
  type: gp3
```

```bash
# Apply:
kubectl apply -f storageclass.yaml

# Verify:
kubectl get sc
```



# Step 5: Create PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 10Gi
```

```bash
# Apply:
kubectl apply -f pvc.yaml

# Verify:
kubectl get pvc

# Output:
NAME      STATUS   VOLUME
app-pvc   Bound    pvc-xxxx
```

At this stage, the CSI driver automatically creates an EBS volume.



# Step 6: Deploy Pod Using PVC

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: app-pvc
```


```bash
# Apply:
kubectl apply -f pod.yaml

# Verify:
kubectl exec -it nginx -- df -h
```

You should see the mounted volume inside the container.



### What Happens Internally?

```text
PVC Created
    ↓
CSI Provisioner Receives Request
    ↓
Cloud Storage Created
(EBS Volume)
    ↓
PV Created Automatically
    ↓
PVC Bound to PV
    ↓
Pod Scheduled
    ↓
CSI Node Plugin Attaches Volume
    ↓
Volume Mounted Inside Container
```



