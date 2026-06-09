### TLS Certificates in Kubernetes

TLS (Transport Layer Security) certificates are used in Kubernetes to **encrypt communication (HTTPS)** between users, applications,cluster components and verify identity between components.

#### Where TLS is Used

| Component    | Purpose                             |
| ------------ | ----------------------------------- |
| Ingress      | HTTPS access to applications        |
| API Server   | Secure communication with `kubectl` |
| etcd         | Encrypt cluster database traffic    |
| Kubelet      | Secure node communication           |
| Service Mesh | Pod-to-Pod mTLS encryption          |
| Web App      | Web application <-> Users/Client    |


**TLS (Transport Layer Security)** is what makes: https://myapp.com -> https://myapp.com

- Benefits or why we use TLS:
  * Encrypts traffic -> Encryption
  * Protects passwords and data -> Authentication
  * Verifies server identity -> Secure Communication


#### Where TLS is Used in Kubernetes

```text
* Ingress HTTPS:  User -> HTTPS -> Ingress -> Service -> Pod
```
```text
* API Server Communication:  kubectl --> Kubernetes API Server
```
```text
* Pod-to-Pod Communication:  Using service mesh like,
  * Istio
  * Linkerd
```

##### TLS Certificate Components: 

| File    | Purpose                    |
| ------- | -------------------------- |
| tls.crt | Public Certificate         |
| tls.key | Private Key (never share)  |

Image:

---

#### Create Self-Signed Certificate (using OpenSSL)


Generate private key:              |        Explanation                  |
---------------------------------  | ----------------------------------  |
openssl genrsa -out tls.key 2048   | #openssl      -> SSL tool           |
                                   | #genrsa       -> Generate RSA key   |
                                   | #-out tls.key -> Save as tls.key    |
Output:  tls.key                   | #2048         -> Key size           | 
-----------------------------------------------------------------------


#### Generate self signed certificate:

 openssl req -new -x509 \       | req          | Certificate request     
 -key tls.key \                 | -new         | Create new              
 -out tls.crt \                 | -x509        | Self-signed certificate
-days 365                       | -key tls.key | Use private key         
------------------------------- | -out tls.crt | Output certificate      
output: tls.crt                 | -days 365    | Valid for 365 days      



#### Verify Certificate

Command:                                | x509 -> Certificate format
openssl x509 -in tls.crt -text -noout   | -in -> Input Certificate
                                        | -text -> Show Details
-------------------------------------   | -noout -> Don't print raw certificate
Shows: Issuer, Subject,Expiry Date      |


#### Create Kubernetes TLS Secret

Kubernetes stores certificates as Secrets.

- Command:
  ```bash
  kubectl create secret tls my-tls-secret \   # my-tls-secret -> Secret name
  --cert=tls.crt \                            # --cert -> Certificate
  --key=tls.key                               # --key -> Private key
  ```

- Verify:
  ```bash
  kubectl get secret     # Output -> mmy-tls-secret
  ```

- Check details:
  ```bash
  kubectl describe secret my-tls-secret
  ```

- Shows:
  ```text
  Type: kubernetes.io/tls
  ```

---

# View Secret YAML
  
  ```bash
  kubectl get secret my-tls-secret -o yaml
  ```

Output: Encoded in Base64.

```yaml
data:
  tls.crt: LS0tLS...
  tls.key: LS0tLS...
```

Decode:  
  ```bash
  echo "LS0tLS..." | base64 -d
  ```

---

### Use TLS Secret in Ingress

Example:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress

spec:
  tls:                                
  - hosts:
      - myapp.local
    secretName: my-tls-secret   #This tells ingress to Use certificate from my-tls-secret

  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```


- Apply Ingress: kubectl apply -f ingress.yaml
 
- Verify:  kubectl get ingress

- Check Certificate from Browser: https://myapp.local


### Mount Certificate Inside Pod

```yaml
#Create volume

volumes:
- name: tls-volume
  secret:
    secretName: my-tls-secret

#Mount

volumeMounts:
- name: tls-volume
  mountPath: /etc/tls
```

Inside container:
  ```text
  /etc/tls/tls.crt
  /etc/tls/tls.key
  ```

- Verify: kubectl exec -it pod-name -- ls /etc/tls

Output:
  ```text
  tls.crt
  tls.key
  ```

---

#### Certificate Expiry Check

Check locally:                            | Output:
----------------------------------------- | -----------------------------------------
```bash                                   | notAfter=Jun 09 2027
openssl x509 -enddate -noout -in tls.crt  |
```
----------------------------------------- | ------------------------------------------
Check remote site:                        | Useful for troubleshooting HTTPS issues
```bash                                   |
openssl s_client -connect myapp.local:443 |
```                                       |
--------------------------------------------------------------------------------------

### Production Environment

In real projects, we usually don't create certificates manually. We use **cert-manager**. It automatically creates,

  * Creates certificates
  * Renews certificates
  * Updates secrets
  * 
```text
Flow: Encrypt -> cert-manager -> TLS Secret -> Ingress 
```


## Common Use Case: HTTPS for an Application

#### Step 1: Create TLS Certificate

Using OpenSSL: tls.cert -> Certificate & tls.key -> Private Key

```bash
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout tls.key \
-out tls.crt \
-subj "/CN=myapp.example.com"
```

#### Step 2: Create Kubernetes TLS Secret

```bash
kubectl create secret tls myapp-tls \
  --cert=tls.crt \
  --key=tls.key
```

Verify: kubectl get secret myapp-tls
Output: kubernetes.io/tls
TYPE

#### Step 3: Use Certificate in Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress

spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls            # certificate used here as a TLS secret

  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

### How Kubernetes Stores TLS Certificates

- TLS certificates are stored as Secrets:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-tls

type: kubernetes.io/tls

data:
  tls.crt: LS0tLS1CRUdJTi...
  tls.key: LS0tLS1CRUdJTi...
```

- View: kubectl get secret myapp-tls -o yaml

- Decode certificate:
      ```bash
      kubectl get secret myapp-tls \
      -o jsonpath='{.data.tls\.crt}' | base64 -d
      ```

### Mount TLS Certificate Inside Pod

```yaml
volumes:
- name: tls-volume
  secret:
    secretName: myapp-tls

containers:
- name: app
  image: nginx

  volumeMounts:
  - name: tls-volume
    mountPath: /etc/tls
    readOnly: true
```

- Inside container:
      ```bash
      /etc/tls/tls.crt
      /etc/tls/tls.key
      ```

##### - What is mTLS?

**Mutual TLS** means: Client validates Server AND Server validates Client.
Used in service meshes such as Istio for secure Pod-to-Pod communication.

##### - What is a TLS Secret?

A Kubernetes Secret of type:
  -  kubernetes.io/tls

##### Difference between ConfigMap and TLS Secret?

| ConfigMap          | Secret                        |
| ------------------ | ----------------------------- |
| Non-sensitive data | Sensitive data                |
| Configurations     | Passwords, Keys, Certificates |

