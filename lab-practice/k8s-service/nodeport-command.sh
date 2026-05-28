kubectl explain service   
#manifest file to create a service
apiVersion: v1
Kind: Service


#while write the manifest file pod label should be mentioned to help to understand which deployment/pod will be use to service
kubectl get pod --show-labels #to show the labels of the pods
kubectl get service --show-labels #to show the labels of the services

ubectl create -f nodeport.yaml
kubectl get service #or, kubectl get svc
kubectl describe service nodeport-service

kubectlget pod -o wide
kubectl get nodes -o wide
kubectl describe pod nginx-pod
kubectl get service -o wide

#new cluster created using kind

kind create cluster --config kind-cluster.yaml --name cka-cluster3
kubectl get nodes

#validate current context and cluster
kubectl config current-context
kubectl config get-contexts

#deploy new deployment using the manifest file created in deployment folder or existing file
kubectl apply -f ../deployment/deployment.yaml

#now pod , replicaset & deployment createdin the cluster and we can see the details of the deployment, replicaset and pods using below commands
kubectl get deploy
kubectl get rs
kubectl get pods  
kubectl get nodes # kubectl get nodes -o wide #to show the details of the nodes
kubectl get all
kubectl describe deploy nginx-deploy     

#create nodeport service using manifest file and check the details of the service
kubectl apply -f nodeport.yaml
kubectl get svc  #validate the created service
kubectl describe svc nodeport-svc  #get the details about the services

#now validate the nodeport connectivity with the application running on Pods & hosts
curl localhost:30001
curl <IP_ADDRESS>:30001 # except kind cluster, rest all cluster use the node IP address to access the nodeport service which is exposed on the node port 30001
#also here we can try access the application from browser using the node IP address and node port 30001 or localhost:30001(for kind cluster) to validate the connectivity to the service


#validate the connectivity to the service using curl command and check the logs of the pods to validate the connectivity
curl <IP_ADDRESS>:30001
kubectl logs -l app=nginx -f    
