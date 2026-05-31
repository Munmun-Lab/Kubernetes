# Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View Metrics
kubectl top pods
kubectl top nodes

# Create HPA
kubectl autoscale deployment nginx --cpu-percent=50 --min=2 --max=10

# List HPA
kubectl get hpa

# Describe HPA
kubectl describe hpa nginx

# Delete HPA
kubectl delete hpa nginx

# View VPA
kubectl get vpa

# Describe VPA
kubectl describe vpa nginx-vpa