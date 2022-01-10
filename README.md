
Tests using ResourceLocker 

This repo contains some simple tests to validate the resource locker behaviour.
This first test only patches a configmap with a hard coded value. 

### Prereq 
Install resource locker operator on your cluster to run these tests.
You also need `oc` and `jq` (for printing) to run the scripts.  

1) patch a random configmap with a value. 

To run it, you can use this script. 
```
./configmap-test.sh
```

The loop patches the value and watches for resourcelocker to patch it back.
This works but in the role `./patch-dm/role.yaml` it needed to be configured for `configmaps` instead of `configmap` for some reason (bug ?).


2) Patching a cluster scoped CR doesn't seem to work. The resource locker claims success but the value is unchanged. 

The use case is trying to patch a CR from the OpenShift Pipelines Operator. 

Install openshift pipelines using the following
```
./install-osp.sh
```

You can verify you have the CR being patched via 

```
oc get TektonConfig config -o yaml
```

The resource locker is looking to patch the pruner field to "5".

```
./tekton-test.sh
```

The status seeems to claim claim success but will not change the value so the test fails
