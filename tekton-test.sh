#!/bin/bash

DIR=patch-tektonconfig
PATCH_CR=$( yq e '.kind' $DIR/lock.yaml) 
NS=locker-patch-tekton-ns
NM=patch-tekton-pruner-config

oc get namespace/$NS 
RC=$?
if [ "${RC}" != 0 ]; then
    echo "Creating namespace and service-account" 
    oc new-project  $NS   
    oc create sa patch-tekton-config-sa -n $NS
fi  
oc delete -f $DIR -n $NS 
oc apply -f $DIR -n $NS  

while true ; do     
echo "manually patching to 777"
echo kubectl patch TektonConfig config -n openshift-pipelines -p \
    '{"spec":{"pruner":{"keep":777}}}' --type=merge
kubectl patch TektonConfig config -n openshift-pipelines -p \
    '{"spec":{"pruner":{"keep":777}}}' --type=merge
echo "resource locker should patch back.\n" 
oc get $PATCH_CR $NM -n $NS -o 'jsonpath={.spec}' | jq    
oc get $PATCH_CR $NM -n $NS -o 'jsonpath={.status}' | jq    
oc get TektonConfig config -n $NS -o 'jsonpath={.spec.pruner}' | jq   

VALUE=$(oc get TektonConfig config -n $NS -o 'jsonpath={.spec.pruner.keep}')

if [ "$VALUE" = "5" ]; then 
    echo
    echo "$PATCH_CR Success, value is $VALUE"
else
    echo
    echo "$PATCH_CR Fail, value is $VALUE, should be 5"
fi 


sleep 5 
done
