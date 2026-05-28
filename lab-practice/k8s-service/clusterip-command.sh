kubectl get svc
kubectl describe svc clusterip-service
kubectl get endpoints clusterip-service


#clusterip has the endpoint of the pod or services hosted on nodes in container, and pods or services can be accessed using the cluster IP name or the IP of the clusterIP
#to access the clusterIP service, we can use port forwarding or create an ingress resource to expose the service outside the cluster.
kubectl get svc
NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
clusterip-service ClusterIP     

#create a clusterIP service
kubectl apply -f clusterip.yaml
kubectl get svc
#NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
#clusterip-service ClusterIP 10.96.166.236
kubectl describe svc clusterip-service
#Name:              clusterip-service
#Namespace:         default
#Labels:            app=clusterip
#                    env=dev
#Annotations:       <none>      
#Selector:          app=clusterip,env=dev
#Type:              ClusterIP
#IP:        
#Endpoints:         <none>  #endpoints are the ip addresses of the pods that are selected by the service. If there are no pods that match the selector, then the endpoints will be empty.
#Port:              <unset>  80/TCP
#TargetPort:        80/TCP
#Session Affinity:  None
#Events:            <none>

kubectl get pods -o wide

kubectl get ep
kubectl get ep clusterip-service
kubectl get endpoints
kubectl get endpoints clusterip-service


