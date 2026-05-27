#!/bin/bash

############################################################
# KUBERNETES DEPLOYMENT COMPLETE CHEATSHEET
############################################################

############################
# CREATE DEPLOYMENT
############################

# Create deployment
kubectl create deployment nginx --image=nginx

# Create deployment with replicas
kubectl create deployment nginx --image=nginx --replicas=3

# Generate deployment YAML
kubectl create deployment nginx \
--image=nginx \
--dry-run=client -o yaml > deployment.yaml

# Apply deployment YAML
kubectl apply -f deployment.yaml

# Apply all YAMLs in directory
kubectl apply -f .

# Create from URL
kubectl apply -f https://k8s.io/examples/application/deployment.yaml


############################
# GET DEPLOYMENTS
############################

# Get deployments
kubectl get deployments

kubectl get deploy

# Wide output
kubectl get deploy -o wide

# Watch deployment changes
kubectl get deploy -w

# Get deployment YAML
kubectl get deploy nginx -o yaml

# Get deployment JSON
kubectl get deploy nginx -o json

# Custom columns
kubectl get deploy nginx \
-o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas

# Get all resources
kubectl get all

# Get ReplicaSets
kubectl get rs

# Get Pods
kubectl get pods

# Get deployment labels
kubectl get deploy --show-labels

# Sort deployments
kubectl get deploy --sort-by=.metadata.name


############################
# DESCRIBE
############################

# Describe deployment
kubectl describe deployment nginx

kubectl describe deploy nginx

# Describe ReplicaSet
kubectl describe rs

# Describe Pod
kubectl describe pod <pod-name>


############################
# SCALE DEPLOYMENT
############################

# Scale replicas
kubectl scale deployment nginx --replicas=5

# Scale multiple deployments
kubectl scale deploy nginx apache --replicas=3

# Autoscale deployment
kubectl autoscale deployment nginx \
--cpu-percent=70 \
--min=2 \
--max=10

# Check HPA
kubectl get hpa


############################
# UPDATE DEPLOYMENT
############################

# Update image
kubectl set image deployment/nginx \
nginx=nginx:1.27

# Update multiple containers
kubectl set image deployment/nginx \
nginx=nginx:1.27 sidecar=busybox

# Record change
kubectl set image deployment/nginx \
nginx=nginx:1.27 --record

# Edit deployment live
kubectl edit deployment nginx

# Patch deployment
kubectl patch deployment nginx \
-p '{"spec":{"replicas":4}}'

# Add annotation
kubectl annotate deployment nginx \
description="Production deployment"

# Remove annotation
kubectl annotate deployment nginx description-

# Label deployment
kubectl label deployment nginx env=prod

# Remove label
kubectl label deployment nginx env-


############################
# ROLLOUT COMMANDS
############################

# Rollout status
kubectl rollout status deployment/nginx

# Rollout history
kubectl rollout history deployment/nginx

# Rollout history revision details
kubectl rollout history deployment/nginx --revision=2

# Pause rollout
kubectl rollout pause deployment/nginx

# Resume rollout
kubectl rollout resume deployment/nginx

# Restart deployment
kubectl rollout restart deployment/nginx

# Undo rollout
kubectl rollout undo deployment/nginx

# Undo to specific revision
kubectl rollout undo deployment/nginx --to-revision=2


############################
# DELETE DEPLOYMENT
############################

# Delete deployment
kubectl delete deployment nginx

# Delete with YAML
kubectl delete -f deployment.yaml

# Force delete
kubectl delete deploy nginx --force --grace-period=0

# Delete all deployments
kubectl delete deploy --all

# Delete all resources in namespace
kubectl delete all --all


############################
# NAMESPACE COMMANDS
############################

# Create namespace
kubectl create ns dev

# Deploy in namespace
kubectl create deployment nginx \
--image=nginx -n dev

# Get deployment in namespace
kubectl get deploy -n dev

# Set default namespace
kubectl config set-context --current --namespace=dev


############################
# LOGS
############################

# Logs from Pod
kubectl logs <pod-name>

# Stream logs
kubectl logs -f <pod-name>

# Previous container logs
kubectl logs -p <pod-name>

# Logs from specific container
kubectl logs <pod-name> -c nginx


############################
# EXEC INTO POD
############################

# Exec into Pod
kubectl exec -it <pod-name> -- bash

# Using sh
kubectl exec -it <pod-name> -- sh

# Run command inside Pod
kubectl exec <pod-name> -- ls /

# Multiple container Pod
kubectl exec -it <pod-name> -c nginx -- bash


############################
# PORT FORWARD
############################

# Port forward deployment
kubectl port-forward deployment/nginx 8080:80

# Port forward Pod
kubectl port-forward pod/<pod-name> 8080:80

# Port forward service
kubectl port-forward svc/nginx 8080:80


############################
# EXPOSE DEPLOYMENT
############################

# Expose deployment as ClusterIP
kubectl expose deployment nginx \
--port=80 --target-port=80

# Expose as NodePort
kubectl expose deployment nginx \
--type=NodePort \
--port=80

# Expose as LoadBalancer
kubectl expose deployment nginx \
--type=LoadBalancer \
--port=80


############################
# DEBUGGING
############################

# Check events
kubectl get events

# Sort events by time
kubectl get events --sort-by=.metadata.creationTimestamp

# Top Pods
kubectl top pods

# Top nodes
kubectl top nodes

# Explain deployment fields
kubectl explain deployment

kubectl explain deployment.spec

kubectl explain deployment.spec.template

# API resources
kubectl api-resources

# API versions
kubectl api-versions


############################
# WAIT COMMANDS
############################

# Wait for deployment available
kubectl wait deployment/nginx \
--for=condition=available \
--timeout=60s

# Wait for Pod ready
kubectl wait pod/<pod-name> \
--for=condition=Ready \
--timeout=60s


############################
# SELECTORS
############################

# Get deployment by label
kubectl get deploy -l app=nginx

# Get Pods by label
kubectl get pods -l app=nginx

# Delete by label
kubectl delete deploy -l app=nginx


############################
# JSONPATH
############################

# Deployment name
kubectl get deploy nginx \
-o jsonpath='{.metadata.name}'

# Replicas count
kubectl get deploy nginx \
-o jsonpath='{.spec.replicas}'

# Container image
kubectl get deploy nginx \
-o jsonpath='{.spec.template.spec.containers[*].image}'


############################
# RESOURCE MANAGEMENT
############################

# Set resources
kubectl set resources deployment nginx \
-c=nginx \
--limits=cpu=500m,memory=512Mi \
--requests=cpu=200m,memory=256Mi

# Check resources
kubectl describe deploy nginx


############################
# ENVIRONMENT VARIABLES
############################

# Set env variable
kubectl set env deployment/nginx ENV=prod

# Set multiple env vars
kubectl set env deployment/nginx \
APP=web TIER=frontend

# Remove env variable
kubectl set env deployment/nginx ENV-

# List env vars
kubectl set env deployment/nginx --list


############################
# SERVICE ACCOUNT
############################

# Set service account
kubectl set serviceaccount deployment nginx default


############################
# TAINT/TOLERATION DEBUG
############################

# Check node taints
kubectl describe node <node-name>

# Check Pod tolerations
kubectl describe pod <pod-name>


############################
# YAML VALIDATION
############################

# Validate YAML
kubectl apply --dry-run=client -f deployment.yaml

# Server validation
kubectl apply --dry-run=server -f deployment.yaml

# Diff changes
kubectl diff -f deployment.yaml


############################
# KUSTOMIZE
############################

# Apply kustomization
kubectl apply -k .

# Preview kustomize
kubectl kustomize .


############################
# HELM RELATED
############################

# Install chart
helm install nginx bitnami/nginx

# Upgrade chart
helm upgrade nginx bitnami/nginx

# List releases
helm list

# Uninstall release
helm uninstall nginx


############################
# COMMON TROUBLESHOOTING
############################

# Image pull issues
kubectl describe pod <pod-name>

# CrashLoopBackOff logs
kubectl logs <pod-name> --previous

# Failed scheduling
kubectl get events

# Deployment not available
kubectl rollout status deployment/nginx

# Check readiness/liveness
kubectl describe pod <pod-name>


############################
# CLEANUP
############################

# Delete Pod
kubectl delete pod <pod-name>

# Delete ReplicaSet
kubectl delete rs <rs-name>

# Delete service
kubectl delete svc nginx

# Delete namespace
kubectl delete ns dev


############################################################
# END OF DEPLOYMENT CHEATSHEET
############################################################