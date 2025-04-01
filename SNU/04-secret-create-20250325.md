# 04-secret-create

ai196165@snu-controller:~/certification$ ls -al
drwxrwxr-x 2 ai196165 ai196165 4096 3월 25 14:19 .
drwxr-xr-x 12 ai196165 ai196165 4096 3월 28 10:08 ..
-rw-rw-r-- 1 ai196165 ai196165 1578 10월 25 18:08 ChainBundle.crt
-rw-rw-r-- 1 ai196165 ai196165 1248 10월 25 18:09 GLOBALSIGN_ROOT_CA.crt
-rw-rw-r-- 1 ai196165 ai196165 2378 10월 25 18:09 STAR.snu.ac.kr.crt
-rw-rw-r-- 1 ai196165 ai196165 1678 10월 25 18:09 STAR.snu.ac.kr.key
-rw-rw-r-- 1 ai196165 ai196165 37 10월 25 18:09 ssl_password.sh
-rw-rw-r-- 1 ai196165 ai196165 12 10월 25 18:09 ssl_password.txt

```bash
ai196165@snu-controller:~/certification$ kubectl get secrets -n wordpress
NAME                              TYPE                 DATA   AGE
mariadb-password                  Opaque               1      2d17h
mariadb-root-password             Opaque               1      2d17h
sh.helm.release.v1.wordpress.v1   helm.sh/release.v1   1      43h
star.snu.ac.kr-tls                kubernetes.io/tls    2      45h
wordpress                         Opaque               1      43h
wordpress-externaldb              Opaque               1      43h
```

```bash
🔐 Secret TYPE별 설명
TYPE	설명
Opaque	기본값. 일반적인 키-값 쌍을 담는 Secret. 사용자 정의 목적.
예: DB 비밀번호, API 토큰 등
kubernetes.io/tls	TLS 인증서용 Secret.
필드: tls.crt (인증서), tls.key (비밀키) 포함.
Ingress의 TLS 설정 등에서 사용
helm.sh/release.v1	Helm이 Release 정보를 저장할 때 사용하는 Secret.
Helm의 설치/업그레이드/롤백 정보를 담고 있음
```

📘 각 항목 예시
🔹 Opaque

```yaml
apiVersion: v1
kind: Secret
type: Opaque
data:
  password: cGFzc3dvcmQ= # base64 인코딩된 값
```

⮕ 사용 예: envFrom, env, volumeMount 등으로 컨테이너에 주입

🔹 kubernetes.io/tls

```yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
```

⮕ 사용 예: Ingress TLS, cert-manager 등

🔹 helm.sh/release.v1

```yaml
apiVersion: v1
kind: Secret
type: helm.sh/release.v1
data:
  release: <base64-encoded-helm-release-info>
```

⮕ Helm이 내부적으로 관리하는 Secret (수동 삭제 주의)

✨ 요약

```bash
Secret 이름	Type	용도 요약
mariadb-password	Opaque	마리아DB 사용자 비밀번호 저장
wordpress	Opaque	워드프레스 관리자 계정 정보 등
wordpress-externaldb	Opaque	외부 DB 연결 정보
star.snu.ac.kr-tls	kubernetes.io/tls	TLS 인증서 (Ingress 등에서 사용)
sh.helm.release.v1...	helm.sh/release.v1	Helm 릴리스 상태 저장용 (자동 관리됨)


echo mariadb-root-password : $(kubectl get secret --namespace wordpress mariadb-root-password -o jsonpath="{.data.password}" | base64 -d)
echo mariadb-password : $(kubectl get secret --namespace wordpress mariadb-password -o jsonpath="{.data.password}" | base64 -d)
echo Password: $(kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)
```
