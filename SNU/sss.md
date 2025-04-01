```yaml
# ✅ 1. Namespace 정의
apiVersion: v1
kind: Namespace
metadata:
  name: web-was-db
---
# ✅ 2. PVC 정의 (web, was, tibero)
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
          image: harbor.snu.ac.kr/proxy-dockerhub/library/ubuntu:22.04
          command: ['/bin/bash', '-c']
          args:
            - apt update && apt install -y apache2 && apachectl -D FOREGROUND
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
  namespace: web-was-db
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
          image: harbor.snu.ac.kr/proxy-dockerhub/library/ubuntu:22.04
          command: ['/bin/bash', '-c']
          args:
            - apt update && apt install -y openjdk-11-jdk wget unzip && \
              wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.zip && \
              unzip apache-tomcat-9.0.85.zip && \
              apache-tomcat-9.0.85/bin/catalina.sh run
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
---
# ✅ 5. Tibero Deployment + LoadBalancer Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tibero
  namespace: web-was-db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tibero
  template:
    metadata:
      labels:
        app: tibero
    spec:
      containers:
        - name: tibero
          image: harbor.snu.ac.kr/proxy-dockerhub/library/ubuntu:22.04
          ports:
            - containerPort: 8629 # Tibero 포트 (MariaDB 3306과 구분)
          volumeMounts:
            - name: tibero-volume
              mountPath: /home/tibero6
          env:
            - name: TB_SID
              value: tibero
            - name: TB_PORT
              value: '8629'
      volumes:
        - name: tibero-volume
          persistentVolumeClaim:
            claimName: tibero-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: tibero-lb
  namespace: web-was-db
spec:
  type: LoadBalancer
  loadBalancerIP: 100.100.100.160
  selector:
    app: tibero
  ports:
    - port: 8629
      targetPort: 8629
```
