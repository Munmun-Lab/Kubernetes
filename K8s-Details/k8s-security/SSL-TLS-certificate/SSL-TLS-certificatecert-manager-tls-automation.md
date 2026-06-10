### Below are the **step-by-step cert-manager automation flow in Kubernetes** :

* Request Certificate       ✓
* Install Certificate       ✓
* Renew Certificate         ✓
* Update Secret             ✓

* * Pre-requisite: cert-manager installed in cluster
  - cert-manager is not part of core kubernetes, hence need to install as a CRD - Custom Resource Defination explicitly.
  * Install steps:
  - 1. kubectl create namespace cert-manager
    2. kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml
    3. Install usingHelm Repo:
    -  1. helm repo add jetstack https://charts.jetstack.io
       2. helm repo update
       3. helm install cert-manager jetstack/cert-manager --namespace cert-manager

* * Verify the Certificate: kubectl get pods -n cert-manager
    - cert-manager
    - cert-manager-cainjector
    - cert-manager-webhook
- All the above certificate dependency pod will be running state.



### ✅ TLS Automation using cert-manager

* An Issuer or ClusterIssuer (Let’s Encrypt or internal CA or 3rd party CA
* And their ACME(Automatic Certificate Management Environment endpoint).

Example Issuer:

```yaml id="issuer01"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: admin@example.com                                    # update will be send to this email id 
    server: https://acme-v02.api.letsencrypt.org/directory      # acme endpoint server address
    privateKeySecretRef:                                        # acme server authentication provate key stored on this secret
      name: letsencrypt-prod-key
    solvers:                    # A solvers tells cert-manager to prove himself as a owner 
    - http01:                   # cert-manager use the http challenge
        ingress:                # cert-manager use the ingress controller to expose the challenge temporarily
          class: nginx          # temporary nginx ingress controller, other(alb, traefik,Istio) ingress controller can also be used, alb, 
```



### 1️⃣ Request Certificate (Auto CSR creation)

- Create a Certificate resource:

```yaml id="cert01"
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: myapp-cert
  namespace: default
spec:
  secretName: myapp-tls      # after obtaining certificate cert-manager will create automatically this secret & store the tls.key & tls.crt
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - myapp.example.com      # this domain name that will be placed inside the certificate, encrypt will verify using HTTP/DNS challenge the domain ownership
```

- Apply:
```bash id="cmd01"
kubectl apply -f certificate.yaml
```



### 2️⃣ Install Certificate (Auto Secret Creation)

- cert-manager automatically:  Certificate → CSR → CA → Signed Cert → Secret
- Check secret:  kubectl get secret myapp-tls
- Output:  TYPE: kubernetes.io/tls
- View files inside:  kubectl get secret myapp-tls -o yaml
- You will see: * tls.crt  &  * tls.key



### 3️⃣ Use Certificate in Application (Install in Ingress)

```yaml id="ing01"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls     # here is the reference of the secret of the tls to get the certificate updated automatically
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

- Apply:  kubectl apply -f ingress.yaml



### 4️⃣ Renewal (Fully Automatic)

cert-manager handles renewal automatically.

- Default behavior:
    * Starts renewal at **~30 days before expiry**
    * No manual intervention required

- Check renewal:  kubectl describe certificate myapp-cert
- Look for:  
    - Renewal Time
    - Next Private Key Secret Rotation
           


### 5️⃣ Secret Update (Automatic Rotation)

- When renewal happens, cert-manager automatically:

```text id="flow02"
New Certificate Issued -> Secret Updated (myapp-tls) -> Pods use new cert automatically (if mounted)
```
 
- Check secret changes:  kubectl get secret myapp-tls -o yaml
- You will see updated:
    * tls.crt (new certificate)
    * tls.key (unchanged or rotated depending config)



### 🔄 End-to-End Flow

```text id="flow03"
Certificate YAML
      ↓
cert-manager creates CSR
      ↓
Issuer signs certificate
      ↓
Kubernetes Secret created (tls.crt + tls.key)
      ↓
Ingress uses Secret for HTTPS
      ↓
cert-manager monitors expiry
      ↓
Auto-renewal triggered
      ↓
Secret updated automatically
```




#### 🎯 Key  Points

##### 1. What triggers certificate creation?  👉 Certificate CRD

##### 2. Where is certificate stored?  👉 Kubernetes Secret (`kubernetes.io/tls`)

##### 3. Who renews certificates?  👉 cert-manager controller

##### 4. Do we manually update Ingress?  👉 ❌ No, secret is auto-updated



