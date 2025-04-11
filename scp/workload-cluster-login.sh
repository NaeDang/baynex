#!/bin/bash
VSPHERE_WITH_TANZU_CONTROL_PLANE_IP=192.168.30.210
VSPHERE_WITH_TANZU_USERNAME=administrator@vsphere.local
VSPHERE_WITH_TANZU_PASSWORD=VMware1!
VSPHERE_WITH_TANZU_NAMESPACE=tkg-ns-sjh
VSPHERE_WITH_TANZU_TKC_NAME=tkg-cluster-sjh
KUBECTL_PATH=/usr/local/bin/kubectl

KUBECTL_VSPHERE_LOGIN_COMMAND=$(expect -c " spawn $KUBECTL_PATH vsphere login --server=$VSPHERE_WITH_TANZU_CONTROL_PLANE_IP --vsphere-username $VSPHERE_WITH_TANZU_USERNAME --insecure-skip-tls-verify --tanzukubernetes-cluster-namespace $VSPHERE_WITH_TANZU_NAMESPACE --tanzu-kubernetescluster-name $VSPHERE_WITH_TANZU_TKC_NAME expect \"*?assword:*\" send -- \"$VSPHERE_WITH_TANZU_PASSWORD\r\" expect eof ")
