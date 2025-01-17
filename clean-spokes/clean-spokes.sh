#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -m

source ${WORKDIR}/shared-utils/common.sh

if [[ -z ${ALLSPOKES} ]]; then
    ALLSPOKES=$(yq e '(.spokes[] | keys)[]' ${SPOKES_FILE})
fi

for SPOKE in ${ALLSPOKES}; do
    echo ">>>> Cleaning the deployed Spokes clusters"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo Spoke: ${SPOKE}
    oc --kubeconfig=${KUBECONFIG_HUB} delete managedcluster ${SPOKE}
    oc --kubeconfig=${KUBECONFIG_HUB} delete ns ${SPOKE}
    sleep 60
    kcli delete vm ${SPOKE}-m0 ${SPOKE}-m1 ${SPOKE}-m2 ${SPOKE}-w0 -y
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
done
exit 0
