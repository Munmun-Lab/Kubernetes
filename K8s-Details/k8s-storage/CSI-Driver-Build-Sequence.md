The **best practice is to install the CSI driver immediately after the Kubernetes/EKS cluster is created**, before deploying any applications that need storage.

## Typical Production Build Sequence

```text
1. Create EKS Cluster
        ↓
2. Install Core Add-ons
   - VPC CNI
   - CoreDNS
   - kube-proxy
        ↓
3. Install CSI Drivers
   - EBS CSI Driver
   - EFS CSI Driver (if needed)
   - S3 CSI Driver (if needed)
        ↓
4. Create StorageClasses
        ↓
5. Deploy Applications
        ↓
6. Create PVCs
        ↓
7. Pods Mount Volumes
```


## Example: EBS CSI Driver

- Step 1 - Create Cluster:  eksctl create cluster ...
- Step 2 - Install EBS CSI Driver: eksctl create addon --name aws-ebs-csi-driver --cluster my-cluster
    - or via Helm.

- Step 3 - Verify: kubectl get csidrivers

    - Output: NAME - ebs.csi.aws.com

- Step 4 - Create StorageClass: 
    - kind: StorageClass
    - provisioner: ebs.csi.aws.com

- Step 5 - Deploy Application: Deployment -> PVC -> StorageClass


## Simple Rule/order for installation

1. CSI Driver 
2. StorageClass 
3. PVC 
4. Pod 



