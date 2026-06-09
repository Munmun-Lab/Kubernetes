## Task for TLS certificates in Kubernetes

1. Generate a PKI private key and CSR and name it as learner.key and learner.csr 
2. Create a CertificateSigningRequest for learner and set the expiration date to 1 week
3. Make sure to use the encoded value of csr in the request field
4. Approve the csr
5. Retrieve the certificate from the CSR
6. Export the issued certificate from the CertificateSigningRequest to a yaml
7. Redirect the certificate value to learner.crt file after decoding it
8. Verify the steps one more time, we will use these details in the next task.

#### Step 1 - Generate a PKI private key and CSR and name it as learner.key and learner.csr
  - openssl genrsa -out learner.key 2048
  - openssl req -new -key learner.key -out learner.csr -days 7 -subj "/CN=yapp.example.com"

##### Generate self signed certificate (for labs/testing)
```bash
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout learner.key \
-out learner.crt \
-subj "/CN=myapp.example.com"
```

##### Generate a CSR (for production / CA signing)
```bash
openssl req -new \
-newkey rsa:2048 \
-nodes \
-keyout learner.key \
-out learner.csr \
-subj "/CN=myapp.example.com"
```
  * Then send **learner.csr** to a CA or use it with cert-manager

#### Step 2 - Encode the CSR to use the same
  - cat learner.csr | base64 | tr -d '\n'

#### Step 3 - Create the CertificateSigningRequest (CSR) (1 week expiration)
```bash
cat <<EOF > learner-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: learner
spec:
  request: <PASTE_BASE64_ENCODED_CSR_HERE>  #from Step 2
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 604800   # Second value for 7 days
  usages:
  - client auth
EOF
```

#### Step 4 - Create CSR Resource 
  - kubectl apply -f learner-csr.yaml

#### Step 5 - Verify CSR
 - kubectl get csr learner

#### Step 6 - Approve CSR
 - kubectl certificate approve learner

#### Step 7 - Verify Approved Status
- kubectl get csr learner    or,  - kubectl describe csr learner

#### Step 8 - Retrieve Certificate from CSR
 - kubectl get csr learner -o yaml

#### Step 9 - Export Issued Certificate to a YAML
 - kubectl get csr learner -o yaml > learner-issued-cert.yaml                #exported issues cert in learner-issued-cert.yaml file

#### Step 10 - Extract and Decode Certificate
kubectl get csr learner \
-o jsonpath='{.status.certificate}' | base64 -d > learner.crt                #decoded cert saved in learner.crt

#### Step 11 - Verify Certificate
 - openssl x509 -in learner.crt -text -noout

#### Step 12 - Verify All Generated Files
 - ls -l learner.key learner.csr learner.crt

#### Step 13 - Check Certificate Subject
openssl x509 -in learner.crt -subject -noout

#### Step 14 - Check Certificate Expiry
openssl x509 -in learner.crt -enddate -noout



---

**Q: Where does Kubernetes store the signed certificate after a CSR is approved?**
Answer:
- In the CertificateSigningRequest object's  [.status.certificate field.]
- We can retrieve it with: kubectl get csr <name>  -o jsonpath='{.status.certificate}' | base64 -d
- then decode it to obtain the actual `.crt` certificate file, using: base64 -d 


