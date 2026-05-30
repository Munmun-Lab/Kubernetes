kubectl apply -f multi-container-pod.yaml
kubectl get pods
READY  STATUS    RESTARTS   AGE
0/1    Init:0/1   0          10s
1/1    Running   0          20s

kubectl describe pod my-app  #to get the details of the pod

REASON             MESSAGE
Init:0/1           init container is not ready
Running            main container is running    
PodInitializing   pod is initializing
Command:
 sh -c "echo Hello from init container; sleep 5"
sh -c "echo Hello from main container; sleep 3600"  

#due to the above command, the init container will run first and once it is completed, the main container will start running. If we check the logs of the init container, we will see the message "Hello from init container" and if we check the logs of the main container, we will see the message "Hello from main container".

kubectl logs pod/my-app #to get the logs of the main container, as it is the default container
kubectl logs my-app #to get the logs of the main container, as it is the
kubectl logs my-app -c init-container  #to get the logs of the init container
kubectl logs my-app -c main-container  #to get the logs of the main container   

#now create a deployment with the same multi-container pod yaml file, as we have not specified any name for the containers, it will take the default name as "init-container" and "main-container"
kubectl apply -f multi-container-deployment.yaml
kubectl get deploy

kubectl create deploy nginx-deploy --image nginx --port 80
kubectl get deploy
kubectl get pod

#now expose the deployment using a service
kubectl expose deploy nginx-deploy --name my-serice --port 80
kubectl expose deply <deployment-name> --name <service-name> --port <port-number>
kubectl get pods
kubectl get svc

#check the logs of the nginx container in the deployment
kubectl logs pod/<pod-name> -c nginx  #to get the logs of the
kubectl logs pod/<pod-name> -c <container-name>  #to get the logs of a specific container in the pod

#now main app container will run and give the final output, as the init container will run first and once it is completed, 
#the main app container will start running and container get stop after 3600 seconds, 
#as we have specified the sleep time in the command of the main container. 
#If we check the logs of the main container, we will see the message "Hello from main container" 
#and if we check the logs of the init container, we will see the message "Hello from init container".



kubectl get pods
kubectl exec -it <pod-name> -c init-container -- sh  #to exec into the init container
kubectl exec -it myapp -- printenv  #to get the environment variables of the main container
kubectl exec -it myapp -c main-container -- printenv  #to get the
#environment variables of the main container
kubectl exec -it myapp -c init-container -- printenv  #to get theenvironment variables of the init container

kubectl exec -it myapp -- sh  #to exec into the main container
echo $FIRTNAME  #to get the value of the environment variable FIRSTNAME in the main container
echo $LASTNAME  #to get the value of the environment variable LASTNAME in the main container


kubectl exec -it myapp -c main-container -- sh  #to exec into themain container
kubectl exec -it myapp -c init-container -- sh  #to exec into the init container


#we can not add/create the init container once it is created
#we can not update the command of the init container once it is created, we have to delete the pod and create a new pod with the updated command for the init container.

kubectl get pods
kubectl delete pod my-app

kubectl apply -f multi-container-pod.yaml
kubectl get pods
#to initializa the main app pod, for that to be up & running all the init container inside that pod has to be intilized first, 
#once all the init container is intilized then the main app container will start running. 

#create deployment
kubectl create deploy mydb --image redis --port 80

#create the service infront of the deployment
kubectl expose deploy mydb --name mydb-service --port 80 #different object service & deployment, so we can keep same name

kubectl get deploy
kubectl get svc
mydb-service   ClusterIP
mydb-service   ClusterIP

kubectl get pods
mydb-5c9b6d8f8c-7j5k2   1/1     Running   0          5m

kubectl get pods -w #to watch the pods in real time, as soon as the pod is created or deleted, it will show the status of the pod in real time.
NAME    READY   STATUS    RESTARTS   AGE
myapp-6d8f8c-7j5k2   0/1     Init:0/1   0          10s
mydb-5c9b6d8f8c-7j5k2   1/1     Running   0          5m
nginx-deploy-5c9b6d8f8c-7j5k2   1/1     Running   0          5m

