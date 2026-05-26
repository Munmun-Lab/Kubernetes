kubectl run nginx-pod --image=nginx:latest  

kubectl explain pod 


  kubectl create -f pod.yaml
     kubectl get pods
 kubectl delete pod nginx-pod

   kubectl create -f pod.yaml

   kubectl apply -f pod.yaml
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