helm upgrade nextcloud nextcloud/nextcloud \
 --version 6.6.6\
 --install \
 --namespace nextcloud \
 --create-namespace \
 --set ingress.enabled=true \
 --set ingress.annotations."cert-manager\.io/cluster-issuer"="letsencrypt-prod" \
 --set ingress.tls[0].hosts[0]="nextcloud.baynex.kr" \
 --set ingress.tls[0].secretName="nextcloud.baynex.kr-tls" \
 --set nextcloud.host="nextcloud.baynex.kr" \
 --set nextcloud.username=admin \
 --set nextcloud.password=changeme \
 --set service.type=NodePort \
 --set service.nodePort=30000 \
 --set mariadb.enabled=true \
 --set mariadb.primary.persistence.enabled=true \
 --set mariadb.primary.persistence.storageClass=ceph-block \
 --set persistence.enabled=true \
 --set persistence.storageClass=ceph-block
