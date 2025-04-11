# 05-wordpress-24.0.6-6.7.0-multisite-externalDatabase-snu-20250327.md

```bash
ssh ai196165@147.47.107.204
ㄴ ssh appadm@147.47.107.73

master : 147.47.107.204
worker1 : 147.47.107.205
worker2 : 147.47.107.206

DB(active) : 147.47.107.75
DB(stanby) : 147.47.107.76
appadm | !@wldnjsrhk1023dm

웹서버1 : 147.47.107.73
웹서버2 : 147.47.107.74
appadm | !@wldnjsrhk1023dm

metabrain
metapresso12#$qweR

```

- https://github.com/bitnami/charts/tree/main/bitnami/wordpress

|       NAME        | CHART VERSION | APP VERSION |                    DESCRIPTION                     |
| :---------------: | :-----------: | :---------: | :------------------------------------------------: |
| bitnami/wordpress |    24.0.6     |    6.7.0    | WordPress is the world's most popular blogging ... |

## mariadb

- [03-mariadb-operator-chart-0.30.0-db-10.11.8-20250323.md](../../../Tools/MariaDB/Kubernetes/03-mariadb-operator-chart-0.30.0-db-10.11.8-20250323.md) 로 mariadb-operator 미리 배포

```yaml
cat <<EOF | kubectl -n wordpress apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: wordpress
---
apiVersion: k8s.mariadb.com/v1alpha1
kind: MariaDB
metadata:
  name: mariadb
spec:
  image: docker-registry1.mariadb.com/library/mariadb:10.6.13
  rootPasswordSecretKeyRef:
    name: mariadb-root-password
    key: password
    generate: true
  username: snu
  passwordSecretKeyRef:
    name: mariadb-password
    key: password
    generate: true
  database: snu
  port: 3306
  storage:
    size: 500Gi
  service:
    type: LoadBalancer
  myCnf: |
    [mariadb]
    bind-address=*
    default_storage_engine=InnoDB
    binlog_format=row
    innodb_autoinc_lock_mode=2
    innodb_buffer_pool_size=4G
    max_allowed_packet=256M
  metrics:
    enabled: true
EOF
```

```bash
echo mariadb-root-password : $(kubectl get secret --namespace wordpress mariadb-root-password -o jsonpath="{.data.password}" | base64 -d)
echo mariadb-password : $(kubectl get secret --namespace wordpress mariadb-password -o jsonpath="{.data.password}" | base64 -d)

echo mariadb-password : $(kubectl get secret --namespace wordpress mariadb-password -o jsonpath="{.data.password}" | base64 -d)
mariadb-password : 7A0Xl)PKy1T%G4Bh

echo mariadb-root-password : $(kubectl get secret --namespace wordpress mariadb-root-password -o jsonpath="{.data.password}" | base64 -d)
mariadb-root-password : qe0T3#oxGH7}iM4z

kubectl run -n wordpress --rm -it mariadb-shell --image=mariadb:latest -- /bin/bash
# until mariadb --user='mariadb' --password='2-94+qVkwbvsiCe0' --host=mariadb.wordpress.svc.cluster.local --ssl=false --execute='SELECT 1'; do echo waiting for mariadb; sleep 5; done;
```

## Create Temp Database

```bash
kubectl run -n wordpress --rm -it mariadb-shell2 --image=mariadb:10.6.13 -- /bin/bash

mysql -h mariadb -u root -p -A
mariadb-root-password : qe0T3#oxGH7}iM4z
```

```sql
CREATE DATABASE wordpress CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci;
GRANT ALL PRIVILEGES ON `wordpress`.* TO `snu`@`%`;
FLUSH PRIVILEGES;
```

## WordPress

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami
helm search repo bitnami
helm pull bitnami/wordpress \
  --version 24.0.6
```

````bash
kubectl -n wordpress create secret tls star.snu.ac.kr-tls --key ./STAR.snu.ac.kr.key --cert ./STAR.snu.ac.kr.crt

helm upgrade wordpress bitnami/wordpress \
  --version 24.0.6 \
  --install \
  --namespace wordpress \
  --create-namespace \
  --set wordpressUsername="admin" \
  --set multisite.enable=false \
  --set multisite.host="vmsnucmsit.snu.ac.kr" \
  --set multisite.networkType="subdomain" \
  --set service.type="ClusterIP" \
  --set ingress.enabled=true \
  --set ingress.ingressClassName="nginx" \
  --set ingress.hostname="*.snu.ac.kr" \
  --set ingress.tls=true \
  --set ingress.extraTls[0].hosts[0]="*.snu.ac.kr" \
  --set ingress.extraTls[0].secretName="star.snu.ac.kr-tls" \
  --set mariadb.enabled=false \
  --set externalDatabase.host=mariadb \
  --set externalDatabase.user=snu \
  --set externalDatabase.password="7A0Xl\)PKy1T\%G4Bh" \
  --set externalDatabase.database=wordpress \
  --set externalDatabase.port=3306
```


```bash
watch kubectl get all -n wordpress

helm get values wordpress -n wordpress

kubectl get certificate -n wordpress

echo Username: admin
echo Password: $(kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)
```

Username: admin
Password: HklyDAN57V

## WordPress 파일 복사

```bash
kubectl scale deployment wordpress --replicas=0 -n wordpress
```

```bash
cat <<EOF | kubectl -n wordpress apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pv-editor
  namespace: wordpress
spec:
  containers:
  - command:
    - sleep
    - "604800"
    image: library/ubuntu:22.04
    imagePullPolicy: IfNotPresent
    name: pv-editor
    volumeMounts:
    - mountPath: /dest
      name: vol-0
  restartPolicy: Never
  volumes:
  - name: vol-0
    persistentVolumeClaim:
      claimName: wordpress
  securityContext:
    seccompProfile:
      type: RuntimeDefault
EOF


```

```bash
nano wp-config.php
# define('DB_PASSWORD', '7A0Xl)PKy1T%G4Bh');
# define('WPML_CACHE_PATH_ROOT', '/opt/bitnami/wordpress/wp-content/uploads/' );
# define('DOMAIN_CURRENT_SITE', 'vmsnucmsit.snu.ac.kr');
```

```bash
kubectl cp snu_250325.tar.gz wordpress/pv-editor:/dest/snu_250325.tar.gz
kubectl cp wp-config.php  wordpress/pv-editor:/dest/wp-config.php

kubectl -n wordpress exec -it pv-editor -- /bin/bash

kubectl -n wordpress exec -it wordpress-c9755c676-gzrk2 -- /bin/bash
```

```bash
kubectl scale deployment wordpress --replicas=1 -n wordpress
```

charts/bitnami/wordpress at main · bitnami/charts
Bitnami Helm Charts. Contribute to bitnami/charts development by creating an account on GitHub.

```bash
      /bitnami/wordpress from wordpress-data (rw,path="wordpress")
      /opt/bitnami/apache/conf from empty-dir (rw,path="apache-conf-dir")
      /opt/bitnami/apache/logs from empty-dir (rw,path="apache-logs-dir")
      /opt/bitnami/apache/var/run from empty-dir (rw,path="apache-tmp-dir")
      /opt/bitnami/php/etc from empty-dir (rw,path="php-conf-dir")
      /opt/bitnami/php/tmp from empty-dir (rw,path="php-tmp-dir")
      /opt/bitnami/php/var from empty-dir (rw,path="php-var-dir")
      /opt/binami/wordpress from empty-dir (rw,path="app-base-dir")
      /tmp from empty-dir (rw,path="tmp-dir")

```

path: /

#
````
