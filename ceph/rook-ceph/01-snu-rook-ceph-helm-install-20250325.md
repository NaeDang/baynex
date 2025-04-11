# helm install rook-ceph

```bash
helm upgrade rook-ceph rook-release/rook-ceph \
  --version v1.16.5 \
  --install \
  --namespace rook-ceph \
  --create-namespace \
  --set enableDiscoveryDaemon=true \
  --set discoveryDaemonInterval=60m
```

```bash
helm upgrade rook-ceph-cluster rook-release/rook-ceph-cluster \
  --version v1.16.5 \
  --install \
  --namespace rook-ceph \
  --create-namespace \
  --set operatorNamespace="rook-ceph" \
  --set toolbox.enabled=true \
  --set cephClusterSpec.mgr.modules[0].name="rook" \
  --set cephClusterSpec.mgr.modules[0].enabled=true \
  --set cephClusterSpec.dashboard.ssl=false \
  --set cephClusterSpec.storage.useAllNodes=true \
  --set cephClusterSpec.storage.useAllDevices=true \
  --set cephClusterSpec.storage.deviceFilter="^sd." \
```

```bash
  --set ingress.dashboard.annotations."cert-manager\.io/cluster-issuer"="letsencrypt-prod" \
  --set ingress.dashboard.host.name="ceph.baynex.kr" \
  --set ingress.dashboard.host.path="/" \
  --set ingress.dashboard.tls[0].hosts[0]="ceph.baynex.kr" \
  --set ingress.dashboard.tls[0].secretName="ceph.baynex.kr-tls" \
  --set ingress.dashboard.ingressClassName="nginx"
```
