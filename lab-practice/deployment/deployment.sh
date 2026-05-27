kubectl explain deploy
GROUP: apps
VERSION: v1
KIND: Deployment
DESCRIPTION:           
Deployment enables declarative updates for Pods and ReplicaSets.
A Deployment provides a lot of useful features like rolling updates, rollbacks, scaling, etc. It manages the ReplicaSets and Pods for you and provides a declarative way to manage your applications.
A Deployment is defined by a Pod template and a set of instructions on how to create and update
the Pods and ReplicaSets. The Deployment controller will create and manage the ReplicaSets and Pods based on the desired state defined in the Deployment.   

kubectl get pods
kubectl delete deploy/nginx-deploy   #delete existing pod nginx-deploy
kubectl get pods

kubectl apply -f deployment.yaml
kubectl get pods

kubectl get deploy
kubectl describe deploy nginx-deploy
kubectl describe rs nginx-deploy-xxxx-xxxx #describe the replica set created by deployment
kubectl describe pod pod-nginx-xxxx-xxxx #describe the pod created by deployment
kubectl get pods -l app=nginx

kubectl get all  #get all the resources created by deployment
kubectl get all -l app=nginx  #get all the resources created by deployment with label app=nginx

kubectl set image deploy/nginx-deploy \     #update the image of the deployment to nginx:1.19.0
>nginx=nginx:1.19.0
kubectl describe deploy nginx-deploy

kubectl rollout history deploy/nginx-deploy  #get the rollout history of the deployment

kubectl rollout undo deploy/nginx-deploy  #rollback to the previous version of the deployment
kubectl describe deploy nginx-deploy

kubectl get pods
kubectl set image deploy/nginx-deploy nginx=nginx:1.19.0  #update the image of the deployment to nginx:1.19.0

kubectl create deploy nginx-deploy --image=nginx:1.18.0  #create a deployment with image nginx:1.18.0
kubectl create deploy deploy/nginx-new --image=nginx:1.18.0 --dry-run=client

kubectl create deploy deploy/nginx-new --image=nginx:1.18.0 --dry-run=client -o yaml > deployment.yaml  #create a deployment with image nginx:1.18.0 and save it to deployment.yaml file
kubectl apply -f deployment.yaml  #apply the deployment.yaml file to create the deployment
kubectl get deploy
kubectl get pods


kubectl delete deploy nginx-deploy
kubectl get pods

