kubectl get namespaces
kubectl get ns

#default namespace is created by default when we create a kubernetes cluster. It is used to hold the system resources and objects. We can create our own namespaces to organize our resources and objects.
#default 
#kube-node-release
#kube-public
#kube-system
#local-path-storage
kubectl get all
kubectl get all -n=default  #default namespace is used to hold the user resources and objects. It is used to run the user applications and services. It is also used to run the user-level components and services.

kubectl get all --namespace=kube-system  #kube-system namespace is used to hold the system resources and objects. It is used to run the system components and services. It is also used to run the cluster-level components and services.
kubectl get all -n kube-system  #same command like above

#core-dns
#etcd
#kindnet
#api-server
#kube-proxy
#controller-manager
#scheduler
#kube-dns
#daemonset
#deployment
#pod
#replicaset
#service


kubectl create namespace demo
kubectl create ns demo
kubectl get namespaces
kubectl delete namespace demo
kubectl delete ns demo
kubectl delete ns/demo
kubectl delete namespace demo --force --grace-period=0
kubectl get namespaces      

#creating namespace using yaml file(declarative way)
kubectl apply -f namespace.yaml
kubectl get namespaces

#create a resource inside this namespace
kubectl run nginx --image=nginx -n demo

#create a deployment inside this namespace
kubectl create deploy nginx --image=nginx -n demo
kubectl create deploy --help #to get the command for deployment

kubectl get deploy #this is the default namespace output will share, we won't get anything as the deployment created in demo namespace, to get the deployment in default namespace
kubectl get deploy -n demo  #this will share the resouces created in demo namespace
kubectl get all -n demo



#create deployment in default namespace
kubectl create deploy nginx --image=nginx  #this will create the deployment in default namespace as we have not specified any namespace, by default it will create in default namespace and we can keep same name of deployments, as both namespaces are isolated from each other, we can have same name of resources in different namespaces.
kubectl get deploy
kubectl get deploy -n default


#pod from demo name space communicate with default namespace
#pod from demo namespace cannot communicate with default namespace as both namespaces are isolated from each other,

#exec into pod in both namespace
kubectl get pods #to get the pods in default namespace
kubectl get pods -n demo #to get the pods in demo namespace
kubectl get pods -n=demo -o wide #to get the pods in demo namespace with more details
kubectl get pods -n=default -o wide #to get the pods in default namespace with more details
kubectl get pods -n=demo -o yaml #to get the pods in demo namespace in yaml format
kubectl get pods -n=default -o yaml #to get the pods in default namespace in yaml format

kubectl exec -it <pod-name> -n demo -- /bin/bash  #to exec into the pod in demo namespace
kubectl exec -it <pod-name> -n default -- /bin/bash  #to exec into the pod in default namespace
or,

kubectl exec -it <pod-name> --namespace=demo -- /bin/bash  #to exec into the pod in demo namespace
kubectl exec -it <pod-name> --namespace=default -- /bin/bash  #
or,

kubectl exec -it <pod-name> -n demo -- sh    #to exec into the pod in demo namespace
kubectl exec -it <pod-name> -n default -- sh    #to exec into the pod in default namespace  

#for default namespace we no need to mentinion the namespace as it is the default one, but for other namespaces we need to specify the namespace explicitly
kubectl get pods -o wide #to get the pods in default namespace with more details
kubectl exec -it <pod-name> -- sh    #to exec into the pod in


#validate with ping from one pod to another pod in different namespace
#pod in demo namespace cannot ping to pod in default namespace as both namespaces are isolated from each

curl <pod-ip addres from default namespace>  #to ping from pod in demo namespace to pod in default namespace
curl 10.244.2.7  #to ping from pod in demo namespace to pod in default namespace using pod IP address
curl <pod-ip addres from demo namespace>  #to ping from pod in default namespace to pod in demo namespace
curl 10.244.1.7  #to ping from pod in default namespace to pod in demo namespace using pod IP address

#scale the deployment with 3 replicas in demo namespace
kubectl scale deploy nginx --replicas=3 -n demo
kubectl scale --replicas=3 deploy nginx -n demo

kubectl scale --replicas=3 deploy/nginx-demo  #this is the same command as above but with different syntax, we can use either of the command to scale the deployment in demo namespace
kubectl get pods -n demo  #to get the pods in demo namespace after scaling the deployment
kubectl get pods #to get the pods in default namespace after scaling the deployment in demo namespace, we won't get any pods in default namespace as the deployment is created in demo namespace and both namespaces are isolated from each other.
kubectl get deploy nginx -n demo


#exposing a service infront of the deployment, becoz service use to access the pods
kubectl expose deploy nginx --port=80 --target-port=80 -n demo  #
kubectl expose deply/nginx-demo --name=svc-demo --port=80 -n=demo
kubectl get svc -n demo  #to get the services in demo namespace
kubectl get svc -n=demo  #to get the services in demo namespace
kubectl get svc  #to get the services in default namespace, we won't get any services


kubectl expose deploy/nginx-test --name=svc-test --port 80 #no need to specify the namespace as it will be created in default namespace as we have not specified any namespace, by default it will create in default namespace and we can keep same name of services, as both namespaces are isolated from each other, we can have same name of resources in different namespaces.
kubectl get svc  #to get the services in default namespace
kubectl get svc -n default  #to get the services in default namespace

kubectl get svc -n demo  #to get the services in demo namespace, we won't get any services in demo namespace as the service is created in default namespace and both namespaces are isolated from each other.
kubectl get svc -n=demo  #to get the services in demo namespace, we won't get any services in demo namespace as the service is created in default namespace and both namespaces are isolated from each other.

#default service cluster IP created in above service creation with different IP addresses

#now will try to access the service from the pod in both namespaces
kubectl get pods -n demo  #to get the pods in demo namespace
kubectl get pods -n default  #to get the pods in default namespace
kubectl exec -it <pod-name> -n demo -- sh
curl <service-name>  #to access the service from the pod in demo namespace, we won't be able to access the service as the service is created in default namespace and both namespaces are isolated from each other.
curl <service-name>.<namespace>  #to access the service from the pod in demo namespace, we won't be able to access the service as the service is created in default namespace and both namespaces are isolated from each other.
curl <service-name>.<namespace>.svc.cluster.local  #to access the service from the pod in demo namespace, we won't be able to access the service as the service is created in default namespace and both namespaces are isolated from each other.
curl <service-name>.<namespace>.svc  #to access the service from the pod in demo namespace, we won't be able to access the service as the service is created in default namespace and both namespaces are isolated from each other.
curl <service-name>.<namespace>.cluster.local  #to access the service from the pod in demo namespace, we won't be able to access the service as the service is created in

kubectl exec -it <pod-name> -n demo -- sh
curl svc-test  #to access the service from the pod in demo namespace, we won't be able to access the service as the service is created in default namespace and both namespaces are isolated from each other.
#custer ip is not reachable (could not resolve the host) with hostname of the service
curl svc-demo #same issue, not accessible

#cat /etc/resolve.conf  #to check the DNS configuration in the pod, we won't be able to resolve the service name as the service is created in default namespace and both namespaces are isolated from each other.
#this file is used to resolve the DNS names in the pod, we can see that the search domain is set to default.svc.cluster.local, which means that the pod will try to resolve the service name with this search domain, but as the service is created in default namespace and both namespaces are isolated from each other, we won't be able to resolve the service name.
cat /etc/resolve.conf  #to check the DNS configuration in the pod, we won't be able to resolve the service name as the service is created in default namespace and both namespaces are isolated from each other.
demo.svc.cluster.local  #this is the search domain for the service in demo namespace, we won't be able to resolve the service name as the service is created in default namespace and both namespaces are isolated from each other.
default.svc.cluster.local  #this is the search domain for the service in default namespace,

curl svc-test.demo.svc.cluster.local  #to access the service from the pod in demo namespace, we won't be able to access the service as the service is created in default namespace and both namespaces are isolated from each other.
curl svc-demo.default.svc.cluster.local  #to access the service from the pod in demo
#now we can access the service from another namespace pod by using the fully qualified domain name (FQDN) of the service, which is <service-name>.<namespace>.svc.cluster.local, as the service is created in default namespace and both namespaces are isolated from each other, we can access the service by using the FQDN of the service.

