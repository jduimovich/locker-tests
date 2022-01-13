#!/bin/bash

oc create namspace resource-locker-operator 
read -r -d '' PATCH <<'PATCH'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: resource-locker-operator 
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: resource-locker-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: resource-locker-operator
spec:
  targetNamespaces: []
PATCH
echo "$PATCH"
echo "$PATCH" | oc apply -f - 
