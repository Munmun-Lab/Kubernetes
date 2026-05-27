
kubectl explain rc

kubectl get pods
kubectl delete deploy/nginx-deploy   #delete existing pod nginx-deploy

kubectl get pods
kubectl apply -f rc.yaml
kubectl get pods
kubectl get rc

kubectl describe pod pod-nginx-xxxx-xxxx #describe the pod 
kubectl describe rc nginx-rc
kubectl get pods -l app=nginx
kubectl delete rc nginx-rc
kubectl get pods    
