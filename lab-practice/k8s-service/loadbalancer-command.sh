kubectl apply -f loadbalancer.yaml
kubectl get svc
loadbalancer-service   LoadBalancer  #loadbalancer created, without external IP
#we haven't provison any external loadbalancer, created the service type loadbalancer, but not created the actual.
#Bydefault without external IP loadbalancer behave as a nodeport service (80:30403/TCP) a random nodeport is assigned to the service, and we can access the service using any node IP and the assigned nodeport.




#For Kind cluster provison loadbalancer follow the steps
#install metallb loadbalancer as a binary
#https://metallb.universe.tf/installation/
#after installing metallb, we can create a loadbalancer service and it will be assigned
#an external IP by metallb, and we can access the service using that external IP.


kubectl describe svc loadbalancer-service
kubectl get endpoints loadbalancer-service

