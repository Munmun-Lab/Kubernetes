## Project : E-Commerce Application

### Components

| Component      | Purpose                        | Storage Needed |
| -------------- | ------------------------------ | -------------- |
| Frontend Pods  | React/Angular UI               | No             |
| Backend Pods   | APIs                           | No             |
| MySQL Database | Stores orders, users, products | Yes            |
| Logs/Backups   | Persistent data                | Yes            |


## Architecture

```text
Users
  │
  ▼
Frontend Pods
  │
  ▼
Backend Pods
  │
  ▼
MySQL Pod
  │
  ▼
PVC
  │
  ▼
StorageClass
  │
  ▼
AWS EBS Volume
```


### Production Storage Workflow

1. StorageClass
2. PVC
3. StatefulSet


### What Happens Behind the Scenes

1. Step 1: StatefulSet created -> mysql-0

2. Step 2: Kubernetes automatically creates PVC -> mysql-storage-mysql-0

3. Step 3: EBS CSI Driver provisions an EBS volume -> vol-123456

4. Step 4: Volume attached to worker node
        Worker Node
        │
        └── EBS Volume

5. Step 5: MySQL stores data: /var/lib/mysql


### Pod Restart Scenario

Suppose: mysql-0 running on Node-1 (AZ-a)

Node crashes, Kubernetes recreates: mysql-0

If another node exists in the **same AZ**, the existing EBS volume is detached from Node-1 and attached to Node-2. No data loss.

- Same PVC
- Same EBS Volume
- Same Data


### Enterprise Production Examples

| Application              | Storage |
| ------------------------ | ------- |
| MySQL                    | EBS     |
| PostgreSQL               | EBS     |
| MongoDB                  | EBS     |
| Elasticsearch            | EBS     |
| Kafka                    | EBS     |
| Jenkins Home             | EFS/EBS |
| Shared Application Files | EFS     |
| Images/Videos/Backups    | S3      |

> For companies such as Netflix, Amazon, and Uber, databases typically use block storage (EBS-like), while large media files, logs, backups, and analytics data are often stored in object storage such as S3. Stateful applications generally run as StatefulSets with persistent volumes rather than using ephemeral pod storage.


