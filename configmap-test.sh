#!/bin/bash

DIR=patch-cm
PATCH_CR=$( yq e '.kind' $DIR/lock.yaml) 
NS=locker-test-ns   
NM=lock-configmap-value

oc get namespace/$NS 
RC=$?
if [ "${RC}" != 0 ]; then
    echo "Creating namespace and service-account" 
    oc new-project  $NS  
    oc create sa patch-configmap-sa -n $NS
fi 
oc delete -f $DIR
oc apply -f $DIR 
while true ; do    
echo "Patching configmap \n"  
echo kubectl patch configmap random-configmap -n $NS -p \
    '{"data":{"random-data":"badvalue"}}' --type=merge
kubectl patch configmap random-configmap -n $NS -p \
    '{"data":{"random-data":"badvalue"}}' --type=merge
echo "resource locker will patch this back\n"  
oc get $PATCH_CR $NM -n $NS -o 'jsonpath={.spec}' | jq 
oc get $PATCH_CR $NM -n $NS -o 'jsonpath={.status}'  | jq 
oc get cm random-configmap -n $NS -o yaml -o 'jsonpath={.data}'
 

VALUE=$(oc get cm random-configmap -n $NS -o yaml -o 'jsonpath={.data.random-data}')

if [ "$VALUE" = "good" ]; then 
    echo
    echo "$PATCH_CR Success, value is $VALUE"
else
    echo
    echo "$PATCH_CR Fail, value is $VALUE, should be good"
fi 

echo 
sleep 5 
done
