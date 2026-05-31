#!/bin/bash

#############################################
# Kubernetes TLS Certificate COMMAND CHEATSHEET
#############################################

############################
# 1. Generate Self-Signed Certificate
############################

# Create private key + certificate
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=myapp.example.com"

# Verify generated files
ls -ltr tls.key tls.crt

############################
# 2. Inspect Certificate
############################

# View certificate details
openssl x509 -in tls.crt -text -noout

# Check expiration date
openssl x509 -in tls.crt -noout -enddate

# Check subject (domain info)
openssl x509 -in tls.crt -noout -subject

# Check issuer
openssl x509 -in tls.crt -noout -issuer


############################
# 3. Create Kubernetes TLS Secret
############################

# Method 1: Imperative
kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key

# Method 2: YAML apply (after base64 encoding)
# base64 encode
cat tls.crt | base64 -w 0
cat tls.key | base64 -w 0

# Apply YAML
kubectl apply -f tls-secret.yaml


############################
# 4. TLS Secret YAML (reference)
############################

cat <<EOF > tls-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: <BASE64_CERT>
  tls.key: <BASE64_KEY>
EOF


############################
# 5. View / Validate Secret
############################

kubectl get secret tls-secret

kubectl describe secret tls-secret

# Decode certificate from secret
kubectl get secret tls-secret -o jsonpath='{.data.tls\.crt}' | base64 -d

# Decode private key
kubectl get secret tls-secret -o jsonpath='{.data.tls\.key}' | base64 -d


############################
# 6. Deep Inspect Certificate from K8s Secret
############################

kubectl get secret tls-secret -o jsonpath='{.data.tls\.crt}' \
| base64 -d \
| openssl x509 -text -noout


############################
# 7. Delete / Recreate TLS Secret
############################

kubectl delete secret tls-secret

kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key


############################
# 8. Ingress TLS Check Commands
############################

kubectl get ingress
kubectl describe ingress nginx-ingress

# Check if TLS is attached
kubectl get ingress nginx-ingress -o yaml


############################
# 9. Test HTTPS Endpoint
############################

# Test TLS handshake
curl -v https://myapp.example.com

# Ignore certificate validation (for testing only)
curl -k https://myapp.example.com


############################
# 10. Debug TLS Issues in Cluster
############################

kubectl get pods -A | grep ingress

kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

kubectl describe secret tls-secret

kubectl describe ingress nginx-ingress


############################
# 11. Check API Server TLS (Advanced)
############################

kubectl get --raw /healthz

kubectl config view --raw


############################
# 12. Optional: Generate CSR (Production-style)
############################

openssl genrsa -out server.key 2048

openssl req -new -key server.key -out server.csr \
  -subj "/CN=myapp.example.com"

#############################################
# END
#############################################

