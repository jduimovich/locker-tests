#!/bin/bash

NS=locker-patch-tekton-ns
oc get namespace/$NS 
RC=$?
if [ "${RC}" != 0 ]; then
    echo "Creating namespace and service-account" 
    oc new-project  $NS   
    oc create sa patch-tekton-config-sa -n $NS
fi  
oc delete -f patch-tektonconfig -n $NS 
oc apply -f patch-tektonconfig -n $NS  

NM=patch-tekton-pruner-config
while true ; do     
echo "manually patching to 777"
echo kubectl patch TektonConfig config -n openshift-pipelines -p \
    '{"spec":{"pruner":{"keep":777}}}' --type=merge
kubectl patch TektonConfig config -n openshift-pipelines -p \
    '{"spec":{"pruner":{"keep":777}}}' --type=merge
echo "resource locker should patch back.\n" 
oc get resourcelocker $NM -n $NS -o 'jsonpath={.spec.patches[0]}' | jq    
oc get resourcelocker $NM -n $NS -o 'jsonpath={.status}' | jq    
oc get TektonConfig config -n $NS -o 'jsonpath={.spec.pruner}' | jq   

VALUE=$(oc get TektonConfig config -n $NS -o 'jsonpath={.spec.pruner.keep}')

if [ "$VALUE" = "5" ]; then 
    echo
    echo "Resource Locker Success, value is $VALUE"
else
    echo
    echo "Resource Locker Fail, value is $VALUE, should be 5"
fi 


sleep 5 
done
