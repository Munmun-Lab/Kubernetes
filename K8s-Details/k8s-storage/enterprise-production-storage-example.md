## Enterprise Production - E-Commerce Application on AWS EKS

An online shopping application consisting of:
- Frontend (React)
- Backend (Java/Spring Boot)
- Database (MySQL)
- Shared Uploads (Images/Documents)


## Architecture

```text
                    Internet
                        │
                AWS Load Balancer
                        │
                    Ingress
                        │
        ┌───────────────┼───────────────┐
        │                               │
   Frontend Pods                  Backend Pods
   (Deployment)                   (Deployment)
        │                               │
        └───────────────┬───────────────┘
                        │
                 Shared Storage
                    Amazon EFS
                        │
                        │
                Uploaded Images
                        │

                 MySQL StatefulSet
                        │
                      PVC
                        │
                  StorageClass
                        │
                  EBS CSI Driver
                        │
                  AWS EBS Volume
```

## Why Two Different Storage Types? (EFS & EBS)

### Application Storage

Frontend and Backend Pods need shared access (/uploads/product-images) and using Amazon EFS.
Because accessModes (ReadWriteMany (RWX)), this means multiple pods can read/write simultaneously.

Example:

frontend-1
frontend-2
backend-1
backend-2


### Database Storage

MySQL requires dedicated disk, using here Amazon EBS.
Beacuse it supports: 
    - High IOPS
    - Low latency
    - Persistent block storage



## Production StatefulSet

Instead of Pod use StatefulSet 

Example:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 1

  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes:
      - ReadWriteOnce
      storageClassName: mysql-gold-storage
      resources:
        requests:
          storage: 100Gi
```


## Backup Architecture

Production never relies only on EBS. Hence EBS Volume Backup saved in S3 bucket.

MySQL -> EBS Volume -> Volume Snapshot -> AWS Backup -> S3

Backup schedule:
- Daily Snapshot
- Weekly Full Backup
- Monthly Archive

## Monitoring

PVC Usage -> Prometheus -> Grafana

Monitor:
* Disk Usage %
* IOPS
* Throughput
* Latency
* Volume Health

## Disaster Recovery

If the primary region fails:
* Restore Snapshot
* Create New Volume
* Attach to New Cluster

```text
Primary Region
(ap-south-1)

       │
Snapshot Replication

       ▼

Secondary Region
(ap-southeast-1)
```

##  Enterprise Security

- Encryption at Rest:  EBS Volume -> AWS KMS Key
- Encryption in Transit: Pod -> TLS -> Storage
- Access Control: IAM Role -> EBS CSI Driver -> Create/Delete Volumes


## Production Workflow

```text
1. Developer Deploys MySQL StatefulSet
                 │
2. StatefulSet Creates PVC
                 │
3. PVC Requests 100Gi Storage
                 │
4. StorageClass Receives Request
                 │
5. EBS CSI Driver Creates EBS Volume
                 │
6. Kubernetes Creates PV
                 │
7. PVC Bound To PV
                 │
8. MySQL Pod Mounts Volume
                 │
9. Application Stores Data
                 │
10. Snapshots Taken Daily
                 │
11. Prometheus Monitors Storage
                 │
12. Disaster Recovery Copies Created
```


## **production-style Kubernetes storage deployment** for **MySQL on AWS EKS** using:

* StorageClass (gp3 EBS)
* StatefulSet
* Headless Service
* VolumeClaimTemplate (auto PVC creation)

**enterprise-storage.yaml**



### Verification Commands

```bash
kubectl get storageclass

kubectl get pvc

kubectl get pv

kubectl get pods

kubectl describe pvc mysql-data-mysql-0

kubectl exec -it mysql-0 -- df -h
```

### Resources Created

* mysql-gold-storage     (StorageClass)

* mysql-secret           (Secret)

* mysql                  (Headless Service)

* mysql-0                (StatefulSet Pod)

* mysql-data-mysql-0     (PVC)

* pvc-xxxxxxxx           (PV)

* AWS EBS Volume         (Actual Storage)


This is a production pattern for MySQL/PostgreSQL databases running on AWS EKS, with dynamic provisioning through the EBS CSI Driver, encrypted storage, retained volumes, and StatefulSet-managed persistence.


### Enterprise EKS Storage Strategy

| Workload                    | Typical Storage            |
| --------------------------- | -------------------------- |
| Kubernetes application data | EBS                        |
| Shared files/configurations | EFS                        |
| Images, videos, backups     | S3                         |
| Databases                   | EBS + Database replication |
| Logs & analytics            | S3 / Data Lake             |
| Cache                       | Redis / Memory             |
