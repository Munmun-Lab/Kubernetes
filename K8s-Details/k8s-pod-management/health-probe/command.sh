kubectl apply -f liveness-c.yaml
kubectl get pods
kubectl get pod --watch
kubectl describe pod liveness-c

kubectl logs liveness-c
kubectl exec -it liveness-c -- /bin/bash
cat /tmp/healthy
echo "not healthy" > /tmp/healthy
cat /tmp/healthy

kubectl get pods
kubectl describe pod liveness-c


#http liveness probe
kubectl apply -f liveness-http.yaml
kubectl get pods
kubectl describe pod liveness-http
curl http://localhost:8080/healthz
curl http://localhost:8080/healthz -v   #to see the response code
curl http://localhost:8080/healthz -v --max-time 1  #to set the timeout for the request

kubectl exec -it liveness-http -- /bin/bash
kubectl exec -it liveness-http --sh
kubectl exec -it liveness-http --bash
ls -lrt
cat /healthz
touch /healthz
cat /healthz

kubectl describe pod liveness-http

#tcp liveness probe
kubectl apply -f liveness-tcp.yaml
kubectl get pods
kubectl describe pod liveness-tcp
nc -zv localhost 8080
nc -zv localhost 8080 -w 1  #to set the timeout for

kubectl apply -f --force liveness-tcp.yaml
kubectl describe pod liveness-tcp
nc -zv localhost 8080


kubectl apply --force -f liveness-tcp.yaml
kubectl get pods
kubectl describe pod liveness-tcp
nc -zv localhost 8080


kubectl get pod/liveness-tcp -o yaml #to see the details of the pod in yaml format
kubectl get pod/liveness-tcp -o json #to see the details of the pod in json format

