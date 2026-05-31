#create secret from commandline
kubectl create secret generic mysql-secret \
--from-literal=username=admin \
--from-literal=password=MyPassword123

kubectl get secret
kubectl describe secret myseql-secret

#view secret YAML
kubectl get secret mysql-secret -o yaml

#decode the data
echo <key> | base64 --decode

#create secret using yaml

#generate Base64 1st
echo -n "admin" | base64
echo -n "MyPassword123" | base64

kubectl apply -f secret.yaml

#using secret as environment variable
kubectl apply -f secret-as-env-variable.yaml
kubectl exec -it mysql-client -- env | grep DB

#import entire secret, so that Pod get all the keys as env variables
#envFrom:
#- secretRef:
#    name: mysql-secret

#secret as volume
kubectl apply -f secret-as-volume.yaml
kubectl exec -it secret-volume-demo -- ls /etc/secrets
kubectl exec -it secret-volume-demo -- cat /etc/secrets/password

