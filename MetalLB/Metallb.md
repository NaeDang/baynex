📌 1. 사전 준비
🧾 필요한 환경
Rancher가 연결된 Kubernetes 클러스터
kubectl, helm CLI 설치 및 설정 완료
Layer 2 네트워크 IP 범위 준비 (예: 192.168.100.240-192.168.100.250)
📌 2. Helm 저장소 추가 및 업데이트

```bash

helm repo add metallb https://metallb.github.io/metallb
helm repo update
```

📌 3. Namespace 생성

```bash
kubectl create namespace metallb-system
```

📌 4. Helm 차트를 사용한 MetalLB 설치

```bash
helm install metallb metallb/metallb -n metallb-system
```

✅ 설치 확인

````bash
kubectl get pods -n metallb-system
📌 5. MetalLB 설정 (Layer 2 모드)
🔖 ConfigMap 작성 (metallb-config.yaml)
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: my-ip-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.0.134-192.168.0.136
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: my-l2-advert
namespace: metallb-system
spec:
  # 사용할 ipAddressPools을 추가해주는 데 위에 정의한 ipAddressPools을 사용하도록 한다.
  ipAddressPools:
    - my-ip-pool
````

````
🚀 ConfigMap 적용
```bash
kubectl apply -f metallb-config.yaml
````

📌 6. LoadBalancer 타입 서비스 생성 예시
1️⃣ Nginx 배포 (nginx-deployment.yaml)

```yaml
복사
편집
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

2️⃣ Service 생성 (nginx-service.yaml)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

3️⃣ 적용

```bash
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
```

📌 7. 서비스 확인 및 테스트
✅ 서비스 확인

```bash
kubectl get services

plaintext
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
nginx-service   LoadBalancer   10.96.210.142   192.168.100.240  80:32007/TCP   2m
```

🌐 외부 IP 접속 테스트

```bash
curl http://192.168.100.240

또는 브라우저에서 접속: http://192.168.100.240
```

📌 8. 상용 환경에서의 고려 사항
IP 충돌 방지: DHCP 및 네트워크 장비와 IP 풀이 겹치지 않도록 설정
고가용성 (HA): MetalLB Speaker를 여러 노드에 배치
보안 설정: 네트워크 정책 (NetworkPolicy) 및 방화벽 설정
모니터링: Rancher UI 또는 Prometheus/Grafana 활용

💡 Tip:
Rancher UI에서도 Helm 차트를 사용해 설치 가능
Rancher UI → Apps & Marketplace → Chart Repositories → Add Repository
이름: metallb, URL: https://metallb.github.io/metallb
추가 후, Helm 차트에서 metallb 검색 및 설치
