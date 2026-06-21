# Calico Troubleshooting Steps (AWS EC2)

After installing Calico, Calico pods are not ready & CrashLoopBackOff error showing:

```bash
-> kubectl get pods -A

# Output similar to:
calico-node                CrashLoopBackOff
calico-node                Error
calico-node                Init:0/3

-> kubectl get nodes

#shows:
NotReady
```

To Troubleshoot this follwed the below steps..


## 1. Disable Source/Destination Check

AWS VPC networking can interfere with pod networking if Source/Destination Check is enabled.

Performed on ALL nodes and disabled..

```text
AWS Console                      
 → EC2
 → Instances
 → Select Instance
 → Actions
 → Networking
 → Change Source/Destination Check
 → Disable
```


## 2. Configure Security Group Rule for Calico BGP

Calico uses BGP (TCP 179) for node-to-node route exchange.
Added the following rule to both Master and Worker Security Groups to ensure traffic is allowed in both directions.

| Type       | Protocol | Port |
| ---------- | -------- | ---- |
| Custom TCP | TCP      | 179  |

Source:  0.0.0.0/0

```text
# Or, Creating a security group,
Master Security Group
Worker Security Group
```


## 3. Verify Node Interface

Find the primary network interface on every node:

```bash
ip addr  # or 
ifconfig

# Example: ens5
```

AWS Nitro instances typically use: ens5

Older instances may use: eth0


## 4. Configure Calico Interface Auto Detection

```bash
# Check current daemonset:
kubectl get ds -n calico-system

# Update Calico:
kubectl set env daemonset/calico-node \
-n calico-system \
IP_AUTODETECTION_METHOD=interface=ens5

# Example output:
daemonset.apps/calico-node env updated

# Replace with actual interface name if different.
ens5 or eth0
```


## 5. Restart Calico Pods

```bash
# Wait a few minutes or restart manually.
kubectl delete pods -n calico-system --all

# Check status:
kubectl get pods -n calico-system -w

# Expected:
calico-node                     Running
calico-kube-controllers         Running
```


## 6. Verify Node Health

```bash
kubectl get nodes

# Expected:
NAME           STATUS
k8s-master     Ready
k8s-worker1    Ready
k8s-worker2    Ready
```


## Verify Calico Logs

```bash
# If still failing:
kubectl logs -n calico-system \            
-l k8s-app=calico-node                 # select all pods that have the level, k8s-app: calico-node

or

kubectl describe pod <calico-pod-name> \
-n calico-system
```

Common issues:

| Error                       | Cause                   |
| --------------------------- | ----------------------- |
| BIRD not ready              | TCP 179 blocked         |
| Failed to autodetect IP     | Wrong interface         |
| Pod sandbox creation failed | CNI issue               |
| Connection refused          | API server access issue |



# Alternative Workaround (Manifest Installation)

If the Operator-based installation continues to fail, we can use use the legacy manifest deployment. But recommendation is. to use the manifest-based installation only as a troubleshooting fallback or for lab environments.

```bash
# Remove current installation:
kubectl delete installation default
kubectl delete ns calico-system

# Install Calico Manifest:
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

This deploys Calico components into **kube-system** instead of **calico-system**

# Verify:
kubectl get pods -n kube-system

# Expected all pods are running on all nodes:
calico-node
calico-kube-controllers
coredns
```



For Kubernetes v1.33, prefer:

```text
Calico Operator
      +
Tigera Operator
      +
custom-resources.yaml
```

because:
* Easier upgrades
* Better lifecycle management
* Current supported deployment model
* Used in production Kubernetes environments


