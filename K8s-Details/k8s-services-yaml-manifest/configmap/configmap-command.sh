kubectl apply -f configmap.yaml
kubectl get configmap
kubectl describe configmap app-config


#create config map imperative way i.e using command
kubectl create configmap app-config \
--from-literal=APP_ENV=production \
--from-literal=DB_HOST=mysql-server \
--from-literal=DB_PORT=3306

kubectl get cm
kubectl get configmap app-config -o yaml

#create pod
kubectl apply -f configmap-pod.yaml

kubectl exec -it webapp --env
kubectl exec -it webapp -- env | grep DB

#configmap as volume
kubectl exec -it nginx-volume -- ls /etc/config
kubectl exec -it nginx-volume -- cat /etc/config/app.conf

#create configmap from file
kubectl create configmap app-config --from-file=app.prpperties
kubectl describe cm app-config

#update configmap
kubectl edit configmap app-config
kubectl apply -f configmap.yaml
