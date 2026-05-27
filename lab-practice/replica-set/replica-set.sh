kubectl explain rs
GROUP: apps
VERSION: v1
KIND: ReplicaSet
DESCRIPTION:
ReplicaSet ensures that a specified number of pod replicas are running at any given time. It can be used to guarantee the availability of a specified number of identical pods. A ReplicaSet is defined by

appVersion: apps/v1
kubectl get pods
kubectl delete rc/nginx-rc   #delete existing replication controller nginx-r
kubectl delete rs/nginx-rs   #delete existing replica set nginx-rs
kubectl get pods
kubectl apply -f rs.yml

replicas: 5 
kubectl apply -f rs.yml
kubectl get pods

kubectl edit rs/nginx-rs  #edit the replica set to change the number of replicas to 5
kubectl apply -f rs.yml #apply chnages is not required as in live object
kubectl get pods

#imperative way to set the replicas to 8
kubectl scale --replicas=8 rs/nginx-rs  #scale the replica set to 8 replicas
kubectl get pods
kubectl get rs

kubectl scale --help

