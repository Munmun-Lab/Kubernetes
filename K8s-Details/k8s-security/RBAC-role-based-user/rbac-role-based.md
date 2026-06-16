# Kubernetes RBAC (Role-Based Access Control) 

**RBAC (Role-Based Access Control)** is a Kubernetes security mechanism that controls **who can access what resources and what actions they can perform**.

### RBAC Components

| Component          | Purpose                                                   |
| ------------------ | --------------------------------------------------------- |
| Role               | Defines permissions within a namespace                    |
| RoleBinding        | Assigns a Role to a User, Group, or ServiceAccount        |
| ClusterRole        | Defines permissions across the entire cluster             |
| ClusterRoleBinding | Assigns a ClusterRole to a User, Group, or ServiceAccount |


### How RBAC Works

```text
User / ServiceAccount
          ↓
RoleBinding / ClusterRoleBinding
          ↓
Role / ClusterRole
          ↓
Permissions
          ↓
Kubernetes Resources
```



### Example

#### Role

```yaml
kind: Role
metadata:
  namespace: dev
  name: pod-reader

rules:
- resources: ["pods"]
  verbs: ["get","list","watch"]
```

#### RoleBinding

```yaml
kind: RoleBinding
metadata:
  namespace: dev
  name: pod-reader-binding

subjects:
- kind: User
  name: developer1

roleRef:
  kind: Role
  name: pod-reader
```




### Role vs ClusterRole

| Feature           | Role             | ClusterRole    |
| ----------------- | ---------------- | -------------- |
| Scope             | Single Namespace | Entire Cluster |
| Access Pods       | Yes              | Yes            |
| Access Nodes      | No               | Yes            |
| Access Namespaces | No               | Yes            |

---

### In Short

> Kubernetes RBAC controls access to cluster resources by assigning permissions through Roles/ClusterRoles and granting them to Users, Groups, or Service Accounts using RoleBindings or ClusterRoleBindings.
