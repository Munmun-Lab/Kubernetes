kubernetes get pods -n=kube-system
kubernetes get ds -A

kind create cluster --name=cka-new --config=kind.yaml


k get nodes
k get nodes --watch

kubectl describe node\cka-new-control-panel

===============================

# install the deamonset yaml for CNI plugin from website

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

kubectl get pods -n kube-system -o wide

k get pods -n=kube-system | grep weave

k get nodes


==================================

# Creating an app with 3 tier app(network project using kind & calico)

k apply -f app-manifest.yaml
k get pods
k get pods --watch

k get svc

==================================


# get inside backend pod from frontend

k get pods
k exec -it frintend -bash

curl backend:80        # access the backend pod

===============================

# get inside db pod from frontend

apt-get update && apt-get install telnet         # install telnet

telnet db 3306

==============================

# create network policy

k apply -f netpolicy.yaml

k get netpol

k describe netpol deb-test

PodSelector: name=mysql     # means applied on pod mysql
From: 
PodSelector: role=backend

===============================

# after injecting netpolicy, test the connectivity from frontend to db

k exec -it frontend bash

telnet db 3306

exit

==============================

# try from backend to test db

k exec -it backend -bash

apt-get update && apt-get install telnet
telnet db 3306

===============================


# implement the project with kind & calico

# install the cluster

k create cluster --config= ind-calico.yaml --name cka-kind

kubectl get nodes
k get nodes -o wide


# install calico (either operator & CRD, but we will do here using manifest)

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.0/manifests/calico.yaml

# verify calico installation

watch kubectl get pods -l k8s-app=calico-node -A           # deployed as deamonset, so each pod on each node will be deployed in kube-system namespace

watch kubectl get pods -l k8s-app=calico-node -A --watch

# apply the manifest for pod & service deployment

k apply -f app-manifest.yaml


# get inside frontend & test backend & db pod

k exec -it frontend -- bash

curl backend:80       # direct refer the service name "backend" with port 80

apt-get update && apt-get install telnet -y

telnet backend 80

telnet db 3306

exit

# login backend pod & test the same

k exec -it backend --bash


==========================================

# all pods are connected & svc are exposed, now will restrict and test the connectivity

k apply -f network-policy.yaml
k describe nettpol db-test

# login frintend & test db

k exec -it frontend -- bash

telnet db 3306         # it's blocked now from frontend -> db 

# login backend & test db

k exec -it backend -- bash

telnet db 3306      # it's allowed










