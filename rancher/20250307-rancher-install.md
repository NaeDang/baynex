# 2024-06-01
 
# https://github.com/rancher/rke2
# https://docs.rke2.io/install/methods
# https://github.com/helm/helm/releases
 
NAME      STATUS   ROLES                       AGE     VERSION          INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
master1   Ready    control-plane,etcd,master   26m     v1.28.10+rke2r1   192.168.0.40   <none>        Ubuntu 22.04.4 LTS   5.15.0-105-generic   containerd://1.7.11-k3s2
worker1   Ready    <none>                      25m     v1.28.10+rke2r1   192.168.0.41   <none>        Ubuntu 22.04.4 LTS   5.15.0-105-generic   containerd://1.7.11-k3s2
worker2   Ready    <none>                      6m48s   v1.28.10+rke2r1   192.168.0.42   <none>        Ubuntu 22.04.4 LTS   5.15.0-105-generic   containerd://1.7.11-k3s2
 
worker1 - GPU X
worker2 - GPU O
 
# ssh root@192.168.0.9
---
export TEMPLATE_ID=9003
export VM_ID=140
export VM_NAME=rke2-master1
export VM_NIC=vmbr0
export VM_IP=192.168.0.40/24
export VM_GW=192.168.0.1
export STORAGE=local-lvm
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full true
qm set $VM_ID --machine q35,viommu=intel
qm set $VM_ID --bios ovmf --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=0
qm set $VM_ID --memory 32768 --cores 16
qm set $VM_ID --net0 virtio,bridge=$VM_NIC,firewall=1
qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW
qm set $VM_ID --ciupgrade 0
qm resize $VM_ID scsi0 +100G
qm snapshot $VM_ID Pre
qm start $VM_ID
---
---
export TEMPLATE_ID=9003
export VM_ID=141
export VM_NAME=rke2-worker1
export VM_NIC=vmbr0
export VM_IP=192.168.0.41/24
export VM_GW=192.168.0.1
export STORAGE=local-lvm
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full true
qm set $VM_ID --machine q35,viommu=intel
qm set $VM_ID --bios ovmf --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=0
qm set $VM_ID --memory 32768 --cores 16
qm set $VM_ID --net0 virtio,bridge=$VM_NIC,firewall=1
qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW
qm set $VM_ID --ciupgrade 0
qm resize $VM_ID scsi0 +100G
qm snapshot $VM_ID Pre
qm start $VM_ID
---
---
export TEMPLATE_ID=9003
export VM_ID=142
export VM_NAME=rke2-worker2
export VM_NIC=vmbr0
export VM_IP=192.168.0.42/24
export VM_GW=192.168.0.1
export STORAGE=local-lvm
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full true
qm set $VM_ID --machine q35,viommu=intel
qm set $VM_ID --bios ovmf --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=0
qm set $VM_ID --memory 32768 --cores 16
qm set $VM_ID --net0 virtio,bridge=$VM_NIC,firewall=1
qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW
qm set $VM_ID --hostpci0 0000:23:00
qm set $VM_ID --ciupgrade 0
qm resize $VM_ID scsi0 +100G
qm snapshot $VM_ID Pre
qm start $VM_ID
---
 
# ssh ubuntu@192.168.0.40
---
curl -sfL https://get.rke2.io --output install.sh
chmod +x install.sh
 
sudo INSTALL_RKE2_CHANNEL=v1.28.10+rke2r1 ./install.sh
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service
journalctl -u rke2-server -f
 
mkdir .kube
sudo cp /etc/rancher/rke2/rke2.yaml .kube/config
sudo chown $USER. .kube/config
sudo cp /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/
 
sudo cat /var/lib/rancher/rke2/server/node-token
# K10a6247b71e756d7dae41b47c2ca7051b93500ea0b6bd00231459a7937909e4709::server:007b5f52d422f8c6aeb7033bc5025588
---
 
# ssh ubuntu@192.168.0.41~42
---
curl -sfL https://get.rke2.io --output install.sh
chmod +x install.sh
 
sudo INSTALL_RKE2_CHANNEL=v1.28.10+rke2r1 ./install.sh
sudo systemctl enable rke2-agent.service
 
sudo mkdir -p /etc/rancher/rke2/
sudo tee -a /etc/rancher/rke2/config.yaml <<EOF
server: https://192.168.0.40:9345
token: K10a6247b71e756d7dae41b47c2ca7051b93500ea0b6bd00231459a7937909e4709::server:007b5f52d422f8c6aeb7033bc5025588
EOF
 
sudo systemctl start rke2-agent.service
journalctl -u rke2-agent -f
---
 
---
[Enable Auto-completion for Kubectl in a Linux Bash Shell]
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#optional-kubectl-configurations-and-plugins
 
type _init_completion
# Ubuntu
sudo apt-get install -y bash-completion
# Centos
sudo yum install -y bash-completion
 
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
 
echo 'export KUBE_EDITOR=nano' >>~/.bashrc
 
source ~/.bashrc
---
 
---
[Install Helm]
export FILE_NAME=helm-v3.15.1-linux-amd64.tar.gz
wget https://get.helm.sh/$FILE_NAME && \
tar -zxvf $FILE_NAME && \
sudo mv linux-amd64/helm /usr/local/bin/helm && \
rm $FILE_NAME && \
rm -rf linux-amd64/ && \
helm version
---
 
---
kubectl get all -A
# NAMESPACE     NAME                                                       READY   STATUS      RESTARTS   AGE
# kube-system   pod/cloud-controller-manager-rke2-master1                  1/1     Running     0          4m43s
# kube-system   pod/etcd-rke2-master1                                      1/1     Running     0          4m36s
# kube-system   pod/helm-install-rke2-canal-dn6g7                          0/1     Completed   0          5m14s
# kube-system   pod/helm-install-rke2-coredns-59vpj                        0/1     Completed   0          5m14s
# kube-system   pod/helm-install-rke2-ingress-nginx-592ms                  0/1     Completed   0          5m14s
# kube-system   pod/helm-install-rke2-metrics-server-zfqpl                 0/1     Completed   0          5m14s
# kube-system   pod/helm-install-rke2-snapshot-controller-bcfwq            0/1     Completed   1          5m14s
# kube-system   pod/helm-install-rke2-snapshot-controller-crd-tz448        0/1     Completed   0          5m14s
# kube-system   pod/helm-install-rke2-snapshot-validation-webhook-7gqnq    0/1     Completed   0          5m14s
# kube-system   pod/kube-apiserver-rke2-master1                            1/1     Running     0          4m34s
# kube-system   pod/kube-controller-manager-rke2-master1                   1/1     Running     0          4m45s
# kube-system   pod/kube-proxy-rke2-master1                                1/1     Running     0          4m29s
# kube-system   pod/kube-proxy-rke2-worker1                                1/1     Running     0          3m46s
# kube-system   pod/kube-proxy-rke2-worker2                                1/1     Running     0          3m45s
# kube-system   pod/kube-scheduler-rke2-master1                            1/1     Running     0          4m42s
# kube-system   pod/rke2-canal-dblfk                                       2/2     Running     0          3m45s
# kube-system   pod/rke2-canal-rnwqn                                       2/2     Running     0          4m34s
# kube-system   pod/rke2-canal-xlvpr                                       2/2     Running     0          3m47s
# kube-system   pod/rke2-coredns-rke2-coredns-84b9cb946c-f2zsk             1/1     Running     0          3m33s
# kube-system   pod/rke2-coredns-rke2-coredns-84b9cb946c-rglf6             1/1     Running     0          4m35s
# kube-system   pod/rke2-coredns-rke2-coredns-autoscaler-b49765765-wx8pg   1/1     Running     0          4m35s
# kube-system   pod/rke2-ingress-nginx-controller-86dm9                    1/1     Running     0          3m14s
# kube-system   pod/rke2-ingress-nginx-controller-896f7                    1/1     Running     0          81s
# kube-system   pod/rke2-ingress-nginx-controller-tlg52                    1/1     Running     0          107s
# kube-system   pod/rke2-metrics-server-655477f655-vwcxz                   1/1     Running     0          3m43s
# kube-system   pod/rke2-snapshot-controller-59cc9cd8f4-vzrrd              1/1     Running     0          3m42s
# kube-system   pod/rke2-snapshot-validation-webhook-54c5989b65-l2d75      1/1     Running     0          3m43s
 
# NAMESPACE     NAME                                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
# default       service/kubernetes                                ClusterIP   10.43.0.1       <none>        443/TCP         5m28s
# kube-system   service/rke2-coredns-rke2-coredns                 ClusterIP   10.43.0.10      <none>        53/UDP,53/TCP   4m35s
# kube-system   service/rke2-ingress-nginx-controller-admission   ClusterIP   10.43.187.134   <none>        443/TCP         3m14s
# kube-system   service/rke2-metrics-server                       ClusterIP   10.43.182.146   <none>        443/TCP         3m43s
# kube-system   service/rke2-snapshot-validation-webhook          ClusterIP   10.43.193.159   <none>        443/TCP         3m43s
 
# NAMESPACE     NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
# kube-system   daemonset.apps/rke2-canal                      3         3         3       3            3           kubernetes.io/os=linux   4m34s
# kube-system   daemonset.apps/rke2-ingress-nginx-controller   3         3         3       3            3           kubernetes.io/os=linux   3m14s
 
# NAMESPACE     NAME                                                   READY   UP-TO-DATE   AVAILABLE   AGE
# kube-system   deployment.apps/rke2-coredns-rke2-coredns              2/2     2            2           4m35s
# kube-system   deployment.apps/rke2-coredns-rke2-coredns-autoscaler   1/1     1            1           4m35s
# kube-system   deployment.apps/rke2-metrics-server                    1/1     1            1           3m43s
# kube-system   deployment.apps/rke2-snapshot-controller               1/1     1            1           3m42s
# kube-system   deployment.apps/rke2-snapshot-validation-webhook       1/1     1            1           3m43s
 
# NAMESPACE     NAME                                                             DESIRED   CURRENT   READY   AGE
# kube-system   replicaset.apps/rke2-coredns-rke2-coredns-84b9cb946c             2         2         2       4m35s
# kube-system   replicaset.apps/rke2-coredns-rke2-coredns-autoscaler-b49765765   1         1         1       4m35s
# kube-system   replicaset.apps/rke2-metrics-server-655477f655                   1         1         1       3m43s
# kube-system   replicaset.apps/rke2-snapshot-controller-59cc9cd8f4              1         1         1       3m42s
# kube-system   replicaset.apps/rke2-snapshot-validation-webhook-54c5989b65      1         1         1       3m43s
 
# NAMESPACE     NAME                                                      COMPLETIONS   DURATION   AGE
# kube-system   job.batch/helm-install-rke2-canal                         1/1           43s        5m23s
# kube-system   job.batch/helm-install-rke2-coredns                       1/1           43s        5m23s
# kube-system   job.batch/helm-install-rke2-ingress-nginx                 1/1           2m6s       5m23s
# kube-system   job.batch/helm-install-rke2-metrics-server                1/1           93s        5m21s
# kube-system   job.batch/helm-install-rke2-snapshot-controller           1/1           95s        5m20s
# kube-system   job.batch/helm-install-rke2-snapshot-controller-crd       1/1           93s        5m21s
# kube-system   job.batch/helm-install-rke2-snapshot-validation-webhook   1/1           93s        5m20s
 
kubectl get ingressclasses.networking.k8s.io -A
# NAME    CONTROLLER             PARAMETERS   AGE
# nginx   k8s.io/ingress-nginx   <none>       3m49s
---
 
---
[Cert Manager]
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack
helm search repo jetstack
# helm pull jetstack/cert-manager \
#     --version v1.14.5
 
helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --namespace cert-manager \
    --create-namespace \
    --version v1.14.5 \
    --set 'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}' \
    --set installCRDs=true
 
watch kubectl get all -n cert-manager
---
 
---
[Client - ex. MacBook]
echo "192.168.0.40 rancher.example.com" | sudo tee -a /etc/hosts
---
 
---
[Rancher]
# https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster
 
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update rancher-stable
helm search repo rancher-stable
helm pull rancher-stable/rancher \
    --version 2.8.4
 
# Error: chart requires kubeVersion: < 1.29.0-0 which is incompatible with Kubernetes v1.30.1+rke2r1
 
helm upgrade rancher rancher-stable/rancher \
    --install \
    --namespace cattle-system \
    --create-namespace \
    --version 2.8.4 \
    --set hostname=rancher.example.com \
    --set replicas=1 \
    --set bootstrapPassword=admin01
 
watch kubectl get all -n cattle-system
 
# url : https://rancher.example.com/dashboard/?setup=admin01
 
# helm delete rancher -n cattle-system
# kubectl delete ns cattle-system
---