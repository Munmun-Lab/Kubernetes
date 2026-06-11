kubernetes can-i get pod
kubectl auth whoami

kuberctl auth can-i get pod --as <user>
kubectl auth can-i get pod --as <user> --namespace <namespace>

kubectl apply -f role.yml
kubectl describe role pod-reader -n default
kubectl auth can-i get pod --as <user> -n default   

kubectl apply -f rolebinding.yml
kubernetes get rolebinding 
kubectl describe rolebinding read-pods -n default
kubectl auth can-i get pod --as <user>

kubectl get roles
kubectl get roles -A
kubectl get roles -A --no-headers | wc -l


#login as user 

kubectl config set-credentials <username> \
--client-key=/path/to/client-key.pem \
--client-certificate=/path/to/client-cert.crt \
--embed-certs=true    #embed certs in kubeconfig file is deprecated in kubectl v1.24 and removed in v1.25

> User is set up in kubeconfig file with client certificate authentication. Now you can use kubectl commands with --as <username> to test the permissions of that user.

#set the context to use the new user
kubectl config set-context <context-name> \
--user=<username> \
--cluster=<cluster-name>

> new context is created that uses the specified user and cluster. You can switch to this context to test the permissions of the user.

kubectl get-contexts  # output will show the new context with the specified user and cluster
kubectl config use-context <context-name>  # switch to the new context
kubectl ge-contexts  # output will show the current context is now set to the new context with the specified user and cluster


kubectl auth whoami # show the current user
kubectl auth whoami --show-token  # show the token being used for authentication
kubectl auth can-i get pods  # check if the current user can get pods


# issue identifies with certificate expired
openssl x509 -noout -in /path/to/client-cert.crt -enddate -noout


# for reverse search in bash shell history, run the below:
ctrl + r -> type the command to search with few characters -> press enter to execute the command


# create a new client/user certificate with openssl command
openssl genrsa -out client-key.key 2048    # generate a new private key
openssl req -new -key client-key.key -out client-csr.csr -subj "/CN=<username>/O=<group>"  # create a certificate signing request (CSR) with the specified subject using the generated private key

ls -lrt  # list files in long format sorted by modification time, with the most recently modified file at the top

# create a CSR file with the specified subject using the generated private key

# get the request to put in the CSR file
cat client-csr.csr  # display the contents of the CSR file
cat client-csr.csr | base64 | tr -d '\n'  # encode the CSR file in base64 and remove newlines for use in Kubernetes CSR resource

# copy the csr encoded string & paste in the csr.yaml file in the request field. 
#Then apply the csr.yaml file to create a CSR resource in Kubernetes. After that, you can approve the CSR to generate a client certificate for the user.

kubectl apply -f csr.yaml  # create a CSR resource in Kubernetes using the specified YAML file
kubectl get csr  # list all CSR resources in Kubernetes
kubectl describe csr <csr-name>  # display detailed information about the specified CSR resource
kubectl certificate approve <csr-name>  # approve the specified CSR to generate a client certificate
kubectl get csr <csr-name> -o jsonpath='{.status.certificate}' | base64 --decode > client-cert.crt  # extract the generated client certificate from the approved CSR    


#validate the new client certificate and test the permissions of the user associated with that certificate
kubectl get pods --as <username>  # test if the user can get pods using the new client certificate  
kubectl auth can-i get pods --as <username>  # check if the user has permission to get pods using the new client certificate
kubectl auth whoami --as <username>  # show the current user when using the new client certificate
kubectl auth can-i get pods # in which user we loggedin currently, check if that user can get pods

# incase you are in different context or directory, you need to switch to the correct one

kubectl config get-contexts  # list all available contexts in kubeconfig file
kubectl config use-context <context-name>  # switch to the specified context


# now once rolebinding done, test the aithentication and authorization for the user
kubectl auth can-i get pods --as <username>  # check if the user can get pods after rolebinding
kubectl auth can-i create pods --as <username>  # check if the user can create pods after rolebinding
kubectl auth can-i delete pods --as <username>  # check if the user can delete pods after rolebinding



kubectl confif set-credentials <username> \
--client-key=/path/to/client-key.key \
--client-certificate=/path/to/client-cert.crt \
--embed-certs=true    


kubectl get csr -o yaml > output-approved-csr.yaml  # export the approved CSR resource to a YAML file for reference or backup
#from this file just copy the status.certificate and key to a secure location for future use, as they are needed for authentication when using kubectl commands with the specified user.

# decode this status.certificate to use as CSR approved client certificate 
echo "-----BEGIN CERTIFICATE-----" | base64 -d | tr -d '\n' > client-approved-cert.crt

# save this approve crtificate in a secure location for future use, as it is needed for authentication when using kubectl commands with the specified user.

# Now run the command again to set the context to the new user with the approved client certificate

kubectl config set-credentials <username> \
--client-key=/path/to/client-key.key \
--client-certificate=/path/to/client-approved-cert.crt \
--embed-certs=true 


#set the context to use the new user with the approved client certificate
kubectl config set-context <context-name> \
--user=<username> \
--cluster=<cluster-name>    

#
kubectl config get-contexts  # output will show the new context with the specified user and cluster
kubectl config use-context <context-name>  # switch to the new context
kubectl get-contexts  # output will show the current context is now set to the new context with the specified user and cluster
kubectl auth whoami  # show the current user with the approved client certificate
kubectl auth can-i get pods  # check if the user with the approved client certificate can get pods


# now if you try to do some other actions , like get deployments, we can't
# for that we need to add the permission in the role.yml file and then apply the changes to update the role with the new permissions. After that, you can test the permissions again using the same commands.   



# imperatiove way to declare & role & rolebinding
kubectl create role pod-reader --verb=get,list,watch --resource=pods -n default
kubectl create rolebinding read-pods --role=pod-reader --user=<username> -n default

# once this done, add the credentials/permissions to the kubeconfig file for the user and then test the permissions using the same commands as mentioned above.
# then add to the context and switch to the new context to test the permissions of the user with the new role and rolebinding. 


# data of the default kubeconfig file is stored in Home directory (~/.kube/config). You can view the contents of this file to see the current contexts, users, and clusters configured for kubectl. You can also edit this file to add new contexts, users, or clusters as needed. However, it is recommended to use kubectl config commands to manage the kubeconfig file instead of editing it directly to avoid syntax errors or misconfigurations.
cat ~/.kube/config  # display the contents of the kubeconfig file   
kubectl config view  # display the current configuration of kubectl, including contexts, users, and clusters

# This all are kubernetes api, but if we want to call REST API directly, 
# we can use curl command to call the Kubernetes API server with the appropriate authentication and authorization headers.
# Rest API call
curl -k https://<kubernetes-api-server>:6443/api/v1/pods \  # control plane API server endpoint for getting pods
--key /path/to/client-key.key \  # specify the client key for authentication
--cert /path/to/client-cert.crt \  # specify the client certificate for authentication
--cacert /path/to/ca-cert.crt \  # specify the CA certificate to verify the API server's identity
--header "Content-Type: application/json" \  # specify the content type of the request body
-H "Authorization: Bearer <token>"  # include the authentication token in the request header

