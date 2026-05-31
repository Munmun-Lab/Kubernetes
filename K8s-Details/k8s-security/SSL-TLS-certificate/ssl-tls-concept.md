## SSL/TLS Certificate – Simple Real-World Understanding

Think of a website or application as a house.

* **HTTP** = sending postcards (anyone can read them)
* **HTTPS (SSL/TLS)** = sending messages inside a locked envelope

SSL/TLS provides:

1. **Encryption** → Data cannot be read by hackers.
2. **Authentication** → Confirms you are talking to the real server.
3. **Integrity** → Data cannot be modified during transmission.

---

## SSL vs TLS

| SSL              | TLS              |
| ---------------- | ---------------- |
| Older technology | Newer and secure |
| SSL 2.0, SSL 3.0 | TLS 1.2, TLS 1.3 |
| Deprecated       | Currently used   |

People still say **SSL Certificate**, but in reality modern systems use **TLS Certificates**.

---

## Simple Flow

```text
User Browser
     |
     | HTTPS Request
     |
     ▼
Server

Server says:
"Here is my TLS Certificate"

Browser verifies:
✓ Certificate valid
✓ Not expired
✓ Trusted CA
✓ Domain matches

Secure encrypted communication starts
```

---

## What is a Certificate?

A certificate is like a digital ID card.

Contains:

```text
Domain Name
Public Key
Certificate Authority (CA)
Expiry Date
Owner Information
```

Example:

```text
Domain: myapp.com
Issued By: DigiCert
Valid Till: 31-Dec-2026
```

---

## Public Key & Private Key

TLS works using two keys:

```text
Public Key
Private Key
```

### Public Key

Can be shared with everyone.

```text
public.crt
```

### Private Key

Must remain secret.

```text
private.key
```

Example:

```text
Client encrypts data
using Public Key

Only Server can decrypt
using Private Key
```

---

## What Happens During TLS Handshake?

```text
Client
  |
  | Hello
  ▼
Server

Server sends Certificate
(public key)

Client verifies certificate

Client creates session key

Session key encrypted
using public key

Server decrypts
using private key

Secure channel established
```

After this, communication is encrypted.

---

# TLS in Kubernetes

In Kubernetes, TLS is mainly used for:

### 1. Secure Ingress

```text
Internet
   |
HTTPS
   |
Ingress
   |
Service
   |
Pod
```

Users access:

```text
https://myapp.com
```

instead of:

```text
http://myapp.com
```

---

### 2. Secure API Server

All communication with Kubernetes API Server uses TLS.

```bash
kubectl get pods
```

Actually:

```text
kubectl
   |
TLS
   |
API Server
```

---

### 3. Pod-to-Pod Security

Service Meshes such as:

* Istio
* Linkerd

use **mTLS (Mutual TLS)**.

```text
Pod A <----TLS----> Pod B
```

Both verify each other's certificates.

---

# Kubernetes TLS Secret

Store certificate and key as a Secret.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret

type: kubernetes.io/tls

data:
  tls.crt: <base64-cert>
  tls.key: <base64-key>
```

Create directly:

```bash
kubectl create secret tls tls-secret \
--cert=tls.crt \
--key=tls.key
```

Check:

```bash
kubectl get secret
kubectl describe secret tls-secret
```

---

# TLS with Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ing

spec:
  tls:
  - hosts:
    - myapp.com
    secretName: tls-secret

  rules:
  - host: myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-svc
            port:
              number: 80
```

Flow:

```text
User
  |
HTTPS
  |
Ingress
  |
nginx-svc
  |
Pod
```

Ingress uses the certificate stored in `tls-secret`.

---

# cert-manager (Most Common in Production)

Instead of manually renewing certificates:

```text
Generate Cert
Renew Cert
Replace Cert
```

Use:

cert-manager

It automatically:

```text
Request certificate
Install certificate
Renew certificate
Update secret
```

Often integrated with:

Let's Encrypt

for free TLS certificates.

---

# Real-Time Production Example

Suppose you deploy an application on Amazon EKS:

```text
myapp.com
```

Steps:

```text
1. Deploy Application
2. Create Service
3. Install Ingress Controller
4. Create TLS Secret
5. Configure Ingress
6. Access via HTTPS
```

Result:

```text
https://myapp.com
```

Users get:

✓ Secure communication
✓ Trusted certificate
✓ Encrypted passwords
✓ Encrypted API traffic

---

## Quick Interview Answer

**What is SSL/TLS?**

SSL/TLS is a security protocol that encrypts communication between a client and a server, provides authentication through certificates, and ensures data integrity. SSL is deprecated, and modern systems use TLS.

**How is TLS used in Kubernetes?**

TLS is used to:

* Secure Ingress traffic (HTTPS)
* Secure communication with the Kubernetes API Server
* Enable mTLS between services using a service mesh
* Store certificates securely as Kubernetes TLS Secrets

```text
Browser
   |
 HTTPS
   |
Ingress (TLS Certificate)
   |
Service
   |
Pod
```

This is the most common Kubernetes TLS architecture you'll encounter in EKS, AKS, GKE, and on-prem clusters.
