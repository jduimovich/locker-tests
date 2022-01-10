
Test using ResourceLocker 

You need to install resource locker operator to run these tests.
You also need oc and jq (for printing) to run the scripts 

1) patch a random configmap with a value. 

This works but the role `./patch-dm/role.yaml` needs to be configured for "configmaps" instead of configmap for some reason (bug ?).

```
./configmap-test.sh
```

2) Patching a cluster scoped CR doesn't seem to work. It claims success but the value is unchanged. 

Install openshift pipelines using the following

```
./install-osp.sh
```

You can verify you have the CR being patched via 

```
oc get TektonConfig config -o yaml
```

Looking to path the pruner field to "5".

```
./tekton-test.sh
```

The patch will claim success but will not change the value. 