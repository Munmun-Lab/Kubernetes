# Complete PV-PVC Workflow with Example (AWS EKS + EBS)

This example is to deploy an NGINX application and store website data persistently.


## Step 1: StorageClass Created

A StorageClass tells Kubernetes **how to create storage dynamically**.

### Example - storageclass.yaml

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3-storage
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
volumeBindingMode: WaitForFirstConsumer
```

** Kubernetes -> StorageClass -> AWS EBS CSI Driver**

StorageClass is now ready to create EBS volumes whenever requested.

---

## Step 2: PVC Created

Application requests storage through a PVC.

### Example - pvc.yaml

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3-storage
  resources:
    requests:
      storage: 5Gi
```

Apply:

```bash
kubectl apply -f pvc.yaml
```

** Application -> Needs 5Gi Storage -> PVC Created**

At this point: PVC is waiting for storage.

```bash
kubectl get pvc

Output:

NAME        STATUS    VOLUME
nginx-pvc   Pending
```

---

## Step 3: StorageClass Provisions PV

Kubernetes detects:
- PVC requesting 5Gi
- Using StorageClass gp3-storage

The AWS EBS CSI Driver automatically creates an EBS volume.

PVC -> StorageClass -> EBS CSI Driver -> Creates AWS EBS Volume -> Creates PV

Automatically generated PV: No manual PV creation required.

```bash
kubectl get pv

Example:

pvc-abc123   5Gi   RWO   Bound
```

---

## Step 4: PVC Bound to PV

Now Kubernetes links the PVC with the newly created PV.

### Relationship

```text
PVC nginx-pvc -> Bound -> PV pvc-abc123 -> AWS EBS Volume
```

Verification:

```bash
kubectl get pvc

Output:

NAME        STATUS   VOLUME
nginx-pvc   Bound    pvc-abc123
```

PVC = Storage Request
PV  = Actual Storage
The request has now been fulfilled.

---

## Step 5: Pod Uses PVC

The Pod mounts the PVC.

### Example - pod.yaml

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
    - name: web-data
      mountPath: /usr/share/nginx/html

  volumes:
  - name: web-data
    persistentVolumeClaim:
      claimName: nginx-pvc
```

Apply:

```bash
kubectl apply -f pod.yaml
```

### What Happens?

```text
Pod -> Uses PVC -> PVC Connected to PV -> PV Connected to EBS Volume
Storage is now available inside the container.
```

---

## Step 6: Application Stores Data

Application writes data to the mounted path.

Example: Get inside container(nginx)

```bash
kubectl exec -it nginx -- sh
```

Inside container:

```bash
echo "Welcome to Kubernetes Storage" > /usr/share/nginx/html/index.html
```

### Data Flow

```text
NGINX Container
      ↓
/usr/share/nginx/html
      ↓
PVC
      ↓
PV
      ↓
AWS EBS Volume
```

---

## Persistence Test

```bash
# Delete the Pod:
kubectl delete pod nginx

# Create it again:
kubectl apply -f pod.yaml

# Check file:
kubectl exec -it nginx -- cat /usr/share/nginx/html/index.html

# Output:
Welcome to Kubernetes Storage
```

The data still exists because it was stored on the EBS volume, not inside the container.

---

# Visual End-to-End Flow

```text
1. StorageClass Created
        ↓
   gp3-storage

2. PVC Created
        ↓
   nginx-pvc (5Gi)

3. Dynamic Provisioning
        ↓
   AWS EBS CSI Driver

4. PV Created Automatically
        ↓
   pv-abc123

5. PVC Bound to PV
        ↓
   nginx-pvc ↔ pv-abc123

6. Pod Uses PVC
        ↓
   NGINX Pod

7. Data Written
        ↓
   /usr/share/nginx/html

8. Stored On
        ↓
   AWS EBS Volume
```

### Inshort Explanation 

> A StorageClass defines how storage should be provisioned. An application creates a PVC requesting storage. Kubernetes uses the StorageClass and CSI driver to dynamically create a PV. The PVC is bound to the PV, and Pods mount the PVC. Any data written by the application is stored on the underlying storage backend (such as AWS EBS), so the data persists even if the Pod is deleted and recreated.

