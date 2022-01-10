#!/bin/bash

NS=locker-test-ns 
oc get namespace/$NS 
RC=$?
if [ "${RC}" != 0 ]; then
    echo "Creating namespace and service-account" 
    oc new-project  $NS  
    oc create sa patch-configmap-sa -n $NS
fi 
oc delete -f patch-cm
oc apply -f patch-cm  
NM=lock-configmap-value
while true ; do    
echo "Patching configmap \n"  
echo kubectl patch configmap random-configmap -n $NS -p \
    '{"data":{"random-data":"badvalue"}}' --type=merge
kubectl patch configmap random-configmap -n $NS -p \
    '{"data":{"random-data":"badvalue"}}' --type=merge
echo "resource locker will patch this back\n"  
oc get resourcelocker $NM -n $NS -o 'jsonpath={.spec.patches[0]}' | jq 
oc get resourcelocker $NM -n $NS -o 'jsonpath={.status}'  | jq 
oc get cm random-configmap -n $NS -o yaml -o 'jsonpath={.data}'
 

VALUE=$(oc get cm random-configmap -n $NS -o yaml -o 'jsonpath={.data.random-data}')

if [ "$VALUE" = "good" ]; then 
    echo
    echo "Resource Locker Success, value is $VALUE"
else
    echo
    echo "Resource Locker Fail, value is $VALUE, should be good"
fi 

echo 
sleep 5 
done
