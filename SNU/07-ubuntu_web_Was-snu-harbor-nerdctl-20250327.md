# 06-ubuntu_web_Was-snu-20250327.md

✅ Namespace 정의

```yaml
# ----------------------
# 1. Namespace 생성
# ----------------------
apiVersion: v1
kind: Namespace
metadata:
  name: apache-web
---
apiVersion: v1
kind: Namespace
metadata:
  name: apache-was
---
# ----------------------
# 2. PVC 정의
# ----------------------

# Apache Web PVC (5Gi)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: apache-web-pvc
  namespace: apache-web
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: ceph-block
---
# Apache WAS PVC (10Gi)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: apache-was-pvc
  namespace: apache-was
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: ceph-block
---
# ----------------------
# 3. Apache Web Deployment + NodePort Service
# ----------------------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-web
  namespace: apache-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apache-web
  template:
    metadata:
      labels:
        app: apache-web
    spec:
      containers:
        - name: apache-web
          image: ubuntu:22.04
          command: ['/bin/bash', '-c']
          args:
            - apt update &&
              apt install -y apache2 &&
              apachectl -D FOREGROUND
          ports:
            - containerPort: 80
          volumeMounts:
            - name: web-storage
              mountPath: /app/WEB_APPS
      volumes:
        - name: web-storage
          persistentVolumeClaim:
            claimName: apache-web-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: apache-web-svc
  namespace: apache-web
spec:
  selector:
    app: apache-web
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
  #  type: NodePort
  type: ClusterIP

---
# ----------------------
# 4. Apache WAS Deployment + NodePort Service
# ----------------------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-was
  namespace: apache-was
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apache-was
  template:
    metadata:
      labels:
        app: apache-was
    spec:
      containers:
        - name: apache-was
          image: ubuntu:22.04
          command: ['/bin/bash', '-c']
          args:
            - apt update &&
              apt install -y openjdk-11-jdk wget unzip &&
              wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.zip &&
              unzip apache-tomcat-9.0.85.zip &&
              chmod +x apache-tomcat-9.0.85/bin/catalina.sh &&
          #              apache-tomcat-9.0.85/bin/catalina.sh run
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: was-storage
              mountPath: /app/WEB_APPS
      volumes:
        - name: was-storage
          persistentVolumeClaim:
            claimName: apache-was-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: apache-was-svc
  namespace: apache-was
spec:
  selector:
    app: apache-was
  ports:
    - port: 8080
      targetPort: 8080
  #      nodePort: 30081
  #  type: NodePort
  type: ClusterIP
```

---

🔹 Apache Web Pod 접속 (Namespace: apache-web)

```bash
kubectl get pods -n apache-web
kubectl exec -it apache-web-696666887c-mkwgf -n apache-web -- /bin/bash
```

### HTML 저장 경로

/var/www/html

---

🔹 Apache WAS Pod 접속 (Namespace: apache-was)

```bash
kubectl get pods -n apache-was
kubectl exec -it apache-was-7d76469fb7-78rhf -n apache-was -- /bin/bash
```

### 소스 저장 경로

/usr/local/tomcat/webapps

          - apt update &&
            apt install -y openjdk-11-jdk wget unzip &&
            wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.zip &&
            unzip apache-tomcat-9.0.85.zip &&
            chmod +x apache-tomcat-9.0.85/bin/catalina.sh

```bash
1. 진행상황 정리
2. 컨테이너, k8s 기본 사용 + 내용 정리 -
3. ubuntu+web, ubuntu+was, DB:Tibero 설치 연결 연동
4. appach image 설치
```

# Secret 복사

kubectl get secret star.snu.ac.kr-tls -n default -o yaml | \
 sed 's/namespace: default/namespace: harbor/' | \
 kubectl apply -n harbor -f -

```bash
helm repo add harbor https://helm.goharbor.io
helm repo update
helm search repo

kubectl create namespace harbor
```

# Harbor 설치 (NodePort)

```bash
helm install harbor harbor/harbor \
  --namespace harbor \
  --set expose.type=nodePort \
  --set expose.tls.enabled=false \
  --set expose.nodePort.ports.http.port=30080 \
  --set expose.nodePort.ports.https.port=30443 \
  --set persistence.persistentVolumeClaim.registry.size=200Gi


helm install harbor harbor/harbor \
  --namespace harbor --create-namespace \
  --set expose.type=ingress \
  --set expose.ingress.hosts.core=harbor.snu.ac.kr \
  --set expose.tls.enabled=true \
  --set expose.tls.secretName=star.snu.ac.kr-tls \
  --set expose.ingress.className=nginx \
  --set externalURL=https://harbor.snu.ac.kr \
  --set persistence.persistentVolumeClaim.registry.size=50Gi \
  --set harborAdminPassword=harbor123

```

✅ RKE2 (containerd)에서 이미지 우선순위 지정 방법
📁 설정 파일: /etc/rancher/rke2/registries.yaml
해당 파일을 수정해 미러(mirrors) 우선순위를 지정합니다.

🧾 예시: Harbor → Docker Hub 순으로 검색하도록 설정

```yaml
mirrors:
  'docker.io':
    endpoints:
      - 'https://harbor.snu.ac.kr' # 1️⃣ Harbor 먼저
      - 'https://registry-1.docker.io' # 2️⃣ Docker Hub fallback

configs:
  'harbor.snu.ac.kr':
    tls:
      ca_file: '/etc/rancher/rke2/certs.d/harbor.snu.ac.kr/ca.crt'
```

```yaml
mirrors:
  'docker.io':
    endpoints:
      - 'https://harbor.snu.ac.kr'
      - 'https://registry-1.docker.io'

configs:
  'harbor.snu.ac.kr':
    tls:
      insecure_skip_verify: true
```

✅ 적용 방법
파일 저장

```bash
sudo mkdir -p /etc/rancher/rke2/
sudo nano /etc/rancher/rke2/registries.yaml
RKE2 서비스 재시작
```

```bash
sudo systemctl restart rke2-server
# 또는 agent 노드라면
sudo systemctl restart rke2-agent
```

🧩 기본 개념: Pod → 이미지 → Harbor 저장 순서
단계 설명
1️⃣ Pod에서 실행 중인 이미지 식별 어떤 이미지를 사용 중인지 확인
2️⃣ 이미지 export (tar로 저장) crictl, ctr, nerdctl 등으로 export
3️⃣ Harbor에 push nerdctl 또는 Docker로 tag + push

✅ Step-by-step 실전 예제
예제: nginx라는 Pod가 실행 중이라고 가정

✅ 1. Pod가 사용하는 이미지 확인

```bash

kubectl get pod nginx -o jsonpath="{.spec.containers[*].image}"

예)
docker.io/library/nginx:latest
```

✅ 2. 해당 이미지 export (containerd 환경에서)
2-1. 이미지 저장 (RKE2는 containerd 기반)

```bash

sudo ctr -n k8s.io images ls | grep nginx
예: docker.io/library/nginx:latest 를 발견했다면:


sudo ctr -n k8s.io images export nginx.tar docker.io/library/nginx:latest
```

✅ 3. Docker 또는 nerdctl 환경으로 이동하여 이미지 import

```bash
# 로컬로 가져옴
sudo ctr -n k8s.io images export nginx.tar docker.io/library/nginx:latest

# nerdctl 환경으로 import
nerdctl image load < nginx.tar

# Harbor용으로 이미지 태깅
nerdctl tag docker.io/library/nginx:latest harbor.snu.ac.kr/proxy-dockerhub/library/nginx:from-k8s

# 로그인 후 push
nerdctl login harbor.snu.ac.kr
nerdctl push harbor.snu.ac.kr/proxy-dockerhub/library/nginx:from-k8s
```

✅ 4. Harbor에서 확인
Harbor 웹 UI 접속 → proxy-dockerhub 프로젝트 확인

library/nginx:from-k8s 이미지가 업로드됨

✅ nerdctl 설치 방법 (RKE2 노드 기준)
📌 1. containerd 확인 (RKE2는 기본 포함)

```bash
which containerd
containerd --version
```

정상적으로 나오면 ✅ OK

📦 2. nerdctl 설치

```bash

# 최신 릴리스 확인 및 다운로드
curl -sSL https://github.com/containerd/nerdctl/releases/latest/download/nerdctl-full-1.7.4-linux-amd64.tar.gz -o nerdctl-full.tar.gz

# 압축 해제
tar -xzf nerdctl-full.tar.gz

# 실행 파일 복사
sudo cp nerdctl /usr/local/bin/
```

nerdctl, containerd, buildkitd 등이 함께 포함되지만, 단순 이미지 push/pull은 nerdctl만 있으면 됩니다.

✅ 3. nerdctl 동작 확인

```bash
nerdctl version
nerdctl info
containerd와 연결된 상태에서 정상 출력되면 성공 🎉
```

✅ nerdctl Harbor 로그인

```bash
nerdctl login harbor.snu.ac.kr
로그인하면 $HOME/.docker/config.json에 credentials가 저장됩니다
이미 로그인한 후에는 nerdctl push에서 자동 사용됩니다.
```

```xml 예시
<License>
  <User>SNULab</User>
  <Company>TmaxSoft</Company>                                                                                                                                    <Product>Tibero</Product>
  <Version>6</Version>                                                                                                                                           <HostID>ABC123456789</HostID>
  <IssueDate>2024-01-01</IssueDate>
  <ExpireDate>2025-12-31</ExpireDate>
  <Signature>abcdef1234567890</Signature>
</License>
```

```yaml
# ✅ 1. Namespace 정의
apiVersion: v1
kind: Namespace
metadata:
  name: web-was-db
---
# ✅ 2. PVC 정의
# Web PVC (5Gi)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-pvc
  namespace: web-was-db
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: ceph-block
---
# WAS PVC (50Gi)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: was-pvc
  namespace: web-was-db
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: ceph-block
---
# Tibero PVC (200Gi)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tibero-pvc
  namespace: web-was-db
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
  storageClassName: ceph-block
---
# ✅ 3. Web Deployment + Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ubuntu-web
  namespace: web-was-db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ubuntu-web
  template:
    metadata:
      labels:
        app: ubuntu-web
    spec:
      containers:
        - name: apache-web
          image: ubuntu/apache2
          ports:
            - containerPort: 80
          volumeMounts:
            - name: web-volume
              mountPath: /app/WEB_APPS
      volumes:
        - name: web-volume
          persistentVolumeClaim:
            claimName: web-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: ubuntu-web-svc
  namespace: web-was-db
spec:
  selector:
    app: ubuntu-web
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
---
# ✅ 4. WAS Deployment + Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ubuntu-was
  namespace: web-was-db:q
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ubuntu-was
  template:
    metadata:
      labels:
        app: ubuntu-was
    spec:
      containers:
        - name: apache-was
          image: ssss:jammy/v2
          command: ['/bin/bash', '-c', '--']
          args: ['while true; do sleep 30; done']
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: was-volume
              mountPath: /app/WEB_APPS
      volumes:
        - name: was-volume
          persistentVolumeClaim:
            claimName: was-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: ubuntu-was-svc
  namespace: web-was-db
spec:
  selector:
    app: ubuntu-was
  ports:
    - port: 8080
      targetPort: 8080
  type: ClusterIP
```

```bash
kubectl create configmap tibero-license \
  --from-file=license.xml=/home/ai196165/license.xml \
  -n web-was-db
```

```yaml
# ✅ 2. ConfigMap: license.xml 포함
apiVersion: v1
kind: ConfigMap
metadata:
  name: tibero-license
  namespace: web-was-db
data:
  license.xml: |
    (여기에 license.xml 내용 붙여넣기)
```

```bash
 apt update && \
 apt install -y openjdk-11-jdk wget unzip && \
 wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz && \
 tar -xvzf apache-tomcat-9.0.85.tar.gz && \
 chmod +x apache-tomcat-9.0.85/bin/catalina.sh
 # apache-tomcat-9.0.85/bin/catalina.sh run

```
