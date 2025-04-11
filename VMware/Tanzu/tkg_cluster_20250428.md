# proxmox vm

export TEMPLATE_ID=9003
export VM_ID=126
export VM_NAME=tanzu-ubuntu
export VM_NIC=vmbr0
export VM_IP=192.168.0.26/24
export VM_GW=192.168.0.1
export STORAGE=local-lvm
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full true
qm set $VM_ID --machine q35,viommu=intel
qm set $VM_ID --bios ovmf --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=0
qm set $VM_ID --memory 8192 --cores 4
qm set $VM_ID --net0 virtio,bridge=$VM_NIC,firewall=1
qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW
qm set $VM_ID --net1 virtio,bridge=vmbr2,firewall=1
qm set $VM_ID --ipconfig1 ip=192.168.30.248/24,gw=192.168.30.1
qm set $VM_ID --ciupgrade 0
qm resize $VM_ID scsi0 +50G
qm snapshot $VM_ID Pre

# 접속 Supervisor Cluster 접속 방법

1. [192.168.0.52 : supervisor ](https://192.168.30.210/) : CLI plugin 다운로드 및 압축 해제
2. 압축 파일의 /bin/\* (kubectl, kubectl-vsphere) /usr/local/bin/ 으로 옮기고
3. kuberctl vsphere login
   kubectl-vsphere login --vsphere-username administrator@vsphere.local --server=https://192.168.30.210 --insecure-skip-tls-verify
4. kubectl config get-contexts

```bash
[root@localhost bin]# kubectl config get-contexts
CURRENT   NAME                         CLUSTER          AUTHINFO                                         NAMESPACE
          192.168.0.152                192.168.0.152    wcp:192.168.0.152:administrator@vsphere.local
          192.168.0.153                192.168.0.153    wcp:192.168.0.153:administrator@vsphere.local
          192.168.30.210               192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local
          svc-cci-service-domain-c55   192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local   svc-cci-service-domain-c55
          svc-tkg-domain-c55           192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local   svc-tkg-domain-c55
          svc-velero-domain-c55        192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local   svc-velero-domain-c55
```

5. vCenter 워크로드 관리에서 tkg cluster 용 namespace 생성

```bash
-         tkg-ns-sjh                   192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local   tkg-ns-sjh
```

7. 사용권한 및 사용스토리지 VMclass(flavor), Kubernetes content libary 설정
8. 해당 namespace로 전환 tkg-ns-sjh

```bash
kubectl config use-context tkg-ns-sjh
```

9. 사용가능한 tkg 버전 확인

```bash
kubectl get tkr -A

[root@localhost bin]# kubectl get tkr -A
NAME                                      VERSION                                 READY   COMPATIBLE   CREATED   TYPE
v1.16.12---vmware.1-tkg.1.da7afe7         v1.16.12+vmware.1-tkg.1.da7afe7         False   False        4h45m     Legacy
v1.16.14---vmware.1-tkg.1.ada4837         v1.16.14+vmware.1-tkg.1.ada4837         False   False        4h45m     Legacy
v1.16.8---vmware.1-tkg.3.60d2ffd          v1.16.8+vmware.1-tkg.3.60d2ffd          False   False        4h45m     Legacy
v1.17.11---vmware.1-tkg.1.15f1e18         v1.17.11+vmware.1-tkg.1.15f1e18         False   False        4h44m     Legacy
v1.17.11---vmware.1-tkg.2.ad3d374         v1.17.11+vmware.1-tkg.2.ad3d374         False   False        4h44m     Legacy
v1.17.13---vmware.1-tkg.2.2c133ed         v1.17.13+vmware.1-tkg.2.2c133ed         False   False        4h46m     Legacy
v1.17.17---vmware.1-tkg.1.d44d45a         v1.17.17+vmware.1-tkg.1.d44d45a         False   False        4h46m     Legacy
v1.17.7---vmware.1-tkg.1.154236c          v1.17.7+vmware.1-tkg.1.154236c          False   False        4h46m     Legacy
v1.17.8---vmware.1-tkg.1.5417466          v1.17.8+vmware.1-tkg.1.5417466          False   False        4h45m     Legacy
v1.18.10---vmware.1-tkg.1.3a6cd48         v1.18.10+vmware.1-tkg.1.3a6cd48         False   False        4h45m     Legacy
v1.18.15---vmware.1-tkg.1.600e412         v1.18.15+vmware.1-tkg.1.600e412         False   False        4h44m     Legacy
v1.18.15---vmware.1-tkg.2.ebf6117         v1.18.15+vmware.1-tkg.2.ebf6117         False   False        4h46m     Legacy
v1.18.19---vmware.1-tkg.1.17af790         v1.18.19+vmware.1-tkg.1.17af790         False   False        4h44m     Legacy
v1.18.5---vmware.1-tkg.1.c40d30d          v1.18.5+vmware.1-tkg.1.c40d30d          False   False        4h45m     Legacy
v1.19.11---vmware.1-tkg.1.9d9b236         v1.19.11+vmware.1-tkg.1.9d9b236         False   False        4h46m     Legacy
v1.19.14---vmware.1-tkg.1.8753786         v1.19.14+vmware.1-tkg.1.8753786         False   False        4h44m     Legacy
v1.19.16---vmware.1-tkg.1.df910e2         v1.19.16+vmware.1-tkg.1.df910e2         False   False        4h46m     Legacy
v1.19.7---vmware.1-tkg.1.fc82c41          v1.19.7+vmware.1-tkg.1.fc82c41          False   False        4h46m     Legacy
v1.19.7---vmware.1-tkg.2.f52f85a          v1.19.7+vmware.1-tkg.2.f52f85a          False   False        4h46m     Legacy
v1.20.12---vmware.1-tkg.1.b9a42f3         v1.20.12+vmware.1-tkg.1.b9a42f3         False   False        4h46m     Legacy
v1.20.2---vmware.1-tkg.1.1d4f79a          v1.20.2+vmware.1-tkg.1.1d4f79a          False   False        4h45m     Legacy
v1.20.2---vmware.1-tkg.2.3e10706          v1.20.2+vmware.1-tkg.2.3e10706          False   False        4h46m     Legacy
v1.20.7---vmware.1-tkg.1.7fb9067          v1.20.7+vmware.1-tkg.1.7fb9067          False   False        4h46m     Legacy
v1.20.8---vmware.1-tkg.2                  v1.20.8+vmware.1-tkg.2                  False   False        4h44m     Legacy
v1.20.9---vmware.1-tkg.1.a4cee5b          v1.20.9+vmware.1-tkg.1.a4cee5b          False   False        4h44m     Legacy
v1.21.2---vmware.1-tkg.1.ee25d55          v1.21.2+vmware.1-tkg.1.ee25d55          False   False        4h45m     Legacy
v1.21.6---vmware.1-tkg.1                  v1.21.6+vmware.1-tkg.1                  False   False        4h46m     Legacy
v1.21.6---vmware.1-tkg.1.b3d708a          v1.21.6+vmware.1-tkg.1.b3d708a          False   False        4h46m     Legacy
v1.22.9---vmware.1-tkg.1                  v1.22.9+vmware.1-tkg.1                  False   False        4h45m     Legacy
v1.22.9---vmware.1-tkg.1.cc71bc8          v1.22.9+vmware.1-tkg.1.cc71bc8          False   False        4h45m     Legacy
v1.23.15---vmware.1-tkg.4                 v1.23.15+vmware.1-tkg.4                 False   False        4h46m
v1.23.8---vmware.2-tkg.2-zshippable       v1.23.8+vmware.2-tkg.2-zshippable       False   False        4h46m
v1.23.8---vmware.3-tkg.1                  v1.23.8+vmware.3-tkg.1                  False   False        4h45m     Legacy
v1.23.8---vmware.3-tkg.1.ubuntu           v1.23.8+vmware.3-tkg.1.ubuntu           False   False        4h44m     Legacy
v1.24.11---vmware.1-fips.1-tkg.1          v1.24.11+vmware.1-fips.1-tkg.1          False   False        4h45m     Legacy
v1.24.11---vmware.1-fips.1-tkg.1.ubuntu   v1.24.11+vmware.1-fips.1-tkg.1.ubuntu   False   False        4h46m     Legacy
v1.24.9---vmware.1-tkg.4                  v1.24.9+vmware.1-tkg.4                  False   False        4h46m
v1.25.13---vmware.1-fips.1-tkg.1          v1.25.13+vmware.1-fips.1-tkg.1          True    True         4h45m     Legacy
v1.25.13---vmware.1-fips.1-tkg.1.ubuntu   v1.25.13+vmware.1-fips.1-tkg.1.ubuntu   True    True         4h44m     Legacy
v1.25.7---vmware.3-fips.1-tkg.1           v1.25.7+vmware.3-fips.1-tkg.1           True    True         4h45m
v1.26.10---vmware.1-fips.1-tkg.1          v1.26.10+vmware.1-fips.1-tkg.1          True    True         4h45m     Legacy
v1.26.10---vmware.1-fips.1-tkg.1.ubuntu   v1.26.10+vmware.1-fips.1-tkg.1.ubuntu   True    True         4h44m     Legacy
v1.26.12---vmware.2-fips.1-tkg.2          v1.26.12+vmware.2-fips.1-tkg.2          True    True         4h44m     Legacy
v1.26.12---vmware.2-fips.1-tkg.2.ubuntu   v1.26.12+vmware.2-fips.1-tkg.2.ubuntu   True    True         4h45m     Legacy
v1.26.13---vmware.1-fips.1-tkg.3          v1.26.13+vmware.1-fips.1-tkg.3          True    True         4h45m
v1.26.5---vmware.2-fips.1-tkg.1           v1.26.5+vmware.2-fips.1-tkg.1           True    True         4h45m
v1.27.10---vmware.1-fips.1-tkg.1          v1.27.10+vmware.1-fips.1-tkg.1          True    True         4h46m     Legacy
v1.27.10---vmware.1-fips.1-tkg.1.ubuntu   v1.27.10+vmware.1-fips.1-tkg.1.ubuntu   True    True         4h46m     Legacy
v1.27.11---vmware.1-fips.1-tkg.2          v1.27.11+vmware.1-fips.1-tkg.2          True    True         4h46m
v1.27.6---vmware.1-fips.1-tkg.1           v1.27.6+vmware.1-fips.1-tkg.1           True    True         4h45m     Legacy
v1.27.6---vmware.1-fips.1-tkg.1.ubuntu    v1.27.6+vmware.1-fips.1-tkg.1.ubuntu    True    True         4h45m     Legacy
v1.28.7---vmware.1-fips.1-tkg.1           v1.28.7+vmware.1-fips.1-tkg.1           True    True         4h45m     Legacy
v1.28.7---vmware.1-fips.1-tkg.1.ubuntu    v1.28.7+vmware.1-fips.1-tkg.1.ubuntu    True    True         4h44m     Legacy
v1.28.8---vmware.1-fips.1-tkg.2           v1.28.8+vmware.1-fips.1-tkg.2           True    True         4h46m
v1.29.4---vmware.3-fips.1-tkg.1           v1.29.4+vmware.3-fips.1-tkg.1           True    True         4h46m
v1.30.1---vmware.1-fips-tkg.5             v1.30.1+vmware.1-fips-tkg.5             True    True         4h45m
v1.30.8---vmware.1-fips-vkr.1             v1.30.8+vmware.1-fips-vkr.1             False   False        4h46m
v1.31.1---vmware.2-fips-vkr.2             v1.31.1+vmware.2-fips-vkr.2             False   False        4h45m
v1.31.4---vmware.1-fips-vkr.3             v1.31.4+vmware.1-fips-vkr.3             False   False        4h46m
v1.32.0---vmware.6-fips-vkr.2             v1.32.0+vmware.6-fips-vkr.2             False   False        4h46m
```

10. READY COMPATIBLE 가 true 인 버전을 확인 후 tkgcluster.yaml 파일 생성

```yaml
apiVersion: run.tanzu.vmware.com/v1alpha3
kind: TanzuKubernetesCluster
metadata:
  name: tkg-cluster-sjh
  namespace: tkg-ns-sjh
spec:
  topology:
    controlPlane:
      count: 1
      class: best-effort-small
      storageClass: k8s-storage
      tkr:
        reference:
          name: v1.29.4---vmware.3-fips.1-tkg.1
    workers:
      count: 2
      class: best-effort-small
      storageClass: k8s-storage
      tkr:
        reference:
          name: v1.29.4---vmware.3-fips.1-tkg.1
  settings:
    network:
      cni:
        name: antrea
      pods:
        cidrBlocks: ['172.168.0.0/16']
      services:
        cidrBlocks: ['10.96.0.0/12']
      serviceDomain: cluster.local
    storage:
      defaultClass: k8s-storage
```

11. tkg cluster 적용

```bash
kubectl apply -f tkg-cluster.yaml -n tkg-ns-sjh
```

12. 클러스터 정상 작동 확인 (vCenter UI)
13. 정상 적으로 완료가 되면 tanzucluster name 과 namespace를 통해 cluster namespace(context) 가지고 오기

```bash
kubectl vsphere login --server=192.168.30.210 --tanzu-kubernetes-cluster-name tkg-cluster-sjh2  --tanzu-kubernetes-cluster-namespace tkg-ns-sjh2 --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
```

14. 해당 namespace로 전환 tkg-cluster-sjh

```bash
kubectl config use-context tkg-cluster-sjh
kubectl config  get-contexts
CURRENT   NAME                         CLUSTER          AUTHINFO                                         NAMESPACE
          192.168.0.152                192.168.0.152    wcp:192.168.0.152:administrator@vsphere.local
          192.168.0.153                192.168.0.153    wcp:192.168.0.153:administrator@vsphere.local
          192.168.30.210               192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local
          svc-cci-service-domain-c55   192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local   svc-cci-service-domain-c55
          svc-tkg-domain-c55           192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local   svc-tkg-domain-c55
          svc-velero-domain-c55        192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local   svc-velero-domain-c55
*          tkg-cluster-sjh              192.168.30.211   wcp:192.168.30.211:administrator@vsphere.local
          tkg-ns-sjh                   192.168.30.210   wcp:192.168.30.210:administrator@vsphere.local   tkg-ns-sjh

You have access to the following contexts:
   192.168.30.210
   svc-tkg-domain-c55
   svc-velero-domain-c55
   tkg-cluster-sjh2
   tkg-ns-lcs
   tkg-ns-sjh2
```

15. tkg cluster 삭제

```bash
kubectl delete tanzukubernetesclusters.run.tanzu.vmware.com tkg-cluster-sjh -n tkg-ns-sjh
```

16.
17.

```bash
#!/bin/bash
VSPHERE_WITH_TANZU_CONTROL_PLANE_IP=10.10.152.1
VSPHERE_WITH_TANZU_USERNAME=administrator@vsphere.local
VSPHERE_WITH_TANZU_PASSWORD=VMware1!
VSPHERE_WITH_TANZU_NAMESPACE=tkg-ns-sjh
KUBECTL_PATH=/usr/bin/kubectl

KUBECTL_VSPHERE_LOGIN_COMMAND=$(expect -c " spawn $KUBECTL_PATH vsphere login --server=$VSPHERE_WITH_TANZU_CONTROL_PLANE_IP --vsphere-username $VSPHERE_WITH_TANZU_USERNAME --insecure-skip-tls-verify

expect \"*?assword:*\"
send -- \"$VSPHERE_WITH_TANZU_PASSWORD\r\" expect eof ")

${KUBECTL_PATH} config use-context ${VSPHERE_WITH_TANZU_NAMESPACE}




#!/bin/bash
VSPHERE_WITH_TANZU_CONTROL_PLANE_IP=10.10.152.1
VSPHERE_WITH_TANZU_USERNAME=administrator@vsphere.local
VSPHERE_WITH_TANZU_PASSWORD=VMware1!
VSPHERE_WITH_TANZU_NAMESPACE=tkg-ns-sjh
VSPHERE_WITH_TANZU_TKC_NAME=tkg-cluster-sjh
KUBECTL_PATH=/usr/local/bin/kubectl

KUBECTL_VSPHERE_LOGIN_COMMAND=$(expect -c " spawn $KUBECTL_PATH vsphere login --server=$VSPHERE_WITH_TANZU_CONTROL_PLANE_IP --vsphere-username $VSPHERE_WITH_TANZU_USERNAME --insecure-skip-tls-verify --tanzukubernetes-cluster-namespace $VSPHERE_WITH_TANZU_NAMESPACE --tanzu-kubernetescluster-name $VSPHERE_WITH_TANZU_TKC_NAME expect \"*?assword:*\" send -- \"$VSPHERE_WITH_TANZU_PASSWORD\r\" expect eof ")
```

#

```bash
[root@localhost bin]# kubectl api-versions -n tkg-ns-sjh
acme.cert-manager.io/v1
addons.cluster.x-k8s.io/v1beta1
admissionregistration.k8s.io/v1
apiextensions.k8s.io/v1
apiregistration.k8s.io/v1
appplatform.vmware.com/v1alpha1
appplatform.wcp.vmware.com/v1alpha1
appplatform.wcp.vmware.com/v1alpha2
appplatform.wcp.vmware.com/v1beta1
apps/v1
authentication.concierge.pinniped.dev/v1alpha1
authentication.k8s.io/v1
authorization.k8s.io/v1
autoscaling/v1
autoscaling/v2
batch/v1
bootstrap.cluster.x-k8s.io/v1beta1
cert-manager.io/v1
certificates.k8s.io/v1
cli.tanzu.vmware.com/v1alpha1
clientsecret.supervisor.pinniped.dev/v1alpha1
cluster.x-k8s.io/v1beta1
cni.tanzu.vmware.com/v1alpha1
cns.vmware.com/v1alpha1
config.concierge.pinniped.dev/v1alpha1
config.supervisor.pinniped.dev/v1alpha1
config.tanzu.vmware.com/v1alpha1
controlplane.cluster.x-k8s.io/v1beta1
coordination.k8s.io/v1
core.tanzu.vmware.com/v1alpha2
cpi.tanzu.vmware.com/v1alpha1
crd.projectcalico.org/v1
csi.tanzu.vmware.com/v1alpha1
data.packaging.carvel.dev/v1alpha1
discovery.k8s.io/v1
events.k8s.io/v1
flowcontrol.apiserver.k8s.io/v1
flowcontrol.apiserver.k8s.io/v1beta3
identity.concierge.pinniped.dev/v1alpha1
idp.supervisor.pinniped.dev/v1alpha1
imagecontroller.vmware.com/v1
imageregistry.vmware.com/v1alpha1
infrastructure.cluster.vmware.com/v1beta1
installers.tmc.cloud.vmware.com/v1alpha1
internal.packaging.carvel.dev/v1alpha1
ipam.cluster.x-k8s.io/v1alpha1
ipam.cluster.x-k8s.io/v1beta1
kappctrl.k14s.io/v1alpha1
licenseoperator.vmware.com/v1alpha1
login.concierge.pinniped.dev/v1alpha1
netoperator.vmware.com/v1alpha1
networking.k8s.io/v1
networking.x-k8s.io/v1alpha1pre1
node.k8s.io/v1
packaging.carvel.dev/v1alpha1
policy/v1
psp.wcp.vmware.com/v1beta1
rbac.authorization.k8s.io/v1
run.tanzu.vmware.com/v1alpha1
run.tanzu.vmware.com/v1alpha2
run.tanzu.vmware.com/v1alpha3
runtime.cluster.x-k8s.io/v1alpha1
scheduling.k8s.io/v1
secretgen.carvel.dev/v1alpha1
secretgen.k14s.io/v1alpha1
snapshot.storage.k8s.io/v1
storage.k8s.io/v1
topology.tanzu.vmware.com/v1alpha1
v1
veleroappoperator.vmware.com/v1alpha1
vmoperator.vmware.com/v1alpha1
vmoperator.vmware.com/v1alpha2
vmware.infrastructure.cluster.x-k8s.io/v1beta1
```

```bash
[root@localhost bin]# kubectl get osimages
NAME                    K8S VERSION                OS NAME   OS VERSION   ARCH    TYPE   COMPATIBLE   CREATED
vmi-0068fddbde9be1a0b   v1.16.12+vmware.1          photon    3.0          amd64   vmi                 4h57m
vmi-0a656e180c1ef59e5   v1.31.4+vmware.1-fips      ubuntu    22.04        amd64   vmi                 5h
vmi-14909d234ea701280   v1.23.15+vmware.1          photon    3            amd64   vmi                 4h59m
vmi-154fc2080b709bde7   v1.24.11+vmware.1-fips.1   ubuntu    20.04        amd64   vmi                 4h59m
vmi-18fec0c40ef82f967   v1.17.7+vmware.1           photon    3.0          amd64   vmi                 4h59m
vmi-1c67adfe993c0eb12   v1.26.13+vmware.1-fips.1   photon    3            amd64   vmi                 4h56m
vmi-219a50a7a4f3192f9   v1.22.9+vmware.1           photon    3.0          amd64   vmi                 4h59m
vmi-2399a3b4bd8af10e4   v1.21.6+vmware.1           ubuntu    20.04        amd64   vmi                 4h57m
vmi-2448f5c87634ba331   v1.17.17+vmware.1          photon    3.0          amd64   vmi                 4h59m
vmi-31a5dc43df65980fe   v1.27.11+vmware.1-fips.1   photon    3            amd64   vmi                 4h55m
vmi-33492be09dac2fa1f   v1.23.15+vmware.1          ubuntu    20.04        amd64   vmi                 5h
vmi-3504f335d26aaade5   v1.27.6+vmware.1-fips.1    photon    3.0          amd64   vmi                 4h57m
vmi-354251f92350d70f4   v1.26.13+vmware.1-fips.1   ubuntu    20.04        amd64   vmi                 4h58m
vmi-36de57ca6d8ea139a   v1.24.11+vmware.1-fips.1   photon    3.0          amd64   vmi                 4h57m
vmi-375452555ac4ed1be   v1.19.14+vmware.1          photon    3.0          amd64   vmi                 4h55m
vmi-3f2b23fa4e453a8f6   v1.16.14+vmware.1          photon    3.0          amd64   vmi                 4h56m
vmi-41f97daf6237c3c36   v1.28.7+vmware.1-fips.1    photon    5.0          amd64   vmi                 4h57m
vmi-451d9a8a9259be645   v1.30.1+vmware.1-fips      ubuntu    22.04        amd64   vmi                 4h56m
vmi-4d21feeecf46865f7   v1.25.7+vmware.3-fips.1    ubuntu    20.04        amd64   vmi                 4h58m
vmi-4f22ea35e045d6966   v1.29.4+vmware.3-fips.1    ubuntu    22.04        amd64   vmi                 4h59m
vmi-5028ff65b2eced01f   v1.23.8+vmware.2           photon    3            amd64   vmi                 4h58m
vmi-52be0eda5b6c24ce4   v1.20.2+vmware.1           photon    3.0          amd64   vmi                 4h56m
vmi-5515e185ee5570287   v1.25.7+vmware.3-fips.1    photon    3            amd64   vmi                 4h59m
vmi-5679e10fdf4f3825b   v1.21.6+vmware.1           photon    3.0          amd64   vmi                 5h
vmi-56bad181a7fe38ff5   v1.27.11+vmware.1-fips.1   ubuntu    22.04        amd64   vmi                 4h57m
vmi-5f7b1f9611c97da93   v1.31.4+vmware.1-fips      photon    5            amd64   vmi                 4h58m
vmi-600761c36d48b6920   v1.30.8+vmware.1-fips      photon    5            amd64   vmi                 4h59m
vmi-624112cd4e1454ae2   v1.20.9+vmware.1           photon    3.0          amd64   vmi                 4h56m
vmi-679005004a3904734   v1.24.9+vmware.1           photon    3            amd64   vmi                 4h58m
vmi-6c215d4c392fa8a1f   v1.28.7+vmware.1-fips.1    ubuntu    22.04        amd64   vmi                 4h58m
vmi-70aa531858949de9d   v1.19.11+vmware.1          photon    3.0          amd64   vmi                 4h57m
vmi-751d948a79443d552   v1.16.8+vmware.1           photon    3.0          amd64   vmi                 4h56m
vmi-7bb2a7834a0ce8983   v1.19.7+vmware.1           photon    3.0          amd64   vmi                 5h
vmi-7c5bffa00a2052142   v1.20.12+vmware.1          photon    3.0          amd64   vmi                 4h57m
vmi-7d0d6466f7bcbd9cf   v1.26.10+vmware.1-fips.1   ubuntu    20.04        amd64   vmi                 4h55m
vmi-7fe7e6b455b6db624   v1.18.15+vmware.1          photon    3.0          amd64   vmi                 4h57m
vmi-80c6aea2ebc56269f   v1.32.0+vmware.6-fips      ubuntu    22.04        amd64   vmi                 4h58m
vmi-8d5132313a9e357f2   v1.18.15+vmware.1          photon    3.0          amd64   vmi                 4h58m
vmi-8e78866cbc2d446fb   v1.21.2+vmware.1           photon    3.0          amd64   vmi                 4h56m
vmi-92ce4b6cb3a2347ac   v1.28.8+vmware.1-fips.1    ubuntu    22.04        amd64   vmi                 4h58m
vmi-95ab065482fdbec8e   v1.20.7+vmware.1           photon    3.0          amd64   vmi                 4h59m
vmi-95ad1d2f21f1316b4   v1.17.13+vmware.1          photon    3.0          amd64   vmi                 4h59m
vmi-9a40cdcb8f684744b   v1.19.7+vmware.1           photon    3.0          amd64   vmi                 4h59m
vmi-9b1f141fb6193f554   v1.23.8+vmware.2           ubuntu    20.04        amd64   vmi                 4h55m
vmi-9e59ef77461ad0e27   v1.26.12+vmware.2-fips.1   ubuntu    20.04        amd64   vmi                 4h58m
vmi-a20d4e2182ec5bcba   v1.20.8+vmware.1           ubuntu    20.04        amd64   vmi                 4h55m
vmi-a3c1f328df98b539d   v1.17.11+vmware.1          photon    3.0          amd64   vmi                 4h56m
vmi-a721775492f4ea40c   v1.23.8+vmware.3           ubuntu    20.04        amd64   vmi                 4h55m
vmi-a84134ba2712a8f8d   v1.30.8+vmware.1-fips      ubuntu    22.04        amd64   vmi                 4h59m
vmi-a9513335d8f64dbcc   v1.23.8+vmware.3           photon    3.0          amd64   vmi                 4h58m
vmi-aa2c5830692060f27   v1.32.0+vmware.6-fips      photon    5            amd64   vmi                 4h57m
vmi-b251d5b0f008949a3   v1.17.8+vmware.1           photon    3.0          amd64   vmi                 4h58m
vmi-b2591eb41f0a336f5   v1.27.6+vmware.1-fips.1    ubuntu    20.04        amd64   vmi                 4h55m
vmi-b4705d6cc4a623ab1   v1.26.12+vmware.2-fips.1   photon    3.0          amd64   vmi                 4h54m
vmi-b7422d0679589cd8f   v1.27.10+vmware.1-fips.1   ubuntu    20.04        amd64   vmi                 4h55m
vmi-b94f097073e107170   v1.17.11+vmware.1          photon    3.0          amd64   vmi                 4h56m
vmi-b9af278921b0f1914   v1.18.5+vmware.1           photon    3.0          amd64   vmi                 4h59m
vmi-bab1d94d961522c42   v1.26.5+vmware.2-fips.1    photon    3            amd64   vmi                 4h58m
vmi-bb9953dcbb8ed0bfb   v1.18.10+vmware.1          photon    3.0          amd64   vmi                 4h56m
vmi-bf8652f9e68f2e9dc   v1.22.9+vmware.1           ubuntu    20.04        amd64   vmi                 4h58m
vmi-bfc7c0d92b93419ce   v1.31.1+vmware.2-fips      ubuntu    22.04        amd64   vmi                 4h58m
vmi-c4df7bf56062a4145   v1.30.1+vmware.1-fips      photon    5            amd64   vmi                 4h56m
vmi-c789a7ecfb6082b3d   v1.27.10+vmware.1-fips.1   photon    3.0          amd64   vmi                 4h57m
vmi-c9c7638fa757d4cc7   v1.28.8+vmware.1-fips.1    photon    5            amd64   vmi                 4h57m
vmi-d28a3a8ce97a755ff   v1.20.2+vmware.1           photon    3.0          amd64   vmi                 4h59m
vmi-dcce34f71132af3d9   v1.31.1+vmware.2-fips      photon    5            amd64   vmi                 4h56m
vmi-e37f584b88278166c   v1.25.13+vmware.1-fips.1   photon    3.0          amd64   vmi                 4h59m
vmi-e5dfb9342db691802   v1.18.19+vmware.1          photon    3.0          amd64   vmi                 4h55m
vmi-eb5f6d891ae25d645   v1.19.16+vmware.1          photon    3.0          amd64   vmi                 4h57m
vmi-ef0f56c137a4146db   v1.29.4+vmware.3-fips.1    photon    5            amd64   vmi                 4h55m
vmi-f5a847c6c1ef8681c   v1.25.13+vmware.1-fips.1   ubuntu    20.04        amd64   vmi                 4h55m
vmi-f6edfa8b8ddcba28a   v1.26.10+vmware.1-fips.1   photon    3.0          amd64   vmi                 4h55m
vmi-f90db18d3c11fc89c   v1.24.9+vmware.1           ubuntu    20.04        amd64   vmi                 5h
vmi-fa8263f81c9b0161b   v1.26.5+vmware.2-fips.1    ubuntu    20.04        amd64   vmi                 4h57m



[root@localhost bin]# kubectl get tkr -A -o wide
NAME                                      VERSION                                 READY   COMPATIBLE   CREATED   TYPE
v1.16.12---vmware.1-tkg.1.da7afe7         v1.16.12+vmware.1-tkg.1.da7afe7         False   False        4h59m     Legacy
v1.16.14---vmware.1-tkg.1.ada4837         v1.16.14+vmware.1-tkg.1.ada4837         False   False        4h58m     Legacy
v1.16.8---vmware.1-tkg.3.60d2ffd          v1.16.8+vmware.1-tkg.3.60d2ffd          False   False        4h58m     Legacy
v1.17.11---vmware.1-tkg.1.15f1e18         v1.17.11+vmware.1-tkg.1.15f1e18         False   False        4h58m     Legacy
v1.17.11---vmware.1-tkg.2.ad3d374         v1.17.11+vmware.1-tkg.2.ad3d374         False   False        4h57m     Legacy
v1.17.13---vmware.1-tkg.2.2c133ed         v1.17.13+vmware.1-tkg.2.2c133ed         False   False        4h59m     Legacy
v1.17.17---vmware.1-tkg.1.d44d45a         v1.17.17+vmware.1-tkg.1.d44d45a         False   False        4h59m     Legacy
v1.17.7---vmware.1-tkg.1.154236c          v1.17.7+vmware.1-tkg.1.154236c          False   False        4h59m     Legacy
v1.17.8---vmware.1-tkg.1.5417466          v1.17.8+vmware.1-tkg.1.5417466          False   False        4h58m     Legacy
v1.18.10---vmware.1-tkg.1.3a6cd48         v1.18.10+vmware.1-tkg.1.3a6cd48         False   False        4h58m     Legacy
v1.18.15---vmware.1-tkg.1.600e412         v1.18.15+vmware.1-tkg.1.600e412         False   False        4h58m     Legacy
v1.18.15---vmware.1-tkg.2.ebf6117         v1.18.15+vmware.1-tkg.2.ebf6117         False   False        4h59m     Legacy
v1.18.19---vmware.1-tkg.1.17af790         v1.18.19+vmware.1-tkg.1.17af790         False   False        4h57m     Legacy
v1.18.5---vmware.1-tkg.1.c40d30d          v1.18.5+vmware.1-tkg.1.c40d30d          False   False        4h58m     Legacy
v1.19.11---vmware.1-tkg.1.9d9b236         v1.19.11+vmware.1-tkg.1.9d9b236         False   False        5h        Legacy
v1.19.14---vmware.1-tkg.1.8753786         v1.19.14+vmware.1-tkg.1.8753786         False   False        4h57m     Legacy
v1.19.16---vmware.1-tkg.1.df910e2         v1.19.16+vmware.1-tkg.1.df910e2         False   False        4h59m     Legacy
v1.19.7---vmware.1-tkg.1.fc82c41          v1.19.7+vmware.1-tkg.1.fc82c41          False   False        5h        Legacy
v1.19.7---vmware.1-tkg.2.f52f85a          v1.19.7+vmware.1-tkg.2.f52f85a          False   False        4h59m     Legacy
v1.20.12---vmware.1-tkg.1.b9a42f3         v1.20.12+vmware.1-tkg.1.b9a42f3         False   False        4h59m     Legacy
v1.20.2---vmware.1-tkg.1.1d4f79a          v1.20.2+vmware.1-tkg.1.1d4f79a          False   False        4h58m     Legacy
v1.20.2---vmware.1-tkg.2.3e10706          v1.20.2+vmware.1-tkg.2.3e10706          False   False        4h59m     Legacy
v1.20.7---vmware.1-tkg.1.7fb9067          v1.20.7+vmware.1-tkg.1.7fb9067          False   False        4h59m     Legacy
v1.20.8---vmware.1-tkg.2                  v1.20.8+vmware.1-tkg.2                  False   False        4h57m     Legacy
v1.20.9---vmware.1-tkg.1.a4cee5b          v1.20.9+vmware.1-tkg.1.a4cee5b          False   False        4h57m     Legacy
v1.21.2---vmware.1-tkg.1.ee25d55          v1.21.2+vmware.1-tkg.1.ee25d55          False   False        4h58m     Legacy
v1.21.6---vmware.1-tkg.1                  v1.21.6+vmware.1-tkg.1                  False   False        4h59m     Legacy
v1.21.6---vmware.1-tkg.1.b3d708a          v1.21.6+vmware.1-tkg.1.b3d708a          False   False        5h        Legacy
v1.22.9---vmware.1-tkg.1                  v1.22.9+vmware.1-tkg.1                  False   False        4h58m     Legacy
v1.22.9---vmware.1-tkg.1.cc71bc8          v1.22.9+vmware.1-tkg.1.cc71bc8          False   False        4h59m     Legacy
v1.23.15---vmware.1-tkg.4                 v1.23.15+vmware.1-tkg.4                 False   False        4h59m
v1.23.8---vmware.2-tkg.2-zshippable       v1.23.8+vmware.2-tkg.2-zshippable       False   False        5h
v1.23.8---vmware.3-tkg.1                  v1.23.8+vmware.3-tkg.1                  False   False        4h58m     Legacy
v1.23.8---vmware.3-tkg.1.ubuntu           v1.23.8+vmware.3-tkg.1.ubuntu           False   False        4h57m     Legacy
v1.24.11---vmware.1-fips.1-tkg.1          v1.24.11+vmware.1-fips.1-tkg.1          False   False        4h58m     Legacy
v1.24.11---vmware.1-fips.1-tkg.1.ubuntu   v1.24.11+vmware.1-fips.1-tkg.1.ubuntu   False   False        4h59m     Legacy
v1.24.9---vmware.1-tkg.4                  v1.24.9+vmware.1-tkg.4                  False   False        4h59m
v1.25.13---vmware.1-fips.1-tkg.1          v1.25.13+vmware.1-fips.1-tkg.1          True    True         4h59m     Legacy
v1.25.13---vmware.1-fips.1-tkg.1.ubuntu   v1.25.13+vmware.1-fips.1-tkg.1.ubuntu   True    True         4h58m     Legacy
v1.25.7---vmware.3-fips.1-tkg.1           v1.25.7+vmware.3-fips.1-tkg.1           True    True         4h58m
v1.26.10---vmware.1-fips.1-tkg.1          v1.26.10+vmware.1-fips.1-tkg.1          True    True         4h59m     Legacy
v1.26.10---vmware.1-fips.1-tkg.1.ubuntu   v1.26.10+vmware.1-fips.1-tkg.1.ubuntu   True    True         4h57m     Legacy
v1.26.12---vmware.2-fips.1-tkg.2          v1.26.12+vmware.2-fips.1-tkg.2          True    True         4h58m     Legacy
v1.26.12---vmware.2-fips.1-tkg.2.ubuntu   v1.26.12+vmware.2-fips.1-tkg.2.ubuntu   True    True         4h58m     Legacy
v1.26.13---vmware.1-fips.1-tkg.3          v1.26.13+vmware.1-fips.1-tkg.3          True    True         4h58m
v1.26.5---vmware.2-fips.1-tkg.1           v1.26.5+vmware.2-fips.1-tkg.1           True    True         4h58m
v1.27.10---vmware.1-fips.1-tkg.1          v1.27.10+vmware.1-fips.1-tkg.1          True    True         4h59m     Legacy
v1.27.10---vmware.1-fips.1-tkg.1.ubuntu   v1.27.10+vmware.1-fips.1-tkg.1.ubuntu   True    True         5h        Legacy
v1.27.11---vmware.1-fips.1-tkg.2          v1.27.11+vmware.1-fips.1-tkg.2          True    True         4h59m
v1.27.6---vmware.1-fips.1-tkg.1           v1.27.6+vmware.1-fips.1-tkg.1           True    True         4h59m     Legacy
v1.27.6---vmware.1-fips.1-tkg.1.ubuntu    v1.27.6+vmware.1-fips.1-tkg.1.ubuntu    True    True         4h58m     Legacy
v1.28.7---vmware.1-fips.1-tkg.1           v1.28.7+vmware.1-fips.1-tkg.1           True    True         4h59m     Legacy
v1.28.7---vmware.1-fips.1-tkg.1.ubuntu    v1.28.7+vmware.1-fips.1-tkg.1.ubuntu    True    True         4h57m     Legacy
v1.28.8---vmware.1-fips.1-tkg.2           v1.28.8+vmware.1-fips.1-tkg.2           True    True         4h59m
v1.29.4---vmware.3-fips.1-tkg.1           v1.29.4+vmware.3-fips.1-tkg.1           True    True         5h
v1.30.1---vmware.1-fips-tkg.5             v1.30.1+vmware.1-fips-tkg.5             True    True         4h58m
v1.30.8---vmware.1-fips-vkr.1             v1.30.8+vmware.1-fips-vkr.1             False   False        4h59m
v1.31.1---vmware.2-fips-vkr.2             v1.31.1+vmware.2-fips-vkr.2             False   False        4h58m
v1.31.4---vmware.1-fips-vkr.3             v1.31.4+vmware.1-fips-vkr.3             False   False        4h59m
v1.32.0---vmware.6-fips-vkr.2             v1.32.0+vmware.6-fips-vkr.2             False   False        4h59m
```

```bash
helm install apache-web bitnami/apache \
  --namespace apache-web \
  --create-namespace \
  --set replicaCount=1 \
  --set service.type=LoadBalancer \
  --set service.port=80 \
  --set persistence.enabled=true \
  --set persistence.size=5Gi \
  --set persistence.storageClass=tanzupolicy

```

```bash
helm pull ceph-csi/ceph-csi-rbd \
    --version 3.13.1

helm upgrade ceph-csi-rbd ceph-csi/ceph-csi-rbd \
    --version 3.13.1 \
    --install \
    --namespace ceph-csi-rbd \
    --create-namespace \
    --set csiConfig[0].clusterID="c0a5c077-7fab-4586-9fda-577c6d70eb40" \
    --set csiConfig[0].monitors[0]="192.168.0.12:6789" \
    --set csiConfig[0].monitors[1]="192.168.0.13:6789" \
    --set csiConfig[0].monitors[2]="192.168.0.14:6789" \
    --set nodeplugin.httpMetrics.enabled=false \
    --set-string nodeplugin.containerSecurityContext.allowPrivilegeEscalation="false" \
        --set serviceAccounts.nodeplugin.name=ceph-csi-nodeplugin \
    --set-string nodeplugin.podSecurityContext.seccompProfile.type="RuntimeDefault" \
    --set nodeplugin.containerSecurityContext.runAsNonRoot=true \
    --set-string nodeplugin.containerSecurityContext.allowPrivilegeEscalation="false" \
    --set nodeplugin.containerSecurityContext.capabilities.drop[0]="ALL" \
    --set provisioner.replicaCount=1 \
    --set provisioner.httpMetrics.enabled=false \
    --set serviceAccounts.provisioner.name=ceph-csi-provisioner \
    --set-string provisioner.podSecurityContext.seccompProfile.type="RuntimeDefault" \
    --set provisioner.containerSecurityContext.runAsNonRoot=true \
    --set-string provisioner.containerSecurityContext.allowPrivilegeEscalation="false" \
    --set provisioner.containerSecurityContext.capabilities.drop[0]="ALL" \
    --set storageClass.create=true \
    --set storageClass.name="csi-rbd-sc" \
    --set storageClass.clusterID="c0a5c077-7fab-4586-9fda-577c6d70eb40" \
    --set storageClass.pool="kubernetes" \
    --set storageClass.reclaimPolicy="Delete" \
    --set secret.create=true \
    --set secret.name="csi-rbd-secret" \
    --set secret.userID="kubernetes" \
    --set secret.userKey="AQAeVvdnN9iDHxAAIYLNgjEn4vw7dPLF6rRCPQ=="

kubectl get storageclasses.storage.k8s.io

watch kubectl get all -n ceph-csi-rbd

helm get values ceph-csi-rbd -n ceph-csi-rbd

```

```bash
helm upgrade ceph-csi-rbd ceph-csi/ceph-csi-rbd \
  --version 3.13.1 \
  --install \
  --namespace ceph-csi-rbd \
  --create-namespace \
  --set csiConfig[0].clusterID="c0a5c077-7fab-4586-9fda-577c6d70eb40" \
  --set csiConfig[0].monitors[0]="192.168.0.12:6789" \
  --set csiConfig[0].monitors[1]="192.168.0.13:6789" \
  --set csiConfig[0].monitors[2]="192.168.0.14:6789" \
  --set nodeplugin.httpMetrics.enabled=false \
  --set serviceAccounts.nodeplugin.name=ceph-csi-nodeplugin \
  --set serviceAccounts.provisioner.name=ceph-csi-provisioner \
  --set nodeplugin.containerSecurityContext.allowPrivilegeEscalation=false \
  --set nodeplugin.containerSecurityContext.capabilities.drop[0]="ALL" \
  --set nodeplugin.containerSecurityContext.runAsNonRoot=true \
  --set nodeplugin.containerSecurityContext.runAsUser=1001 \
  --set-string nodeplugin.podSecurityContext.seccompProfile.type="RuntimeDefault" \
  --set nodeplugin.podSecurityContext.runAsNonRoot=true \
  --set nodeplugin.podSecurityContext.runAsUser=1001 \
  --set provisioner.containerSecurityContext.allowPrivilegeEscalation=false \
  --set provisioner.containerSecurityContext.capabilities.drop[0]="ALL" \
  --set provisioner.containerSecurityContext.runAsNonRoot=true \
  --set provisioner.containerSecurityContext.runAsUser=1001 \
  --set-string provisioner.podSecurityContext.seccompProfile.type="RuntimeDefault" \
  --set provisioner.podSecurityContext.runAsNonRoot=true \
  --set provisioner.podSecurityContext.runAsUser=1001 \
  --set provisioner.replicaCount=1 \
  --set provisioner.httpMetrics.enabled=false \
  --set storageClass.create=true \
  --set storageClass.name="csi-rbd-sc" \
  --set storageClass.clusterID="c0a5c077-7fab-4586-9fda-577c6d70eb40" \
  --set storageClass.pool="kubernetes" \
  --set storageClass.reclaimPolicy="Delete" \
  --set secret.create=true \
  --set secret.name="csi-rbd-secret" \
  --set secret.userID="kubernetes" \
  --set secret.userKey="AQAeVvdnN9iDHxAAIYLNgjEn4vw7dPLF6rRCPQ=="
```
