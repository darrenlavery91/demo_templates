#!/bin/bash

echo "Creating a new user team1-member"

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: team1-deployment-manager
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["create", "update", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: team1-manage-deployments
  namespace: default
subjects:
- kind: User
  name: "team1-member"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: team1-deployment-manager
  apiGroup: rbac.authorization.k8s.io
EOF


echo "Creating a new user team2-member"

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: team2-read-only
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: team2-view-pods
  namespace: default
subjects:
- kind: User
  name: "team2-member"
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: team2-read-only
  apiGroup: rbac.authorization.k8s.io

EOF

echo "Testing results"
kubectl auth can-i create deployments --namespace=default --as=team1-member  
kubectl auth can-i create deployments --namespace=default --as=team2-member