kubectl get pods
kubectl delete pod nginx-pod

kubectl apply -f node-affinity.yaml

kubectl get nodes

kubectl label node <node-name> disktype=ssd
kubectl get node --show-labels

kubectl get pods
kubectl get pods -o wide
kubectil describe pod nginx-pod

