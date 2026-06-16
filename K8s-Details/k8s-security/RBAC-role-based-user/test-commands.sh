kubernetes can-i get pod
kubectl auth whoami

kuberctl auth can-i get pod --as <user>
kubectl auth can-i get pod --as <user> --namespace <namespace>

=====================================================================

# here user doesn't have access, so have to create a role & rolebonding to give the access to the user to get pods.

kubectl apply -f role.yml             # role created with get, list, watch permissions on pods resource in default namespace
kubectl describe role pod-reader -n default
kubectl auth can-i get pod --as <user> -n default   


==================================================================
# to which user the created role need to be binded, we need to create a rolebinding to bind the role to the user

kubectl apply -f rolebinding.yml           # rolebinding created to bind the role pod-reader to the user <username> in default namespace
kubectl get rolebinding
kubectl describe rolebinding read-pods -n default

=====================================================================

# Now test the permissions of the user again after rolebinding
kubectl auth can-i get pod --as <user>
kubectl auth can-i get pod --as adam
=====================================================================

kubectl get roles
kubectl get roles -A         # list all roles in all namespaces
kubectl get roles -A --no-headers | wc -l        # count the total number of roles in the cluster by listing all roles in all namespaces and counting the lines of output (excluding headers)


=====================================================================

#login as user  adam

# for that we need to create a client certificate for the user adam and then add the credentials to the kubeconfig file for that user. After that, you can use kubectl commands with --as adam to test the permissions of that user.

kubectl config set-credentials <username> \
--client-key=/path/to/client-key.pem \       # client key for the user
--client-certificate=/path/to/client-cert.crt \      # client certificate for the user
--embed-certs=true    

* User is set up in kubeconfig file with client certificate authentication. Now you can use kubectl commands with --as <username> to test the permissions of that user.


======================================================================

#set the context to use the new user adam with the approved client certificate

kubectl config set-context <context-name> \
--user=<username> \
--cluster=<cluster-name>


kubectl config set-context adam \
--user=adam \
--cluster=kind-cka-cluster2

* new context adam is created that uses the specified user and cluster. You can switch to this context to test the permissions of the user.

=======================================================================
# setting the context adam to use the new user adam with the approved client certificate

kubectl get-contexts                        # output will show the new context with the specified user and cluster

kubectl config use-context <context-name>   # switch to the new context
kubectl config use-context adam             # switched to adam context
kubectl get-contexts                         # output will show the current context is now set to the new context with the specified user and cluster

=======================================================================

# Now test the permissions of the user adam with the approved client certificate

kubectl auth whoami # show the current user
kubectl auth whoami --show-token  # show the token being used for authentication
kubectl auth can-i get pods  # check if the current user can get pods


=======================================================================

# issue identifies with certificate expired
openssl x509 -noout -in /path/to/client-cert.crt -enddate -noout


openssl x509 -req -in client-csr.csr \
-CA ca.crt \
-CAkey ca.key \
-CAcreateserial -out client-cert.crt \
-days 365                                # sign the CSR with the CA certificate and key to generate a client certificate that is valid for 365 days


========================================================================

# for reverse search in bash shell history, run the below:
ctrl + r -> type the command to search with few characters -> press enter to execute the command

# get the CA certificate from the control plane node to use for signing the client certificate
scp user@control-plane-node:/etc/kubernetes/pki/ca.crt /path/to

docker exec -it <control-plane-container-id> /bin/bash  # access the control plane container to run commands directly on the node
cat /etc/kubernetes/pki/ca.crt  # display the contents of the CA
cat ca.cert
cat ca.key
# copy the ca.cert & ca.key and save in a file

========================================================================
# Authentication

# create a new user with new client certificate 
# and add the credentials to kubeconfig file for that user

openssl genrsa -out krishna-client.key 2048    # generate a new private key for the user
openssl req -new -key krishna-client.key -out krishna-client-csr.csr -subj "/CN=krishna/O=dev"  # create a certificate signing request (CSR) with the specified subject using the generated private key

ls -lrt  # list files in long format sorted by modification time, with the most recently modified file at the top

# create a CSR file with the specified subject using the generated private key
# Krishna-CSR.yml file is created with the base64 encoded CSR content in the request field. This file is applied to create a CSR resource in Kubernetes, which can then be approved to generate a client certificate for the user Krishna.

# in krishna-csr.yml file, the request field contains the base64-encoded CSR content, which is generated from the krishna-client-csr.csr file using the command below:

#spec:
  #request: <base64-encoded CSR>  
cat krishna-client-csr.csr                 # display the contents of the CSR file
cat krishna-client-csr.csr | base64        # encode the CSR file in base64 format for use in the Kubernetes CSR resource
cat krishna-client-csr.csr | base64 -w 0   # encode the
cat krishna-client-csr.csr | base64 | tr -d '\n'      # encode the CSR file in base64 format and remove newlines for use in the Kubernetes CSR resource


#   #request: <base64-encoded CSR>  , placed here the the encoded csr


# now apply the krishna-csr.yml file to create a CSR resource in Kubernetes. After that, you can approve the CSR to generate a client certificate for the user Krishna.
# validate the context to create the CSR resource in Kubernetes and then approve the CSR to generate a client certificate for the user Krishna. After that, you can add the credentials to the kubeconfig file for that user and test the permissions using kubectl commands with --as krishna.
kubectl apply -f krishna-csr.yml  # create a CSR resource in Kubernetes using the specified YAML file

kubectl config get-contexts  # list all available contexts in kubeconfig file
kubectl config use-context <context-name>  # switch to the context where the CSR resource
kubectl config use-context kind-cka-cluster2  # switch to the context where the CSR resource is created

# now after switching the context, apply the krishna-csr.yml file to create a CSR resource in Kubernetes. After that, you can approve the CSR to generate a client certificate for the user Krishna. Then add the credentials to the kubeconfig file for that user and test the permissions using kubectl commands with --as krishna.

kubectl apply -f krishna-csr.yml  # create a CSR resource in Kubernetes using the specified YAML file
kubectl get csr  # list all CSR resources in Kubernetes

# now do the self approve the certificate 
kubectl certificate approve krishna-csr  # approve the specified CSR to generate a client certificate for the user Krishna

kubectl get pods --as krishna  # validate the access
kubectl auth can-i get pod as krishna  # validate the access

kubectl auth can-i get pod         # validate the access the user we have logged in


=====================================================================    

# get the approved version csr with decode

kubectl get csr -o yaml > output-approved-csr.yaml  # export the approved CSR resource to a YAML file for reference or backup

#from this file just copy the status.certificate and key to a secure location for future use, as they are needed for authentication when using kubectl commands with the specified user.

kubectl get csr -o yaml > krishna-ca-approved.crt      # get the whole csr file, but we need only status.certificate, which need as decode format


# decode this status.certificate to use as CSR approved client certificate 
echo "-----BEGIN CERTIFICATE-----" | base64 -d | tr -d '\n' > client-approved-cert.crt

# save this approve crtificate in a secure location for future use, as it is needed for authentication when using kubectl commands with the specified user.


echo <status.certificate> | base64 -d | tr -d "/n" 

echo <status.certificate> | base64 -d | tr -d "/n"  > krishna-ca-crt.crt

kubectl get csr krishna-CSR -o jsonpath='{.status.certificate}' | base64 --decode > krishna-approved-decode-client.crt  # extract the generated client certificate from the approved CSR and save it to a file for future use


=====================================================================

# Authorization

# Now run the command again to set the context to the new user with the approved client certificate

kubectl config set-credentials <username> \
--client-key=/path/to/client-key.key \
--client-certificate=/path/to/client-approved-cert.crt \
--embed-certs=true   


kubectl config set-credentials krishna \
--client-key=krishna-client.key \
--client-certificate=krishna-approved-decode-client.crt \
--embed-certs=true

# with the above User context "krishna" set
 
# with this below command Context krishna created to set the context to use the new user(krishna) with the approved client certificate
kubectl config set-context <context-name> \
--user=<username> \
--cluster=<cluster-name>    


kube tl config set-context krishna \
--cluster=kind-cka-cluster2 \
--user=krishna

# krishna context created

# now validate the context lists
kubectl config get-contexts  # output will show the new context with the specified user and cluster
kubectl config use-context <context-name>  # switch to the new context

kubectl config use-context krishna     # switched to krishna context

kubectl get-contexts  # output will show the current context is now set to the new context with the specified user and cluster
kubectl auth whoami  # show the current user with the approved client certificate
kubectl auth can-i get pods  # check if the user with the approved client certificate can get pods

kubectl get pods    # in krishna conetxt


# now if you try to do some other actions , like get deployments, we can't
# for that we need to add the permission in the role.yml file and then apply the changes to update the role with the new permissions. After that, you can test the permissions again using the same commands.   

kubectl get deploy          # krishna conetxt is forbidden for this, as only allowed for pods


====================================================================

# imperatiove way to declare & role & rolebinding


kubectl create role developer --verb=get,list,watch --resource=pods -n default


kubectl create rolebinding developer-binding-myuser --role=developer --user=myuser -n default


# once this done, the last step is to add this user into the kubeconfig file
# First, need to add the new credentials/permissions into the kubeconfig file for the user and then test the permissions using the same commands as mentioned above.

kubectl config set-credentials myuser \
--client-key=myuser.key \
--client-certificate=myuser.crt \
--embed-certs=true


# then add to the context and switch to the new context to test the permissions of the user with the new role and rolebinding. 

kubectl config set-context myuser --cluster=kubernetes --user=myuser

# switch to context "myuser"

kubectl config use-context myuser


kubectl auth whoami         # username would be myuser


=======================================================================

# data of the default kubeconfig file is stored in Home directory (~/.kube/config). You can view the contents of this file to see the current contexts, users, and clusters configured for kubectl. You can also edit this file to add new contexts, users, or clusters as needed. However, it is recommended to use kubectl config commands to manage the kubeconfig file instead of editing it directly to avoid syntax errors or misconfigurations.

cat ~/.kube/config  # display the contents of the kubeconfig file   
kubectl config view  # display the current configuration of kubectl, including contexts, users, and clusters

========================================================================


# This all are kubernetes api, but if we want to call REST API directly, 
# we can use curl command to call the Kubernetes API server with the appropriate authentication and authorization headers.


# Rest API call


curl -k https://<kubernetes-api-server>:6443/api/v1/pods \  # to curl the control plane IP address on this port,  API server endpoint for getting pods
--key /path/to/client-key.key \  # specify the client key for authentication
--cert /path/to/client-cert.crt \  # specify the client certificate for authentication
--cacert /path/to/ca-cert.crt \  # specify the CA certificate to verify the API server's identity
--header "Content-Type: application/json" \  # specify the content type of the request body
-H "Authorization: Bearer <token>"  # include the authentication token in the request header




curl -k https://<control-plane-node-IP>:6443/api/v1/pods \  
--key /path/to/client-key.key \  
--cert /path/to/client-cert.crt \  
--cacert /path/to/ca-cert.crt \
  -o output.json                         # Save API response to a file
  

========================================================================
# Authentication

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
