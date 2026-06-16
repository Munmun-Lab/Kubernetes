
- What is a Kubernetes network policy
- Why do we use a network policy in Kubernetes
- Create a cluster that supports network policy
- Install a network add-on such as Calico
- Create a network policy to restrict access to the pods


### What is a network policy

Network policy allows you to control the Inbound and Outbound traffic to and from the cluster.
For example, you can specify a deny-all network policy that restricts all incoming traffic to the cluster, or you can create an allow-network policy that will only allow certain services to be accessed by certain pods on a specific port.

 ![network-policy-in-kubernetes](https://github.com/user-attachments/assets/c7d2c77f-e12d-488b-8158-f7d2b3d4d10a)


#### Document to install `calico` on your cluster

https://docs.tigera.io/calico/latest/getting-started/kubernetes/kind


## Kubernetes Network Policy (Short Explanation)

A **Kubernetes Network Policy** is a security rule that controls **which Pods can communicate with other Pods or external networks**. It is like a  **firewall for Kubernetes Pods**.


### Why do we need it?

Without Network Policies:

* Any Pod can communicate with any other Pod in the cluster.
* This is not secure for production environments.

With Network Policies:

* You can allow or deny only required traffic based on (Pod labels, Namespace labels, IP addresses, Port numbers)
* Block unauthorized communication between applications.

---

## Example Scenario

```text
Frontend Pod  ---> Backend Pod ---> Database Pod
```

Requirements: Network Policies help enforce these rules.

- ✅ Frontend can access Backend
- ✅ Backend can access Database
- ❌ Frontend cannot access Database directly
- ❌ Any random Pod → Database


---

## Types of Rules

| Type             | Controls                           |
| ---------------- | ---------------------------------- |
| Ingress          | Incoming traffic to a Pod          |
| Egress           | Outgoing traffic from a Pod        |
| Ingress + Egress | Both incoming and outgoing traffic |


### 1. Ingress Policy

Controls **incoming traffic** to a Pod.

Example: Allow traffic to Backend only from Frontend

---

### 2. Egress Policy

Controls **outgoing traffic** from a Pod.

Example: Allow Backend to connect only to Database


---

### 3. Ingress + Egress Policy

Controls both  Incoming traffic and Outgoing traffic

Example: "Who can enter my house and where can I go?"


---

## Sample Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy

metadata:
  name: backend-policy

spec:
  podSelector:
    matchLabels:
      app: backend

  policyTypes:
  - Ingress
  - Egress

  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend

  egress:
  - to:
    - podSelector:
        matchLabels:
          app: db

    ports:
    - protocol: TCP
      port: 3306
```

### Meaning

* Apply policy to Pods with label `app=backend`
* Allow incoming traffic only from Pods with label `app=frontend`
* All other incoming traffic is denied

---

## Important Notes

### 1. Network Policy works only if CNI supports it (Not all CNIs support Network Policies)

Supported CNIs (Plugins):

* Calico ✅
* Cilium ✅
* Weave Net ✅
* Antrea ✅


---

### 2. Default Behavior

If no Network Policy exists:

```text
Allow All Traffic
```

Once a Pod is selected by a Network Policy:

```text
Deny All Traffic
Except what is explicitly allowed
```

---

## Production Use Cases

| Use Case              | Example                                  |
| --------------------- | ---------------------------------------- |
| Microservice Security | Frontend → Backend only                  |
| Database Protection   | Only Backend can access DB               |
| Namespace Isolation   | Dev namespace cannot access Prod         |
| Internet Restriction  | Block Pods from accessing external sites |
| Compliance            | PCI-DSS, Banking, Healthcare security    |

---

## Network Policy Rules

1. Default Allow: Everything is allowed
2. Default Deny: All incoming traffic is blocked
    - Create an empty Network Policy

```yaml    
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}

  policyTypes:
  - Ingress
```

3. Allow All: All traffic allowed

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
spec:
  podSelector: {}

  ingress:
  - {}

  egress:
  - {}

  policyTypes:
  - Ingress
  - Egress
```


4. Namespace-Based Policy: Allow traffic from Pods in a specific namespace

```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        name: production
```


5. IP-Based Policy: Allow traffic from a specific IP range

```yaml
ingress:
- from:
  - ipBlock:
      cidr: 10.0.0.0/24
```


---

## In short 

**Kubernetes Network Policy is a firewall-like resource that controls ingress and egress traffic between Pods, Namespaces, and external networks within a Kubernetes cluster.**
