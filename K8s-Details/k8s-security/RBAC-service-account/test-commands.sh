kubectl get sa         # service account list from default 
kubectl get sa -A      # service account list from all namespaces

kubectl get sa -A | grep default        # all default service accounts

# 5 namespace = 5 service accounts

kubectl describe sa default    

kubectl get sa default -o yaml 

====================================

# create a service account

kubectl create sa build-sa              # create sa in default namespace

kubectl describe sa build-sa

=====================================

# create a long live api token for a sa

# secret.yaml create to deploy the secret 

kubernetes apply -f secret-token.yaml

kubernetes get secret

kubernetes describe secret/build-robot-secret

# this secret has a token, token data, ca cert(as it is encrypted, namespace scoped)

================================

# add Imagepullsecret to a service account

1. create a imagepull secret 
2.  


================================

# 

kubectl get pods \
--server <https://localhost:64418> \
--client-key krishna.key \
--client-certificate krishna.crt \
--certificate-authority krishna-ca.cert


# instead use
kubectl get pods <service account>

# but for that sa need to have the access

kubectl get pods --as build-sa      # forbidden, as no access

kubectl auth can-i get pods --as build-sa     # no, the answer is


===============================

# create a role & role binding for service account

kubectl create role build-role \
--verb=list,get,watch \
--resource=pod

# now create role binding

kubectl create rolebinding rb \
--role=build-role \
--user=build-sa          #user is service acccount


# now test the service account to get the pods

kubectl auth can-i get pods --as build-sa

kubectl get pods --as build-sa

==================================

# REST api call to pass the service account details



==================================

# location where token reside inside container or pod

# so, service account is mounted to the pods



==================================

# files which are mountes part of service account

kubectl exec -it <conteiner/pod> -- bash
root@pod: cd /var/run
root@pod: ls -rlt

root@pod: cd secrets/
root@pod: ls rlt

root@pod: cd kubernestes.io
root@pod: ls -ltr

root@pod: cd serviceaccount/
root@pod: ls -ltr

> ..data/token , ..data/namespace , ..data/ca.crt

# these files are mounted as a directory or volume inside a container or pod

====================================

kubectl get sa
kubectl delete sa build-sa




