# 05-wordpress-24.0.6-6.7.0-multisite-externalDatabase-snu-20250327.md

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
              mountPath: /var/www/html
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
              apache-tomcat-9.0.85/bin/catalina.sh run
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: was-storage
              mountPath: /usr/local/tomcat/webapps
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
      nodePort: 30081
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
2. 컨테이너, k8s 기본 사용 + 내용 정리
3. ubuntu+web, ubuntu+was, DB:Tibero 설치 연결 연동
4. appach image 설치
```
