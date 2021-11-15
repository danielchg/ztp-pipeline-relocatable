#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -m

# variables
# #########
# uncomment it, change it or get it from gh-env vars (default behaviour: get from gh-env)
# export KUBECONFIG=/root/admin.kubeconfig   
export KUBECONFIG="$OC_KUBECONFIG_PATH"

echo ">>>> Modify files to replace with pipeline info gathered"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
sed -i "s/CHANGEME/$OC_ACM_VERSION/g" 03-subscription.yml

echo ">>>> Deploy manifests to install ACM $OC_ACM_VERSION"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
oc create -f 01-namespace.yml; sleep 2
oc create -f 02-operatorgroup.yml; sleep 2
oc create -f 03-subscription.yml; sleep 2


echo ">>>> Wait for ACM to be ready"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

while [ "$timeout" -lt "60" ] ; do
  oc get crd | grep -q multiclusterhubs.operator.open-cluster-management.io && ready=true && break;
  echo "Waiting for CRD multiclusterhubs.operator.open-cluster-management.io to be created"
  sleep 5
  timeout=$(($timeout + 5))
done
if [ "$ready" == "false" ] ; then
 echo "timeout waiting for CRD multiclusterhubs.operator.open-cluster-management.io"
 exit 1
fi
echo "ACM version $OC_ACM_VERSION deployed!"

echo ">>>>EOF"
echo ">>>>>>>"

