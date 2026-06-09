* **cert-manager is not limited to Let's Encrypt**

- The purpose of cert-manager is:
    ```text
    cert-manager  -> Automates certificate lifecycle  -> Works with many Certificate Authorities (CA)
    ```

- You can use:
    * Sectigo
    * DigiCert
    * GlobalSign
    * Entrust
    * Let's Encrypt
    * Internal Enterprise PKI (Microsoft CA, Venafi, etc.)



### Important Distinction

### ClusterIssuer

`ClusterIssuer` is **not a certificate provider**.

- It is a Kubernetes resource (CRD) created by cert-manager.
```text
Certificate Authority
      ↓
Let's Encrypt
Sectigo
DigiCert
      ↓
ClusterIssuer
      ↓
Certificate
      ↓
Secret
```

- So whatever the encryption, we still use:  "kind: ClusterIssuer"

- but the backend CA changes.



#### Example 1: Let's Encrypt
```yaml
kind: ClusterIssuer
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory    # acme server endpoint
```


#### Example 2: Internal CA
```yaml
kind: ClusterIssuer
spec:
  ca:
    secretName: root-ca-secret     # internal root secret reference, cert-manager signs certificates using your organization's CA.
```



#### Example 3: Self-Signed (Useful for labs)
```yaml
kind: ClusterIssuer
spec:
  selfSigned: {}     # self signed certificate
```



#### Example 4: Sectigo or any 3rd party

  - For Sectigo, cert-manager typically uses an external issuer integration rather than the built-in ACME issuer.

The flow looks like:

```text
Certificate
      ↓
cert-manager
      ↓
Sectigo Issuer Plugin
      ↓
Sectigo CA
      ↓
Certificate
      ↓
Secret
```

Many enterprises use Sectigo or DigiCert because:
    * Corporate trust requirements
    * Commercial support
    * Extended Validation (EV)
    * Wildcard certificates
    * Internal governance



#### Points to remember:

**Q: Why specify nginx?

A cluster may have multiple ingress controllers: **NGINX**, **ALB**, **Traefik**, **Istio**. 
cert-manager must know which one to use.

Examples:

NGINX                  AWS ALB            Traefik          Istio
----------------- | ---------------- | --------------  | ---------------
ingress:          | ingress:         | ingress:        | ingress:
  class: nginx    |   class: alb     |  class: traefik |   class: istio



**Q: What is `privateKeySecretRef` used for?**
**A:** It stores the ACME account private key used by cert-manager to authenticate with the certificate authority. It is different from the TLS certificate secret used by applications.

**Q: What is `solvers.http01.ingress.class: nginx` used for?**
**A:** It tells cert-manager to use the HTTP-01 ACME challenge and create temporary resources through the NGINX Ingress Controller so the certificate authority can verify domain ownership before issuing the certificate.


**Q: What gets created during validation?

We can see temporarily during validation:

- kubectl get ingress  -> cm-acme-http-solver-xxxxx      # ingress controller temporarily created
- kubectl get pods     -> cm-acme-http-solver-xxxxx      # pod created temporarily
  
- After validation:

```text
Challenge Completed -> Certificate Issued  -> Temporary Resources Deleted
```
