kubectl run nginx-pod --image=nginx:latest  

kubectl explain pod 

#manifest file to create a pod or a container
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod

  kubectl create -f pod.yaml
     kubectl get pods
 kubectl delete pod nginx-pod

   kubectl create -f pod.yaml

   kubectl apply -f pod.yaml  #using a manifest file deploy a pod
  kubectl get pods

   kubectl describe pod nginx-pod

   kubectl edit pod nginx-pod

   kubectl get pods
   kubectl describe pod nginx-pod

   kubectl exec -it nginx-pod -- sh

    kubectl logs nginx-pod
        kubectl logs nginx-pod -f

  
   kubectl run nginx --image=nginx --dry-run=client -o yaml


   kubectl run nginx --image=nginx --dry-run=client -o yaml > pod-new.yaml
 
   kubectl run nginx --image=nginx --dry-run=client -o json > pod-new.json

   kubectl get pods
   kubectl describe pod nginx-pod
 
   kubectl get pods nginx-pod --show-labels

   kubectl get pods -o wide

   kubectl get pods

   kubectl get nodes
   kubectl get nodes -o wide

   #pod ip is not static, it can change when the pod is recreated or rescheduled to a different node. To access the nginx server running in the pod, you can use port forwarding or create a service to expose the pod.
    kubectl port-forward pod/nginx-pod 8080:80
    #Now you can access the nginx server by opening a web browser and navigating to http://localhost:8080. This will forward traffic from your local machine's port 8080 to the nginx server running in the pod on port 80.

#pod lifecycle
   kubectl get pods
   kubectl delete pod nginx-pod
   kubectl get pods
   kubectl create -f pod.yaml
   kubectl get pods
   kubectl delete pod nginx-pod --grace-period=0 --force
   kubectl get pods   

#pods are ephemeral, they can be created, deleted, and recreated. 
#When a pod is deleted, it is removed from the cluster and cannot be recovered. 
#If you want to keep the pod running even after it is deleted, you can use a deployment or a statefulset instead of a pod. 
#Deployments and statefulsets manage the lifecycle of pods and ensure that the desired number of replicas are always running.
#pod doesn't have a self-healing mechanism, if a pod is deleted or fails, it will not be automatically recreated. 
#Pod doesn't have static IP, it's dynamic, it can change when the pod is restarted, deleted, recreated, or rescheduled.

kubectl get pods
kubectl describe pod nginx-pod # IP 1
kubectl delete pod nginx-pod
kubectl get pods
kubectl describe pod nginx-pod

