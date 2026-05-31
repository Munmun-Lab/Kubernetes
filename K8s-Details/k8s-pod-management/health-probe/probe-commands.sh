#!/bin/bash

########################################
# HEALTH PROBE COMMANDS
########################################

# Apply Probe YAML
kubectl apply -f probe.yaml

# List Pods
kubectl get pods

# Watch Pod Status
kubectl get pods -w

# Detailed Pod Information
kubectl describe pod <pod-name>

# View Logs
kubectl logs <pod-name>

# View Previous Container Logs (after restart)
kubectl logs --previous <pod-name>

# Check Restart Count
kubectl get pod <pod-name> -o wide

kubectl get pod <pod-name> \
-o=jsonpath='{.status.containerStatuses[*].restartCount}'

########################################
# READINESS PROBE
########################################

# Check Service Endpoints
kubectl get endpoints

kubectl get endpoints <service-name>

# Check EndpointSlices
kubectl get endpointslices

# Verify Pod Ready Status
kubectl get pods

kubectl get pod <pod-name> \
-o=jsonpath='{.status.conditions[?(@.type=="Ready")].status}'

########################################
# LIVENESS PROBE
########################################

# Check Liveness Failures
kubectl describe pod <pod-name>

# Check Container Restarts
kubectl get pod <pod-name> \
-o=jsonpath='{.status.containerStatuses[*].restartCount}'

########################################
# STARTUP PROBE
########################################

# Check Startup Probe Events
kubectl describe pod <pod-name>

# Watch Events
kubectl get events --sort-by=.metadata.creationTimestamp

########################################
# EXEC INTO POD
########################################

# Open Shell
kubectl exec -it <pod-name> -- sh

# Open Bash
kubectl exec -it <pod-name> -- bash

########################################
# TEST HTTP HEALTH ENDPOINT
########################################

kubectl exec -it <pod-name> -- curl localhost

kubectl exec -it <pod-name> -- curl localhost:8080

kubectl exec -it <pod-name> -- curl localhost:8080/health

kubectl exec -it <pod-name> -- wget -qO- localhost:8080/health

########################################
# TEST TCP PORT
########################################

kubectl exec -it <pod-name> -- netstat -tulpn

kubectl exec -it <pod-name> -- ss -tulpn

########################################
# CHECK EVENTS
########################################

kubectl get events

kubectl get events --sort-by=.metadata.creationTimestamp

########################################
# FILTER PROBE FAILURES
########################################

kubectl describe pod <pod-name> | grep -i probe

kubectl describe pod <pod-name> | grep -i liveness

kubectl describe pod <pod-name> | grep -i readiness

kubectl describe pod <pod-name> | grep -i startup

########################################
# DELETE & RECREATE
########################################

kubectl delete -f probe.yaml

kubectl apply -f probe.yaml

########################################
# POD YAML
########################################

kubectl get pod <pod-name> -o yaml

kubectl get deployment <deployment-name> -o yaml

########################################
# DEBUG
########################################

kubectl top pod

kubectl top node

kubectl describe node <node-name>

---

kubectl get pods

kubectl describe pod <pod-name>

kubectl logs <pod-name>

kubectl logs --previous <pod-name>

kubectl get endpoints

kubectl get events --sort-by=.metadata.creationTimestamp

kubectl exec -it <pod-name> -- sh

