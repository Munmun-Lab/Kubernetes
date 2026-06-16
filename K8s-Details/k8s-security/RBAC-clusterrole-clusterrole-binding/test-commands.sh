kubectl api-resources namespaced=true              # gives all resouces in the namespace level
kubectl api-resources namespaced=false             #  gives all resouces in the cluster level


# check the permission for the user krishna

kubectl auth can-i get nodes --as krishna          # resources "nodes" is not namespace scoped, so no


=================
# create a resouce clusterrole

kubectl create clusterrole --help

kubectl create clusterrole node-reader --verb=get,list,watch --resource=node

kubectl get clusterrole
kubectl get clusterrole | grep node-reader

kubectl describe clusterrole/node-reader

============================================

# create a clusterrole binding to attach the above role to user or a group

kubectl clusterrolebinding --help

kubectl create clusterrolebinding reader-binding --clusterrolename=node-reader --user=krishna

kubectl get clusterrolebinding

kkubectl get clusterrolebinding | grep reader

kubectl describe clusterrolebinding/reader-binding                  # this will show user krishna will have node-reader role on this cluster 

==============================================

# validate & switch the context & login with krishna user 

kubectl config get-contexts

kubectl auth can-i get nodes --as krishna

kubectl config user-context krishna

kubectl get nodes

kubectl describe nodes

kubectl delete node cka-cluster2-worker          # forbidden, as user krishna not have the access to delete the resouces


====================================================

