#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -m

# variables
# #########
# uncomment it, change it or get it from gh-env vars (default behaviour: get from gh-env)
# export KUBECONFIG=/root/admin.kubeconfig   

echo ">>>> Download jq, oc, kubectl and set bash completion"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
curl -Ls https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 >/usr/bin/jq
chmod u+x /usr/bin/jq

if [ ! -d "/root/bin" ]; then
    mkdir -p /root/bin
    export PATH="$PATH:/root/bin"
fi

cd /root/bin
curl -k -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz >oc.tar.gz
tar zxf oc.tar.gz
rm -rf oc.tar.gz
mv oc /usr/bin
chmod +x /usr/bin/oc

curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl >/usr/bin/kubectl
chmod u+x /usr/bin/kubectl

oc completion bash >>/etc/bash_completion.d/oc_completion

echo ">>>> Loading the Kubeconfig file"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
if [ ! -f "$OC_KUBECONFIG_PATH" ]; then
    echo "Error: Kubeconfig file not found in the path passed in github actions"
    exit 1 
fi
export KUBECONFIG="$OC_KUBECONFIG_PATH"

echo ">>>> Verify ocp server version"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
if [[ $(oc version |grep -i server | grep $OC_OCP_VERSION | wc -l) -eq 1 ]]; then
    echo "Error: OCP version not supported"
    exit 1
fi

echo ">>>> Verify oc get nodes"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>"
if [[ $(oc get nodes | grep -i ready | wc -l) -ne 1 ]] && [[ $(oc get nodes | grep -i ready | wc -l) -ne 3 ]]; then
	echo "Error: Nodes are not ready"
    exit 2
fi

echo ">>>> Verify the cluster operator ready"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
if [[ $(oc get co | awk '{print $3}' | grep -i true | wc -l) -ne $(($(oc get co | wc -l) - 1)) ]]; then
	echo "Error: some cluster operators are not ready"
    exit 3
fi

echo ">>>> Verify the metal3 pods ready"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
if [[ $(oc get pod -n openshift-machine-api | wc -l) -lt 1 ]]; then
	echo "Error: metal3 pods are not available to use ztp"
    exit 4
fi

echo ">>>> Verify the PV available"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
if [[ $(oc get pv | wc -l) -lt 3 ]]; then
    #TODO verify the PV size  and if does not exists, create it from disk 
	echo "Error: Persisten volumes not available in the hub"
    exit 5
fi

echo ">>>> EOF"
echo ">>>>>>>>"