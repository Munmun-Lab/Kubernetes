kubectl get pods
kubectl get pods --server=https://<api-server-endpoint> --token=<token>  # authenticate using a token to access the Kubernetes API server
kubectl get pods --server --client-certificate=/path/to/client-cert.crt --client-key=/path/to/client-key.key  # authenticate using client certificate and key to access the Kubernetes API server
kuberctl get pod --kubeconfig=/path/to/kubeconfig.yaml  # authenticate using a kubeconfig file that contains the necessary credentials and context to access the Kubernetes API server

#kubeconfig by default is located at ~/.kube/config, you can specify a different kubeconfig file using the --kubeconfig flag as shown above. This file contains the necessary credentials and context to authenticate and access the Kubernetes API server.
#kubeconfig by default has it's own value.

cd $HOME/.kube                       # default location of kubeconfig file
ls -lrt  # list the contents of the .kube directory to see the kubeconfig file and any other files that may be present
cat config  # display the contents of the kubeconfig file

vi config  # edit the kubeconfig file using the vi editor to add new contexts, users, or clusters as needed. Be careful when editing this file to avoid syntax errors or misconfigurations that may prevent you from accessing the Kubernetes API server. It is recommended to use kubectl config commands to manage the kubeconfig file instead of editing it directly.

=====================================================================

# search in kubernetes document kubeconfig

# login to apiserver 

ssh -> control plane node -> kubectl get pods --kubeconfig=/path/to/kubeconfig.yaml  # authenticate using a kubeconfig file that contains the necessary credentials and context to access the Kubernetes API server

docker ps | grep control  # check if the control plane container is running on the node
docker exec -it <control-plane-container-id> /bin/bash  # access the control plane container to run kubectl commands directly on the node

cd /etc/kubernetes/manifests  # navigate to the directory where the Kubernetes manifests are stored on the control plane node
ls -lrt  # list the contents of the manifests directory to see the Kubernetes manifests that are used to deploy the control plane components
cat kube-apiserver.yaml  # display the contents of the kube-apiserver manifest to see the configuration options that are used to start the API server, including the location of the kubeconfig file and any other relevant settings

-- authorization mode in kube-apiserver.yaml file  -> Node, RBAC, ABAC, Webhook, AlwaysAllow, AlwaysDeny  -> Based on the input, api server will select the authorization mode to use for authorizing the incoming requests.

-- authorization policy-file in kube-apiserver.yaml file  -> This is used to specify the path to the authorization policy file that contains the rules for authorizing the incoming requests based on the specified authorization mode. The content of this file will depend on the chosen authorization mode and will define the permissions and access control rules for users and resources in the Kubernetes cluster.

======================================================================

# all the certificates and keys are hosted in below location in api server node
cd /etc/kubernetes/pki  # navigate to the directory where the Kubernetes certificates and keys are stored on the control plane node
ls -lrt  # list the contents of the pki directory to see the certificates and keys that are used for authentication and encryption in the Kubernetes cluster
cat apiserver.crt  # display the contents of the API server certificate to see the details of the certificate, including the subject, issuer, and expiration date
cat apiserver.key  # display the contents of the API server key to see the private key that is used for authentication and encryption

