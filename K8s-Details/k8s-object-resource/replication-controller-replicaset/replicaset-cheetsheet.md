#!/bin/bash

############################################################
# KUBERNETES REPLICASET COMPLETE CHEATSHEET
############################################################

############################
# CREATE REPLICASET
############################

# Create ReplicaSet from YAML
kubectl apply -f rs.yaml

# Create using create command
kubectl create -f rs.yaml

# Dry run ReplicaSet
kubectl apply --dry-run=client -f rs.yaml

# Server-side dry run
kubectl apply --dry-run=server -f rs.yaml

# Validate YAML
kubectl apply --validate=true -f rs.yaml

# Create namespace
kubectl create ns dev

# Create ReplicaSet in namespace
kubectl apply -f rs.yaml -n dev


############################
# GET REPLICASET
############################

# Get ReplicaSets
kubectl get rs

kubectl get replicaset

kubectl get replicasets

# Get ReplicaSet wide output
kubectl get rs -o wide

# Watch ReplicaSet
kubectl get rs -w

# Get ReplicaSet in namespace
kubectl get rs -n dev

# Get all namespaces
kubectl get rs -A

# Get ReplicaSet YAML
kubectl get rs nginx-rs -o yaml

# Get ReplicaSet JSON
kubectl get rs nginx-rs -o json

# Custom columns
kubectl get rs \
-o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas

# Sort ReplicaSets
kubectl get rs --sort-by=.metadata.name

# Show labels
kubectl get rs --show-labels

# Get all resources
kubectl get all

# Get Pods
kubectl get pods

# Get Pods created by ReplicaSet
kubectl get pods -l app=nginx


############################
# DESCRIBE REPLICASET
############################

# Describe ReplicaSet
kubectl describe rs nginx-rs

kubectl describe replicaset nginx-rs

# Describe Pod
kubectl describe pod <pod-name>

# Describe namespace ReplicaSet
kubectl describe rs nginx-rs -n dev


############################
# SCALE REPLICASET
############################

# Scale replicas
kubectl scale rs nginx-rs --replicas=5

# Scale ReplicaSet in namespace
kubectl scale rs nginx-rs \
--replicas=5 -n dev

# Scale multiple ReplicaSets
kubectl scale rs nginx-rs apache-rs \
--replicas=3

# Edit replicas manually
kubectl edit rs nginx-rs


############################
# PATCH REPLICASET
############################

# Patch replicas
kubectl patch rs nginx-rs \
-p '{"spec":{"replicas":4}}'

# Strategic merge patch
kubectl patch rs nginx-rs \
--type='strategic' \
-p '{"spec":{"replicas":6}}'

# JSON patch
kubectl patch rs nginx-rs \
--type='json' \
-p='[{"op":"replace","path":"/spec/replicas","value":3}]'


############################
# LABELS
############################

# Add label
kubectl label rs nginx-rs env=prod

# Update label
kubectl label rs nginx-rs env=dev --overwrite

# Remove label
kubectl label rs nginx-rs env-

# Filter by label
kubectl get rs -l app=nginx

# Multiple labels
kubectl get rs -l app=nginx,env=prod

# Label Pods
kubectl label pod <pod-name> app=nginx

# Show labels
kubectl get rs --show-labels


############################
# ANNOTATIONS
############################

# Add annotation
kubectl annotate rs nginx-rs \
description="Frontend ReplicaSet"

# Update annotation
kubectl annotate rs nginx-rs \
description="Updated RS" --overwrite

# Remove annotation
kubectl annotate rs nginx-rs description-


############################
# DELETE REPLICASET
############################

# Delete ReplicaSet
kubectl delete rs nginx-rs

# Delete from YAML
kubectl delete -f rs.yaml

# Delete all ReplicaSets
kubectl delete rs --all

# Delete ReplicaSet in namespace
kubectl delete rs nginx-rs -n dev

# Force delete
kubectl delete rs nginx-rs \
--force --grace-period=0

# Delete by label
kubectl delete rs -l app=nginx


############################
# POD OPERATIONS
############################

# Get Pods
kubectl get pods

# Wide Pod output
kubectl get pods -o wide

# Watch Pods
kubectl get pods -w

# Delete Pod (self-healing test)
kubectl delete pod <pod-name>

# Delete multiple Pods
kubectl delete pod pod1 pod2

# Force delete Pod
kubectl delete pod <pod-name> \
--force --grace-period=0

# Exec into Pod
kubectl exec -it <pod-name> -- bash

# Exec using sh
kubectl exec -it <pod-name> -- sh

# Run command inside Pod
kubectl exec <pod-name> -- ls /

# Logs
kubectl logs <pod-name>

# Stream logs
kubectl logs -f <pod-name>

# Previous logs
kubectl logs -p <pod-name>


############################
# IMAGE MANAGEMENT
############################

# Update image using edit
kubectl edit rs nginx-rs

# Patch image
kubectl patch rs nginx-rs \
-p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.27"}]}}}}'

# Check image
kubectl get rs nginx-rs \
-o jsonpath='{.spec.template.spec.containers[*].image}'


############################
# YAML GENERATION
############################

# Export YAML
kubectl get rs nginx-rs -o yaml > rs-export.yaml

# Export without status
kubectl get rs nginx-rs \
-o yaml --export

# View live manifest
kubectl get rs nginx-rs -o yaml


############################
# EVENTS & TROUBLESHOOTING
############################

# Get events
kubectl get events

# Sort events
kubectl get events \
--sort-by=.metadata.creationTimestamp

# ReplicaSet troubleshooting
kubectl describe rs nginx-rs

# Pod troubleshooting
kubectl describe pod <pod-name>

# Image pull issues
kubectl get events

# CrashLoopBackOff
kubectl logs <pod-name> --previous

# Pending Pods
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes

# Check Pod resources
kubectl top pods


############################
# WAIT COMMANDS
############################

# Wait for ReplicaSet ready
kubectl wait rs/nginx-rs \
--for=jsonpath='{.status.readyReplicas}'=3 \
--timeout=60s

# Wait for Pod ready
kubectl wait pod/<pod-name> \
--for=condition=Ready \
--timeout=60s


############################
# JSONPATH
############################

# ReplicaSet name
kubectl get rs nginx-rs \
-o jsonpath='{.metadata.name}'

# Replica count
kubectl get rs nginx-rs \
-o jsonpath='{.spec.replicas}'

# Ready replicas
kubectl get rs nginx-rs \
-o jsonpath='{.status.readyReplicas}'

# Pod labels
kubectl get rs nginx-rs \
-o jsonpath='{.spec.template.metadata.labels}'

# Container names
kubectl get rs nginx-rs \
-o jsonpath='{.spec.template.spec.containers[*].name}'


############################
# EXPLAIN COMMANDS
############################

# Explain ReplicaSet
kubectl explain rs

# Explain spec
kubectl explain rs.spec

# Explain template
kubectl explain rs.spec.template

# Explain selector
kubectl explain rs.spec.selector

# Explain matchLabels
kubectl explain rs.spec.selector.matchLabels

# Explain matchExpressions
kubectl explain rs.spec.selector.matchExpressions


############################
# RESOURCE MANAGEMENT
############################

# Set resources
kubectl set resources rs nginx-rs \
-c=nginx \
--limits=cpu=500m,memory=512Mi \
--requests=cpu=200m,memory=256Mi

# Check resources
kubectl describe rs nginx-rs


############################
# ENVIRONMENT VARIABLES
############################

# Set env variable
kubectl set env rs/nginx-rs ENV=prod

# Multiple env vars
kubectl set env rs/nginx-rs \
APP=web TIER=frontend

# Remove env variable
kubectl set env rs/nginx-rs ENV-

# List env vars
kubectl set env rs/nginx-rs --list


############################
# PORT FORWARD
############################

# Port forward Pod
kubectl port-forward pod/<pod-name> 8080:80

# Port forward service
kubectl port-forward svc/nginx 8080:80


############################
# EXPOSE REPLICASET
############################

# Expose ReplicaSet
kubectl expose rs nginx-rs \
--port=80 \
--target-port=80 \
--type=ClusterIP

# Expose as NodePort
kubectl expose rs nginx-rs \
--type=NodePort \
--port=80

# Expose as LoadBalancer
kubectl expose rs nginx-rs \
--type=LoadBalancer \
--port=80


############################
# SERVICE ACCOUNT
############################

# Set service account
kubectl set serviceaccount rs nginx-rs default


############################
# TAINTS & TOLERATIONS
############################

# Check taints
kubectl describe node <node-name>

# Check tolerations
kubectl describe pod <pod-name>


############################
# API INFORMATION
############################

# API resources
kubectl api-resources

# API versions
kubectl api-versions


############################
# KUSTOMIZE
############################

# Apply kustomize
kubectl apply -k .

# Preview kustomize
kubectl kustomize .


############################
# CLEANUP
############################

# Delete Pod
kubectl delete pod <pod-name>

# Delete service
kubectl delete svc nginx

# Delete namespace
kubectl delete ns dev

# Delete all resources
kubectl delete all --all


############################################################
# END OF REPLICASET CHEATSHEET
############################################################