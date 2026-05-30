kubectl apply -f resource-limit.yaml

kubectl get pods
kubectl get pods -n kube-system

kubectl top
kubectl top node  #cpu memory exposed by a metric server
kubectl top pod
kubectl top pod -n kube-system

#resource stress testing

kubectl create ns mem-example
kubectl apply -f mem-stress.yaml -n mem-example

#or in yaml file mention the namespace in metadata section and then apply the file without -n option
kubectl apply -f mem-stress.yaml

kubectl get pod -n mem-example
kubectl top pod -n mem-example
kubectl top pod mem-stress -n mem-example

# another example mem-stress2.yaml
kubectl apply -f mem-stress2.yaml -n mem-example    

kuberctl get pod -n mem-example
kubectl describe pod mem-stress2 -n mem-example
kubectl top pod mem-stress2 -n mem-example

#another example mem-stress3.yaml
kubectl apply -f mem-stress3.yaml -n mem-example
kubectl get pod -n mem-example
kubectl describe pod mem-stress3 -n mem-example
kubectl top pod mem-stress3 -n mem-example





