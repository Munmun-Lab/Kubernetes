brew install kind
kind create cluster --image kindest/node:v1.35.0@sha256:452d707d4862f52530247495d180205e029056831160e22870e37e3f6c1ac31f --name cka-cluster1
kubectl cluster-info --context kind-cka-cluster1
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"

brew install kubernetes-cli

kubectl version --client   
kubectl get nodes 
vi config.yaml 
kind create cluster --image kindest/node:v1.35.0@sha256:452d707d4862f52530247495d180205e029056831160e22870e37e3f6c1ac31f --name cka-cluster2 --config config.yaml
kubectl get nodes

kubectl config get-contexts 
kubectl config use-context kind-cka-cluster1

kubectl get nodes 
kubectl config use-context kind-cka-cluster2

kubectl get nodes

kubectl config get-contexts   