# 08-wordpress-24.0.6-6.7.0_MariaDB_Apache_WEB_WAS-snu-20250331.md

모든 실행은 Master Node(147.47.107.204)에 접속 하여 실행 하시면 됩니다.

## 마스터 노드 접근 방법

```bash
ssh ai196165@147.47.107.204
ㄴ ssh appadm@147.47.107.74 - WEB
ㄴ ssh appadm@147.47.107.76 - DB

master : 147.47.107.204
worker1 : 147.47.107.205
worker2 : 147.47.107.206
ID: ai196165
PW: 1234qwer

DB(active) : 147.47.107.75
DB(stanby) : 147.47.107.76

웹서버1 : 147.47.107.73
웹서버2 : 147.47.107.74
```

# MariaDB 접근 방법

```bash
kubectl run -n wordpress --rm -it mariadb-shell2 --image=mariadb:10.6.13 -- /bin/bash
mysql -h mariadb -u root -p -A
mariadb-root-password : qe0T3#oxGH7}iM4z

use 데이터베이스명[wordpress]
```

# Wordpress 접근 방법

```bash
https://vmsnucmsit.snu.ac.kr
Username: admin
Password: HklyDAN57V
```

---

# Apache Web Pod 접속 (Namespace: apache-web)

```bash
kubectl get pods -n apache-web
kubectl exec -it apache-web-xxxxxxxxx(검색되서 나오는 Pod 명) -n apache-web -- /bin/bash
```

### HTML 저장 경로

/app/WEB_APPS

---

# Apache WAS Pod 접속 (Namespace: apache-was)

```bash
kubectl get pods -n apache-was

kubectl exec -it apache-was-xxxxxxxxx(검색되서 나오는 Pod 명) -n apache-was -- /bin/bash
```

### 소스 저장 경로

/app/WEB_APPS
