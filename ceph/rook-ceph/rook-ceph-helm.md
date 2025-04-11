- helm 활용 rook 오퍼레이터 구성

helm 으로 간단하게 rook-ceph 구성해 보겠습니다.

```bash
- (repo 추가)
(repo 추가)
$ helm repo add rook-release https://charts.rook.io/release
$ helm search repo rook-ceph (rook 오퍼레이터 설치)
$ kubectl create namespace rook-ceph (repo 추가)
$ helm install --namespace rook-ceph rook-ceph rook-release/rook-ceph
$ kubectl get all -n rook-ceph
-
```

- Ceph 클러스터 구성

rook/deploy/examples/ 에 여러 예제 파일이 존재합니다. helm chart 기본 구성으로 설치합니다. 기본으로 구성할 경우, 2개의 MGR / 3개의 MON / 빈디스크 수만큼의 OSD 데몬이 생성됩니다. 최소 3개 노드이상일 경우 기본구성으로 설치하면 적당합니다. 아래 설치하기 전에 위에 구성한 오퍼레이터가 꼭 동작하고 있어야 합니다. 만약 오퍼레이터가 설치 중이라면 설치완료 후 진행합니다.

$ helm install --namespace rook-ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster
$ kubectl get all -n rook-ceph

기본으로 구성하면, 스토리지 클래스에 Ceph-Block, Ceph-Bucket, Ceph-File system 이 모두 생성됩니다. 필요한 것만 설치한다면 예제파일 참고하여 구성할 수 있습니다.

-
- Toolbox 설치

rook/deploy/examples/ 에 toolbox.yaml 파일을 사용하여 구성합니다. toolbox를 통해 ceph cli를 사용할 수 있습니다.

$ kubectl apply -f toolbox.yaml $ kubectl get deploy rook-ceph-tools -n rook-ceph
$ kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash (toolbox)
$ ceph -s (toolbox)
$ ceph osd status

-
- Dashboard 사용

Ceph-Cluster관련 서비스가 모두 작동한다면, Dashboard 서비스가 동작중인 것을 확인할 수 있습니다. Dashboard는 기본 ClusterIP 서비스로 동작합니다. 외부에서 접속이 가능하게, LoadBalancer로 변경하여 사용합니다. (k8s에 LoadBalancer 서비스가 설치되어 있어야 합니다.) 먼저, CephCluster의 Dashboard 서비스를 ssl을 사용하지 않도록 변경하고, 기본 url을 변경합니다.

$ kubectl get svc -n rook-ceph
$ kubectl edit CephCluster rook-ceph -n rook-ceph
(수정전) dashboard :
enabled : true
ssl : true
(수정후) dashboard :
enabled : true
ssl : false
urlPrefix : /ceph-dashboard

대시보드가 ssl을 사용한다면 8443 포트이지만, 우리는 ssl을 사용하지 않도록 구성하니 7000 포트로 고정됩니다. rook-ceph 예제파일 중 dashboard-loadbalancer.yaml 파일을 수정하고 적용합니다.

- $ vi dashboard**-**loadbalancer.yaml
- (수정전)
- **port** **:** **8443**
- **targetPort** **:** **8443**
- (수정후)
- **port** **:** **7000**
- **targetPort** **:** **7000**
- $ kubectl apply **-**f dashboard**-**loadbalancer.yaml

이제 rook-ceph-mgr-dashboard-loadbalancer라는 서비스가 LoadBalancer 타입으로 만들어지고 외부 IP가 확인됩니다.

| $ kubectl get svc -n rook-ceph       |              |               |               |                   |       |
| ------------------------------------ | ------------ | ------------- | ------------- | ----------------- | ----- |
| NAME                                 | TYPE         | CLUSTER-IP    | EXTERNAL-IP   | PORT(S)           | AGE   |
| rook-ceph-mgr                        | ClusterIP    | 10.233.49.224 | `<none>`      | 9283/TCP          | 157m  |
| rook-ceph-mgr-dashboard              | ClusterIP    | 10.233.27.231 | `<none>`      | 7000/TCP          | 157m  |
| rook-ceph-mgr-dashboard-loadbalancer | LoadBalancer | 10.233.23.189 | 192.168.0.170 | 000:31460/TCP     | 7m54s |
| rook-ceph-mon-a                      | ClusterIP    | 10.233.60.101 | `<none>`      | 6789/TCP,3300/TCP | 159m  |
| rook-ceph-mon-b                      | ClusterIP    | 10.233.32.79  | `<none>`      | 6789/TCP,3300/TCP | 158m  |
| rook-ceph-mon-c                      | ClusterIP    | 10.233.1.9    | `<none>`      | 6789/TCP,3300/TCP | 158m  |
| rook-ceph- rgw-ceph-objectstore      | ClusterIP    | 10.233.40.192 | `<none>`      | 80/TCP            |       |

브라우저에서 http://192.168.0.170:7000/ceph-dashboard/ 경로로 접속할 수 있습니다. 계정은 admin이고 패스워드는 아래 명령으로 확인할 수 있습니다.

![](https://erevent.co.kr/230213_itmaya_K8s/img/2.png)

- # 패스워드 확인
- $ kubectl **get** secret rook**-**ceph**-**dashboard**-**password **-**n rook**-**ceph **-**o yaml **|** grep **"password:"** **|** awk **'{print $2}'** **|** base64 **--**decode
-
- (Ceph-filesystem) PVC 생성

PVC를 생성하면 자동으로 PV도 함께 생성되고 연결됩니다. PVC 생성 예제 파일도 마찬가지로 ceph-csi/example/ 에서 확인할 수 있습니다.

- $ vi cephfs**-**pvc01.yaml
- **---**
- **apiVersion** **:** v1
- **kind** **:** PersistentVolumeClaim
- **metadata** **:**
- **name** **:** cephfs**-**pvc01
- **spec** **:**
- **accessModes** **:**
- **-**ReadWriteMany
- **resources** **:**
- **requests** **:**
- **storage** **:** 5Gi
- ** storageClassName** **:** ceph**-**filesystem
- $ kubectl apply **-**f cephfs**-**pvc01.yaml
- $ kubectl **get** pvc
-
- (ceph-block) PVC 생성

CephFS와 가장 큰 차이점은 PVC 생성 시 accessModes값을 ReadWriteOnce로 구성했다는 것입니다. RBD는 ReadWriteMany로 구성할 수 없습니다.

- $ vi cephblock**-**pvc01.yaml
- **---**
- **apiVersion** **:** v1
- **kind** **:** PersistentVolumeClaim
- **metadata** **:**
- **name** **:** rbd**-**pvc
- **spec** **:**
- **accessModes** **:**
- **-**ReadWriteOnce
- **resources** **:**
- **requests** **:**
- **storage** **:** 10Gi
- ** storageClassName** **:** ceph**-**block
- $ kubectl apply **-**f cephblock**-**pvc01.yaml
- $ kubectl **get** pvc
-
- Test pod 생성 및 확인

ceph-filesystem PVC와 ceph-block PVC가 생성되었고 pvc 정보가 bound로 출력되는 것을 확인할 수 있습니다. pod를 만들어 마운트가 되는지 테스트해봅니다.

- $ vi ceph**-**test**-**pod.yaml
- **---**
- **apiVersion** **:** v1
- **kind** **:** Pod
- **metadata** **:**
- **name** **:** ceph**-**test**-**pod
- **spec** **:**
- **containers** **:**
- **-** name **:** web**-**server
- **image** **:** nginx
- **volumeMounts** **:**
- **-** name **:** ceph**-**filesystem**-01**
- **mountPath** **: /**data1
- **-** name **:** ceph**-**block**-01**
- **mountPath** **: /**data2
- **volumes** **:**
- **-** name **:** ceph**-**filesystem**-01**
- **persistentVolumeClaim** **:**
- **claimName** **:** rbd**-**pvc
- **readOnly** **:** **false**
- **-** name **:** ceph**-**block**-01**
- **mountPath** **: /**data2
- **-** name **:** ceph**-**block**-01**
- **persistentVolumeClaim** **:**
- **claimName** **:** rbd**-**pvc
- **readOnly** **:** **false**
- $ kubectl apply **-**f ceph**-**test**-**pod.yaml

| (확인)                                     |      |      |       |      |                                            |
| ------------------------------------------ | ---- | ---- | ----- | ---- | ------------------------------------------ |
| $ kubectl exec -ti ceph-test-pod /bin/bash |      |      |       |      |                                            |
| rdb-test-pod01>df -h                       |      |      |       |      |                                            |
| Filesystem                                 | Size | Used | Avail | Use% | Mounted on                                 |
| overlay                                    | 49G  | 17G  | 30G   | 37%  | /                                          |
| tmpfs                                      | 64M  | 0    | 64M   | 0%   | /dev                                       |
| tmpfs                                      | 14G  | 0    | 14G   | 0%   | /sys/fs/cgroup                             |
| 10.233.1.9:6789,10.233.60.101:6789---      | 5.0G | 0    | 5.0G  | 0%   | /data1                                     |
| /dev/rbd0                                  | 9.8G | 24K  | 9.8G  | 1%   | /data2                                     |
| /dev/mapper/ubuntu --vg-ubuntu--lv         | 49G  | 17G  | 30G   | 37%  | /etc/hosts                                 |
| shm                                        | 64M  | 0    | 64M   | 0%   | /dev/shm                                   |
| tmpfs                                      | 28G  | 12K  | 28G   | 1%   | /run/secrets /kubernetes.io/serviceaccount |
| tmpfs                                      | 14G  | 0    | 14G   | 0%   | /proc/acpi                                 |
| tmpfs                                      | 14G  | 0    | 14G   | 0%   | /proc/scsi                                 |
| tmpfs                                      | 14G  | 0    | 14G   | 0%   | /sys/firmware                              |
