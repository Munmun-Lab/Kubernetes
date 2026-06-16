In Kubernetes, a **user is not created directly inside the cluster** like a Linux user. Kubernetes relies on an external authentication mechanism (certificates, OIDC, LDAP, cloud IAM, etc.).

The most common way is to create a user using a **client certificate** and then grant permissions through **RBAC**.

---

# Step 1: Create Private Key

```bash
openssl genrsa -out dev-user.key 2048
```

This creates:

```text
dev-user.key
```

---

# Step 2: Create Certificate Signing Request (CSR)

```bash
openssl req -new -key dev-user.key \
-out dev-user.csr \
-subj "/CN=dev-user/O=developers"
```

Where:

| Field        | Meaning  |
| ------------ | -------- |
| CN=dev-user  | Username |
| O=developers | Group    |

Kubernetes will identify:

```text
User  : dev-user
Group : developers
```

---

# Step 3: Sign Certificate Using Kubernetes CA

On the control plane node:

```bash
openssl x509 -req \
-in dev-user.csr \
-CA /etc/kubernetes/pki/ca.crt \
-CAkey /etc/kubernetes/pki/ca.key \
-CAcreateserial \
-out dev-user.crt \
-days 365
```

Generated:

```text
dev-user.crt
```

---

# Step 4: Add User to kubeconfig

```bash
kubectl config set-credentials dev-user \
--client-certificate=dev-user.crt \
--client-key=dev-user.key
```

Verify:

```bash
kubectl config view
```

---

# Step 5: Create Role

Example: Read-only access to Pods.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader

rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list","watch"]
```

Apply:

```bash
kubectl apply -f role.yaml
```

---

# Step 6: Create RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default

subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io

roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply:

```bash
kubectl apply -f rolebinding.yaml
```

---

# Step 7: Test Permissions

Create a context:

```bash
kubectl config set-context dev-user-context \
--cluster=kubernetes \
--user=dev-user \
--namespace=default
```

Switch:

```bash
kubectl config use-context dev-user-context
```

Test:

```bash
kubectl get pods
```

Expected:

```text
NAME          READY   STATUS
nginx-pod     1/1     Running
```

Try creating a pod:

```bash
kubectl run nginx --image=nginx
```

Expected:

```text
Error from server (Forbidden)
```

Because the user only has read access.

---

#### In short

**How do you create a user in Kubernetes?**

1. Generate a private key and CSR.
2. Sign the CSR using the Kubernetes CA.
3. Add the certificate to kubeconfig.
4. Create a Role or ClusterRole.
5. Bind the user to the role using RoleBinding or ClusterRoleBinding.
6. Verify permissions using `kubectl auth can-i`.

```bash
kubectl auth can-i create pods --as=dev-user
```


