#!/bin/bash
#
# ============================================================
# Kubernetes Cluster Restore & Rollback Helper Script
# ============================================================
#
# Purpose:
# Recover Kubernetes cluster after upgrade failure/disaster
#
# Covers:
# - etcd restore
# - Kubernetes rollback
# - Service restart
# - Cluster validation
#
# ============================================================


# ============================================================
# set -e
# ============================================================
#
# Meaning:
# Stop script immediately if any command fails
#
# Why Important:
# Prevents partial restore/rollback execution
#
# Example:
# If etcd restore fails,
# script should stop immediately
#
# ============================================================

set -e



# ============================================================
# Environment Variables
# ============================================================

#
# ETCD_BACKUP
# Location of etcd snapshot backup file
#

ETCD_BACKUP="/backup/etcd-backup.db"


#
# ETCD_RESTORE_DIR
# Temporary directory used during etcd restore
#

ETCD_RESTORE_DIR="/var/lib/etcd-restore"


#
# K8S_VERSION_PREVIOUS
# Previous stable Kubernetes version
# used for rollback
#

K8S_VERSION_PREVIOUS="1.28.5"


#
# CONTROL_PLANE_NODE
# Kubernetes master/control-plane hostname
#

CONTROL_PLANE_NODE="master-node"


#
# WORKER_NODE
# Kubernetes worker node hostname
#

WORKER_NODE="worker-node1"



# ============================================================
# STEP 1 - Validate Backup File
# ============================================================

echo "========== STEP 1 : Checking Backup =========="

#
# Validate whether backup file exists
#

if [ ! -f "$ETCD_BACKUP" ]; then

    echo "ERROR: etcd backup not found!"

    #
    # exit 1
    # Means:
    # terminate script with failure status
    #

    exit 1

fi

echo "Backup file exists."



# ============================================================
# STEP 2 - Drain Kubernetes Nodes
# ============================================================

echo "========== STEP 2 : Draining Nodes =========="

#
# kubectl drain
#
# Purpose:
# Safely evict workloads from node
#
# --ignore-daemonsets
# Ignore daemonset-managed pods
#
# --delete-emptydir-data
# Remove temporary pod storage
#
# || true
# Ignore command failure and continue
#

kubectl drain $CONTROL_PLANE_NODE \
--ignore-daemonsets \
--delete-emptydir-data || true


kubectl drain $WORKER_NODE \
--ignore-daemonsets \
--delete-emptydir-data || true



# ============================================================
# STEP 3 - Stop Kubernetes Services
# ============================================================

echo "========== STEP 3 : Stopping Services =========="

#
# Stop kubelet service
#

systemctl stop kubelet || true


#
# Stop etcd database service
#

systemctl stop etcd || true



# ============================================================
# STEP 4 - Restore etcd Snapshot
# ============================================================

echo "========== STEP 4 : Restoring etcd =========="

#
# ETCDCTL_API=3
# Use etcd API version 3
#

#
# etcdctl snapshot restore
# Restore etcd database snapshot
#

#
# --data-dir
# Target restore location
#

ETCDCTL_API=3 etcdctl snapshot restore $ETCD_BACKUP \
--data-dir $ETCD_RESTORE_DIR


echo "etcd restore completed."



# ============================================================
# STEP 5 - Replace Existing etcd Data
# ============================================================

echo "========== STEP 5 : Replacing etcd Data =========="

#
# Backup current etcd directory
#

mv /var/lib/etcd \
/var/lib/etcd-old-$(date +%F-%H%M%S) || true


#
# Move restored etcd data
#

mv $ETCD_RESTORE_DIR /var/lib/etcd



# ============================================================
# STEP 6 - Rollback Kubernetes Packages
# ============================================================

echo "========== STEP 6 : Rolling Back Kubernetes Version =========="

#
# Refresh package repository
#

apt-get update


#
# Install previous Kubernetes version
#
# Components:
# - kubeadm
# - kubelet
# - kubectl
#

apt-get install -y \
kubeadm=$K8S_VERSION_PREVIOUS-1.1 \
kubelet=$K8S_VERSION_PREVIOUS-1.1 \
kubectl=$K8S_VERSION_PREVIOUS-1.1


#
# Prevent automatic package upgrade
#

apt-mark hold kubeadm kubelet kubectl



# ============================================================
# STEP 7 - Restart Kubernetes Services
# ============================================================

echo "========== STEP 7 : Restarting Services =========="

#
# Reload systemd daemon
#

systemctl daemon-reload


#
# Restart etcd database
#

systemctl restart etcd || true


#
# Restart kubelet node agent
#

systemctl restart kubelet



# ============================================================
# STEP 8 - Reload Kubernetes Config
# ============================================================

echo "========== STEP 8 : Reloading Cluster Config =========="

#
# KUBECONFIG
# Kubernetes admin authentication file
#

export KUBECONFIG=/etc/kubernetes/admin.conf


#
# Wait for cluster stabilization
#

sleep 15



# ============================================================
# STEP 9 - Uncordon Kubernetes Nodes
# ============================================================

echo "========== STEP 9 : Uncordoning Nodes =========="

#
# kubectl uncordon
#
# Allow scheduling pods again
#

kubectl uncordon $CONTROL_PLANE_NODE || true

kubectl uncordon $WORKER_NODE || true



# ============================================================
# STEP 10 - Validate Cluster Health
# ============================================================

echo "========== STEP 10 : Cluster Validation =========="

#
# Verify node health
#

kubectl get nodes


#
# Verify all pods
#

kubectl get pods -A



# ============================================================
# Final Status
# ============================================================

echo "========== Cluster Restore & Rollback Completed =========="
