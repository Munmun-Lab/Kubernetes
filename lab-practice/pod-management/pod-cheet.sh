#!/bin/bash

# =========================================================
# Kubernetes POD Commands Cheat Sheet Script
# Purpose:
#   Collection of most-used kubectl pod commands
#   for learning, troubleshooting, YAML generation,
#   debugging, scaling, labeling, patching, etc.
#
# Usage:
#   chmod +x pod-commands.sh
#   ./pod-commands.sh
#
# NOTE:
#   Commands are grouped by category.
#   Some commands are commented for safety.
# =========================================================


echo "==============================================="
echo " Kubernetes POD Commands Reference Script"
echo "==============================================="


# =========================================================
# 1. CREATE PODS
# =========================================================

echo "1. Creating Pods"

# Create nginx pod
kubectl run nginx --image=nginx

# Create pod with custom image version
kubectl run nginx2 --image=nginx:1.25

# Create pod with labels
kubectl run nginx-label --image=nginx --labels="env=dev,app=web"

# Create pod with environment variable
kubectl run nginx-env --image=nginx --env="APP_ENV=DEV"

# Create pod with port exposed
kubectl run nginx-port --image=nginx --port=80

# Create interactive busybox pod
kubectl run busybox --image=busybox -it -- sh

# Create pod and remove after exit
kubectl run temp-busybox --image=busybox -it --rm -- sh

# Run pod in specific namespace
kubectl run nginx-ns --image=nginx -n dev

# Create pod with restart policy Never
kubectl run nginx-never --image=nginx --restart=Never

# Create pod with command
kubectl run ubuntu --image=ubuntu -- sleep 3600

# Create pod overriding command
kubectl run custom-cmd \
  --image=busybox \
  --command -- echo "Hello Kubernetes"


# =========================================================
# 2. GENERATE YAML / JSON
# =========================================================

echo "2. Generating YAML / JSON"

# Generate YAML without creating
kubectl run nginx \
  --image=nginx \
  --dry-run=client -o yaml > nginx-pod.yaml

# Generate JSON without creating
kubectl run nginx \
  --image=nginx \
  --dry-run=client -o json > pod-new.json

# Generate YAML with labels
kubectl run nginx \
  --image=nginx \
  --labels="app=nginx,env=prod" \
  --dry-run=client -o yaml > labeled-pod.yaml

# Generate YAML for busybox pod
kubectl run busybox \
  --image=busybox \
  --restart=Never \
  --dry-run=client -o yaml > busybox.yaml


# =========================================================
# 3. APPLY / DELETE PODS
# =========================================================

echo "3. Apply / Delete"

# Create from YAML
kubectl apply -f nginx-pod.yaml

# Create from JSON
kubectl apply -f pod-new.json

# Delete pod
kubectl delete pod nginx

# Force delete pod
kubectl delete pod nginx --force --grace-period=0

# Delete all pods
# kubectl delete pods --all

# Delete pod from namespace
kubectl delete pod nginx -n dev


# =========================================================
# 4. GET POD INFORMATION
# =========================================================

echo "4. Get Pod Information"

# List pods
kubectl get pods

# Wide output
kubectl get pods -o wide

# Show labels
kubectl get pods --show-labels

# Watch pods continuously
kubectl get pods -w

# Specific namespace
kubectl get pods -n kube-system

# Get pod YAML
kubectl get pod nginx -o yaml

# Get pod JSON
kubectl get pod nginx -o json

# Custom columns
kubectl get pods \
  -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# Sort by creation time
kubectl get pods --sort-by=.metadata.creationTimestamp


# =========================================================
# 5. DESCRIBE POD
# =========================================================

echo "5. Describe Pods"

kubectl describe pod nginx

kubectl describe pod nginx -n dev


# =========================================================
# 6. EXEC INTO POD
# =========================================================

echo "6. Exec Into Pod"

# Open shell
kubectl exec -it nginx -- /bin/bash

# Busybox shell
kubectl exec -it busybox -- sh

# Run single command
kubectl exec nginx -- ls /

# Multiple container pod
kubectl exec -it multi-container -c nginx -- bash


# =========================================================
# 7. LOGS
# =========================================================

echo "7. Logs"

# View logs
kubectl logs nginx

# Follow logs
kubectl logs -f nginx

# Previous logs
kubectl logs nginx --previous

# Multi-container logs
kubectl logs multi-container -c nginx

# Tail logs
kubectl logs nginx --tail=50

# Logs with timestamps
kubectl logs nginx --timestamps


# =========================================================
# 8. EDIT / PATCH PODS
# =========================================================

echo "8. Edit / Patch"

# Edit pod live
kubectl edit pod nginx

# Patch label
kubectl patch pod nginx \
  -p '{"metadata":{"labels":{"env":"prod"}}}'

# Add annotation
kubectl annotate pod nginx owner=devops

# Remove annotation
kubectl annotate pod nginx owner-


# =========================================================
# 9. LABELS & SELECTORS
# =========================================================

echo "9. Labels & Selectors"

# Add label
kubectl label pod nginx env=dev

# Overwrite label
kubectl label pod nginx env=prod --overwrite

# Remove label
kubectl label pod nginx env-

# Filter using label
kubectl get pods -l env=prod

# Multiple selectors
kubectl get pods -l app=nginx,env=prod


# =========================================================
# 10. POD DEBUGGING
# =========================================================

echo "10. Debugging"

# Events
kubectl get events

# Sort events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check resource usage
kubectl top pod nginx

# Debug node issue
kubectl describe node worker-node

# Check pod status
kubectl get pod nginx -o wide

# Explain pod resource
kubectl explain pod

# Explain containers
kubectl explain pod.spec.containers


# =========================================================
# 11. COPY FILES
# =========================================================

echo "11. Copy Files"

# Copy local to pod
kubectl cp test.txt nginx:/tmp/

# Copy pod to local
kubectl cp nginx:/etc/nginx/nginx.conf ./


# =========================================================
# 12. PORT FORWARDING
# =========================================================

echo "12. Port Forward"

# Local 8080 -> pod 80
kubectl port-forward pod/nginx 8080:80

# Namespace
kubectl port-forward pod/nginx 9090:80 -n dev


# =========================================================
# 13. RESOURCE MANAGEMENT
# =========================================================

echo "13. Resource Management"

# Run pod with requests and limits
kubectl run resource-pod \
  --image=nginx \
  --requests='cpu=100m,memory=128Mi' \
  --limits='cpu=200m,memory=256Mi'

# View resource usage
kubectl top pods


# =========================================================
# 14. MULTI-CONTAINER PODS
# =========================================================

echo "14. Multi-Container Pods"

# Create YAML template only
kubectl run multi \
  --image=nginx \
  --dry-run=client -o yaml > multi.yaml

# Edit multi.yaml manually
# Add sidecar container


# =========================================================
# 15. POD RESTART / STATUS
# =========================================================

echo "15. Pod Status"

# Check restart count
kubectl get pod nginx

# JSONPath restart count
kubectl get pod nginx \
  -o jsonpath='{.status.containerStatuses[0].restartCount}'

# Pod phase
kubectl get pod nginx \
  -o jsonpath='{.status.phase}'


# =========================================================
# 16. JSONPATH EXAMPLES
# =========================================================

echo "16. JSONPATH"

# Pod IP
kubectl get pod nginx \
  -o jsonpath='{.status.podIP}'

# Node name
kubectl get pod nginx \
  -o jsonpath='{.spec.nodeName}'

# Container image
kubectl get pod nginx \
  -o jsonpath='{.spec.containers[*].image}'


# =========================================================
# 17. NAMESPACE COMMANDS
# =========================================================

echo "17. Namespace"

# Create namespace
kubectl create namespace dev

# Run pod in namespace
kubectl run nginx \
  --image=nginx \
  -n dev

# Get namespace pods
kubectl get pods -n dev


# =========================================================
# 18. IMPERATIVE TO DECLARATIVE
# =========================================================

echo "18. Imperative to Declarative"

# Generate YAML
kubectl run nginx \
  --image=nginx \
  --dry-run=client -o yaml > deploy.yaml

# Edit YAML
vi deploy.yaml

# Apply YAML
kubectl apply -f deploy.yaml


# =========================================================
# 19. CLEANUP
# =========================================================

echo "19. Cleanup"

# Delete generated YAMLs
# rm -f *.yaml *.json

# Delete pods
# kubectl delete pods --all


echo "==============================================="
echo " Completed Kubernetes POD Command Collection"
echo "==============================================="