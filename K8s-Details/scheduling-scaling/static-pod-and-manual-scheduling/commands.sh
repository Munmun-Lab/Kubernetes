#!/bin/bash

#################################################
# STATIC PODS LAB COMMANDS
#################################################

# Check static pod manifest directory
ls /etc/kubernetes/manifests/

# View existing static pod manifests
cat /etc/kubernetes/manifests/kube-apiserver.yaml
cat /etc/kubernetes/manifests/kube-scheduler.yaml
cat /etc/kubernetes/manifests/kube-controller-manager.yaml
cat /etc/kubernetes/manifests/etcd.yaml

# Check kubelet status
systemctl status kubelet

# Follow kubelet logs
journalctl -u kubelet -f

# Generate pod yaml
kubectl run nginx-static \
--image=nginx \
--dry-run=client \
-o yaml > nginx-static.yaml

# Move generated yaml to static pod location
sudo mv nginx-static.yaml \
/etc/kubernetes/manifests/

# Verify static pod
kubectl get pods -A

# Verify static pod node
kubectl get pods -A -o wide

# Describe static pod
kubectl describe pod nginx-static

# Edit static pod
sudo vi /etc/kubernetes/manifests/nginx-static.yaml

# Delete static pod
sudo rm /etc/kubernetes/manifests/nginx-static.yaml

# Verify deletion
kubectl get pods -A


#################################################
# MANUAL SCHEDULING LAB COMMANDS
#################################################

# Check cluster nodes
kubectl get nodes

# Check nodes with labels
kubectl get nodes --show-labels

# Create pod yaml manually
cat <<EOF > manual-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-manual
spec:
  nodeName: worker1
  containers:
  - name: nginx
    image: nginx
EOF

# Deploy pod
kubectl apply -f manual-pod.yaml

# Verify pod placement
kubectl get pods -o wide

# Describe pod
kubectl describe pod nginx-manual

# Verify all pods and nodes
kubectl get pods -A -o wide

# Delete pod
kubectl delete pod nginx-manual

# Verify deletion
kubectl get pods

#################################################
# TROUBLESHOOTING
#################################################

# Events
kubectl get events --sort-by=.metadata.creationTimestamp

# Pod logs
kubectl logs nginx-manual

# Scheduler logs
kubectl logs -n kube-system \
kube-scheduler-controlplane

#################################################
# END
#################################################