# 2024-06-01

# https://github.com/rancher/rke2

# https://docs.rke2.io/install/methods

# https://github.com/helm/helm/releases

NAME STATUS ROLES AGE VERSION INTERNAL-IP EXTERNAL-IP OS-IMAGE KERNEL-VERSION CONTAINER-RUNTIME
master1 Ready control-plane,etcd,master 26m v1.28.10+rke2r1 192.168.0.130 `<none>` Ubuntu 22.04.4 LTS 5.15.0-105-generic containerd://1.7.11-k3s2
worker1 Ready `<none>` 25m v1.28.10+rke2r1 192.168.0.131 `<none>` Ubuntu 22.04.4 LTS 5.15.0-105-generic containerd://1.7.11-k3s2
worker2 Ready `<none>` 6m48s v1.28.10+rke2r1 192.168.0.132 `<none>` Ubuntu 22.04.4 LTS 5.15.0-105-generic containerd://1.7.11-k3s2

worker1 - GPU X
worker2 - GPU X

# ssh root@192.168.0.9

---

export TEMPLATE_ID=9003
export VM_ID=130
export VM_NAME=sjh-rke-master
export VM_NIC=vmbr0
export VM_IP=192.168.0.130/24
export VM_GW=192.168.0.1
export STORAGE=local-lvm
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full true
qm set $VM_ID --machine q35,viommu=intel
qm set $VM_ID --bios ovmf --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=0
qm set $VM_ID --memory 4096 --cores 4
qm set $VM_ID --net0 virtio,bridge=$VM_NIC,firewall=1
qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW
qm set $VM_ID --ciupgrade 0
qm resize $VM_ID scsi0 +100G
qm snapshot $VM_ID Pre

export TEMPLATE_ID=9003
export VM_ID=131
export VM_NAME=sjh-rke-work1
export VM_NIC=vmbr0
export VM_IP=192.168.0.131/24
export VM_GW=192.168.0.1
export STORAGE=local-lvm
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full true
qm set $VM_ID --machine q35,viommu=intel
qm set $VM_ID --bios ovmf --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=0
qm set $VM_ID --memory 4096 --cores 4
qm set $VM_ID --net0 virtio,bridge=$VM_NIC,firewall=1
qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW
qm set $VM_ID --ciupgrade 0
qm resize $VM_ID scsi0 +100G
qm snapshot $VM_ID Pre

export TEMPLATE_ID=9003
export VM_ID=132
export VM_NAME=sjh-rke-work2
export VM_NIC=vmbr0
export VM_IP=192.168.0.132/24
export VM_GW=192.168.0.1
export STORAGE=local-lvm
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full true
qm set $VM_ID --machine q35,viommu=intel
qm set $VM_ID --bios ovmf --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=0
qm set $VM_ID --memory 8192 --cores 8
qm set $VM_ID --net0 virtio,bridge=$VM_NIC,firewall=1
qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW
qm set $VM_ID --ciupgrade 0
qm resize $VM_ID scsi0 +100G
qm snapshot $VM_ID Pre

export TEMPLATE_ID=9003
export VM_ID=133
export VM_NAME=sjh-rke-work3
export VM_NIC=vmbr0
export VM_IP=192.168.0.133/24
export VM_GW=192.168.0.1
export STORAGE=local-lvm
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full true
qm set $VM_ID --machine q35,viommu=intel
qm set $VM_ID --bios ovmf --efidisk0 $STORAGE:1,efitype=4m,pre-enrolled-keys=0
qm set $VM_ID --memory 8192 --cores 8
qm set $VM_ID --net0 virtio,bridge=$VM_NIC,firewall=1
qm set $VM_ID --ipconfig0 ip=$VM_IP,gw=$VM_GW
qm set $VM_ID --ciupgrade 0
qm resize $VM_ID scsi0 +100G
qm snapshot $VM_ID Pre

---

# ssh ubuntu@192.168.0.130

---

curl -sfL https://get.rke2.io --output install.sh
chmod +x install.sh

# sudo INSTALL_RKE2_CHANNEL=v1.28.10+rke2r1 ./install.sh

# sudo INSTALL_RKE2_CHANNEL=v1.31.6+rke2r1 ./install.sh

sudo INSTALL_RKE2_CHANNEL=v1.31.6+rke2r1 ./install.sh
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service
journalctl -u rke2-server -f

mkdir .kube
sudo cp /etc/rancher/rke2/rke2.yaml .kube/config
sudo chown $USER. .kube/config
sudo cp /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/

sudo cat /var/lib/rancher/rke2/server/node-token

# K10530f4f6f7d053cedf49ad9e1261bd2dae862819a344d1d08a7bee6ec35b88f87::server:93e2129b1f28956f20db00e355f667ac

---

# ssh ubuntu@192.168.0.131~32

---

curl -sfL https://get.rke2.io --output install.sh
chmod +x install.sh

<!-- sudo INSTALL_RKE2_CHANNEL=v1.28.10+rke2r1 ./install.sh -->

sudo INSTALL_RKE2_CHANNEL=v1.31.6+rke2r1 ./install.sh
sudo systemctl enable rke2-agent.service

sudo mkdir -p /etc/rancher/rke2/
sudo tee -a /etc/rancher/rke2/config.yaml <<EOF
server: https://192.168.0.130:9345
token: K10530f4f6f7d053cedf49ad9e1261bd2dae862819a344d1d08a7bee6ec35b88f87::server:93e2129b1f28956f20db00e355f667ac
EOF

sudo systemctl start rke2-agent.service
journalctl -u rke2-agent -f

---

---

[Enable Auto-completion for Kubectl in a Linux Bash Shell]

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#optional-kubectl-configurations-and-plugins

type \_init_completion

# Ubuntu

sudo apt-get install -y bash-completion

# Centos

sudo yum install -y bash-completion

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F \_\_start_kubectl k' >>~/.bashrc

echo 'export KUBE_EDITOR=nano' >>~/.bashrc

## source ~/.bashrc

---

[Install Helm]
export FILE_NAME=helm-v3.15.1-linux-amd64.tar.gz
wget https://get.helm.sh/$FILE_NAME &&
tar -zxvf $FILE_NAME &&
sudo mv linux-amd64/helm /usr/local/bin/helm &&
rm $FILE_NAME &&
rm -rf linux-amd64/ &&
helm version

---

---

kubectl get all -A

<!--
NAMESPACE     NAME                                                        READY   STATUS      RESTARTS   AGE
kube-system   pod/cloud-controller-manager-sjh-rke-depoly                 1/1     Running     0          26m
kube-system   pod/etcd-sjh-rke-depoly                                     1/1     Running     0          26m
kube-system   pod/helm-install-rke2-canal-ghxf5                           0/1     Completed   0          27m
kube-system   pod/helm-install-rke2-coredns-5l6sf                         0/1     Completed   0          27m
kube-system   pod/helm-install-rke2-ingress-nginx-z8xb4                   0/1     Completed   0          27m
kube-system   pod/helm-install-rke2-metrics-server-hctw8                  0/1     Completed   0          27m
kube-system   pod/helm-install-rke2-runtimeclasses-75d2w                  0/1     Completed   0          27m
kube-system   pod/helm-install-rke2-snapshot-controller-656xm             0/1     Completed   2          27m
kube-system   pod/helm-install-rke2-snapshot-controller-crd-tpfpd         0/1     Completed   0          27m
kube-system   pod/kube-apiserver-sjh-rke-depoly                           1/1     Running     0          26m
kube-system   pod/kube-controller-manager-sjh-rke-depoly                  1/1     Running     0          26m
kube-system   pod/kube-proxy-sjh-rke-depoly                               1/1     Running     0          26m
kube-system   pod/kube-proxy-sjh-rke-master1                              1/1     Running     0          7m4s
kube-system   pod/kube-proxy-sjh-rke-work1                                1/1     Running     0          9m4s
kube-system   pod/kube-proxy-sjh-rke-work2                                1/1     Running     0          7m
kube-system   pod/kube-scheduler-sjh-rke-depoly                           1/1     Running     0          26m
kube-system   pod/rke2-canal-8kw4q                                        2/2     Running     0          9m4s
kube-system   pod/rke2-canal-9dj48                                        2/2     Running     0          26m
kube-system   pod/rke2-canal-9fb5p                                        2/2     Running     0          9m
kube-system   pod/rke2-canal-zqfrd                                        2/2     Running     0          9m
kube-system   pod/rke2-coredns-rke2-coredns-55bdf87668-bk8dl              1/1     Running     0          26m
kube-system   pod/rke2-coredns-rke2-coredns-55bdf87668-hbm6r              1/1     Running     0          8m58s
kube-system   pod/rke2-coredns-rke2-coredns-autoscaler-65c8c6bd64-pqxf5   1/1     Running     0          26m
kube-system   pod/rke2-ingress-nginx-controller-88rf5                     1/1     Running     0          25m
kube-system   pod/rke2-ingress-nginx-controller-csvks                     1/1     Running     0          6m52s
kube-system   pod/rke2-ingress-nginx-controller-jbmkb                     1/1     Running     0          6m47s
kube-system   pod/rke2-ingress-nginx-controller-nm2dr                     1/1     Running     0          6m48s
kube-system   pod/rke2-metrics-server-58ff89f9c7-gjp7p                    1/1     Running     0          25m
kube-system   pod/rke2-snapshot-controller-58dbcfd956-gdh2h               1/1     Running     0          25m

NAMESPACE     NAME                                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
default       service/kubernetes                                ClusterIP   10.43.0.1       <none>        443/TCP         27m
kube-system   service/rke2-coredns-rke2-coredns                 ClusterIP   10.43.0.10      <none>        53/UDP,53/TCP   26m
kube-system   service/rke2-ingress-nginx-controller-admission   ClusterIP   10.43.68.120    <none>        443/TCP         25m
kube-system   service/rke2-metrics-server                       ClusterIP   10.43.150.234   <none>        443/TCP         25m

NAMESPACE     NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/rke2-canal                      4         4         4       4            4           kubernetes.io/os=linux   26m
kube-system   daemonset.apps/rke2-ingress-nginx-controller   4         4         4       4            4           kubernetes.io/os=linux   25m

NAMESPACE     NAME                                                   READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/rke2-coredns-rke2-coredns              2/2     2            2           26m
kube-system   deployment.apps/rke2-coredns-rke2-coredns-autoscaler   1/1     1            1           26m
kube-system   deployment.apps/rke2-metrics-server                    1/1     1            1           25m
kube-system   deployment.apps/rke2-snapshot-controller               1/1     1            1           25m

NAMESPACE     NAME                                                              DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/rke2-coredns-rke2-coredns-55bdf87668              2         2         2       26m
kube-system   replicaset.apps/rke2-coredns-rke2-coredns-autoscaler-65c8c6bd64   1         1         1       26m
kube-system   replicaset.apps/rke2-metrics-server-58ff89f9c7                    1         1         1       25m
kube-system   replicaset.apps/rke2-snapshot-controller-58dbcfd956               1         1         1       25m

NAMESPACE     NAME                                                  STATUS     COMPLETIONS   DURATION   AGE
kube-system   job.batch/helm-install-rke2-canal                     Complete   1/1           30s        27m
kube-system   job.batch/helm-install-rke2-coredns                   Complete   1/1           30s        27m
kube-system   job.batch/helm-install-rke2-ingress-nginx             Complete   1/1           89s        27m
kube-system   job.batch/helm-install-rke2-metrics-server            Complete   1/1           74s        27m
kube-system   job.batch/helm-install-rke2-runtimeclasses            Complete   1/1           75s        27m
kube-system   job.batch/helm-install-rke2-snapshot-controller       Complete   1/1           88s        27m
kube-system   job.batch/helm-install-rke2-snapshot-controller-crd   Complete   1/1           75s        27m -->

kubectl get ingressclasses.networking.k8s.io -A

# NAME CONTROLLER PARAMETERS AGE

# nginx k8s.io/ingress-nginx `<none>` 27m

---

---

[Cert Manager]
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack
helm search repo jetstack

# helm pull jetstack/cert-manager \

# --version v1.14.5

helm upgrade cert-manager jetstack/cert-manager
--install
--namespace cert-manager
--create-namespace
--version v1.14.5
--set 'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}'
--set installCRDs=true

## watch kubectl get all -n cert-manager

---

[Client - ex. MacBook]
echo "192.168.0.130 rancher.example.com" | sudo tee -a /etc/hosts

---

---

[Rancher]

# https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/install-upgrade-on-a-kubernetes-cluster

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update rancher-stable
helm search repo rancher-stable
helm pull rancher-stable/rancher
--version 2.10.3

# Error: chart requires kubeVersion: < 1.29.0-0 which is incompatible with Kubernetes v1.30.1+rke2r1

helm upgrade rancher rancher-stable/rancher
--install
--namespace cattle-system
--create-namespace
--version 2.10.3
--set hostname=rancher.sample.com
--set replicas=1
--set bootstrapPassword=admin01

watch kubectl get all -n cattle-system

# url : https://rancher.sample.com/dashboard/?setup=admin01

# kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='}}'

# helm delete rancher -n cattle-system

# kubectl delete ns cattle-system

---
