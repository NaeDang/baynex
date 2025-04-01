
# 🚀 Kubernetes 핵심 개념 요약

## 📦 주요 리소스 개념

| 개념 | 설명 |
|------|------|
| **Pod** | 컨테이너의 최소 단위. 하나 이상의 컨테이너가 하나의 IP를 공유하며 함께 배포됨 |
| **Deployment** | Pod를 선언적으로 관리하는 리소스. 수량, 업데이트 전략 등을 자동화 |
| **Service (SVC)** | Pod들을 하나의 네트워크 엔드포인트로 묶는 가상 IP. Pod가 재시작되어도 안정된 접근 제공 |
| **PersistentVolume (PV)** | 실제 저장 공간 (Disk, Ceph 등). 클러스터 관리자에 의해 미리 정의됨 |
| **PersistentVolumeClaim (PVC)** | Pod가 필요로 하는 저장 공간 요청. PV와 매칭됨 (동적 또는 수동) |
| **Ingress** | HTTP/HTTPS 경로 기반 라우팅. 여러 서비스를 하나의 외부 IP로 접근 가능하게 해줌 |
| **Namespace** | 리소스를 논리적으로 구분하는 공간. 멀티팀, 멀티서비스 구분 시 사용 |

---

## 🌐 Service 타입별 네트워크 구성

| 타입 | 설명 | 외부 접근 가능 여부 |
|------|------|------------------|
| **ClusterIP** (기본) | 클러스터 내부에서만 접근 가능 | ❌ |
| **NodePort** | 노드의 고정 포트를 외부로 노출 (예: 노드IP:30080) | ✅ 단순 테스트용 |
| **LoadBalancer** | 외부 LoadBalancer (MetalLB, 클라우드 LB) 를 통해 접근 | ✅ 운영 환경 사용 |
| **ExternalName** | DNS alias 용도로 외부 서비스 이름 사용 | ✅ (특수한 경우) |

---

## 🔁 리소스 관계 흐름 요약

```
Ingress → Service → Pod (→ Container)
                       ↑
                   VolumeMount
                       ↑
                     PVC
                       ↑
                     PV
```

---

## 📌 실전 구성 예시: 웹 서비스

| 리소스 | 예시 |
|--------|------|
| Deployment | nginx 웹서버 3개 복제 |
| Pod | nginx 컨테이너 1개 포함 |
| Service | `nginx-svc` 이름으로 3개 Pod를 묶음 |
| Ingress | `example.com` 접근 시 `nginx-svc`로 라우팅 |
| PVC | `/var/www/html`에 5GiB 연결 요청 |
| PV | Rook-Ceph에서 자동 할당된 볼륨 |
| LoadBalancer IP | 100.100.100.251:443 → Ingress → 내부 Pod 연결 |

---

## ✅ 실무 팁

- **Pod는 직접 만들지 말고 Deployment 사용하기**
- **모든 통신은 Service를 통해 연결된다고 이해하기**
- **Ingress는 외부 HTTP/S 진입점**
- **PVC는 Pod에 연결되는 요청이고, PV는 실제 볼륨**
- **LoadBalancer는 외부 IP를 클러스터로 연결해줌**

---

## 🌐 Ingress-NGINX Controller란?

- Kubernetes 클러스터에서 **Ingress 리소스를 실제로 처리하는 컨트롤러**
- 클러스터 외부로부터 들어오는 HTTP/HTTPS 요청을 Ingress 정의에 따라 Service로 라우팅
- 보통 LoadBalancer나 NodePort로 노출되어 있으며, TLS(HTTPS) 종료 기능도 지원

### 🔁 구성 흐름

```
Client → LoadBalancer IP (ex: 100.100.100.251)
       → Ingress-NGINX Controller
       → Ingress Resource (Path/Host 기반 매핑)
       → ClusterIP Service
       → Pod
```

### ✅ 주요 기능

- Path, Host 기반 라우팅
- HTTPS TLS Termination (Secret 기반 인증서 사용)
- Rewrite, Redirect, Rate limit 등 다양한 정책 적용 가능
