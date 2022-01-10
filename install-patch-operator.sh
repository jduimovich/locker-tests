#!/bin/bash

oc create namspace patch-operator 
read -r -d '' PATCH <<'PATCH'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: patch-operator 
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: patch-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: patch-operator
spec:
  targetNamespaces: []
PATCH
echo "$PATCH"
echo "$PATCH" | oc apply -f - 
