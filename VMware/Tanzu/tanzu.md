멀티존 싱글 네임스페이스 화면
vsphere namespace 격리는 NSX-T 환경에서는 격리가 가능하나 분산 스위치 환경에서는 격리가 돼지 않아서 쿠버네티스 설정에서 변경 해야함
LB - NSX(4월까지), HA-Proxy, NSX-ALB
CSI 드라이버 볼륨 : RWO(read write Once), RWX(Read Write Many) 하이퍼바이저 데이터 스토어 접근 가능 ( RWO 만 가능) vSAN, NAS = RWX 가능
RWO 단일 Pod 엑세스 = 단일 워커로드, RWX 여러 Pod 동시 엑세스 가능 = 여러 워커노드
TKG = 커스터마이징 안함, VMware = Ubuntu, Photon 만 가능
tkgm(?)
CNI = Antrea 권장
L7 = ingreess L4 = LB
CONTOUR = controller, \*\*\*\*envoy가 필요!!!
fluentbit = tkg 로그 수집 가능 aria logs 활용
