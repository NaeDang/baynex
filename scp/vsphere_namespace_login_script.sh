#!/bin/bash
VSPHERE_WITH_TANZU_CONTROL_PLANE_IP=192.168.30.210
VSPHERE_WITH_TANZU_USERNAME=administrator@vsphere.local
VSPHERE_WITH_TANZU_PASSWORD=VMware1!
VSPHERE_WITH_TANZU_NAMESPACE=tkg-ns-sjh
KUBECTL_PATH=/usr/bin/kubectl

KUBECTL_VSPHERE_LOGIN_COMMAND=$(expect -c " spawn $KUBECTL_PATH vsphere login --server=$VSPHERE_WITH_TANZU_CONTROL_PLANE_IP --vsphere-username $VSPHERE_WITH_TANZU_USERNAME --insecure-skip-tls-verify

expect \"*?assword:*\"
send -- \"$VSPHERE_WITH_TANZU_PASSWORD\r\" expect eof ")

${KUBECTL_PATH} config use-context ${VSPHERE_WITH_TANZU_NAMESPACE}
