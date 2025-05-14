# 🚩 1단계: 디렉터리 준비

작업 디렉터리를 생성하고 해당 경로로 이동합니다.

```bash
mkdir prometheus-grafana
cd prometheus-grafana
```

# 🚩 2단계: 설정 파일 준비

아래와 같이 설정 파일들을 생성합니다.

prometheus.yml

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']

  - job_name: 'node-exporters'
    static_configs:
      - targets:
          - '192.168.0.26:9100'
          - '192.168.0.248:9100'

  - job_name: 'cadvisor'
    static_configs:
      - targets:
          - '192.168.0.26:8080'
          - '192.168.0.248:8090'
```

ubuntu@tanzu-ubuntu:~/prometheus-grafana$ cat telegraf.conf

telegraf.conf

```bash
[agent]
  interval = "60s"
  round_interval = true
  omit_hostname = true

[[outputs.influxdb_v2]]
  urls = ["http://influxdb:8086"]
  token = "mytoken"                  # <- DOCKER_INFLUXDB_INIT_ADMIN_TOKEN 값과 동일해야 함
  organization = "myorg"            # <- DOCKER_INFLUXDB_INIT_ORG 값
  bucket = "vsphere"                # <- DOCKER_INFLUXDB_INIT_BUCKET 값

[[inputs.vsphere]]
  interval = "60s"
  vcenters = [ "https://192.168.0.100/sdk" ]
  username = "administrator@vsphere.local"
  password = "VMware1!"

  insecure_skip_verify = true
  force_discover_on_init = true
  max_query_metrics = 256

  # Exclude all historical metrics
  datastore_metric_exclude = []
  cluster_metric_exclude = []
  datacenter_metric_exclude = []
  resource_pool_metric_exclude = ["*"]
  host_metric_exclude = []
  vm_metric_exclude = []

  collect_concurrency = 5
  discover_concurrency = 5
```

위 설정은 Prometheus 자기 자신을 모니터링하도록 합니다. 추가로 다른 타겟을 모니터링하려면 targets에 추가하면 됩니다.

# 🚩 3단계: Docker Compose 설정

아래의 내용을 docker-compose.yaml로 저장합니다.

```yaml
version: '3.8'

services:
  influxdb:
    image: influxdb:2.7
    container_name: influxdb
    ports:
      - '8086:8086'
    volumes:
      - influxdb-data:/var/lib/influxdb2
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=admin
      - DOCKER_INFLUXDB_INIT_PASSWORD=adminpass
      - DOCKER_INFLUXDB_INIT_ORG=myorg
      - DOCKER_INFLUXDB_INIT_BUCKET=vsphere
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=mytoken

  telegraf:
    image: telegraf:1.25
    container_name: telegraf
    volumes:
      - ./telegraf.conf:/etc/telegraf/telegraf.conf:ro
    depends_on:
      - influxdb
    restart: always

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - '3000:3000'
    volumes:
      - grafana-data:/var/lib/grafana
    depends_on:
      - influxdb

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - '9090:9090'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    restart: always

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - '8080:8080'
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: always

volumes:
  influxdb-data:
  grafana-data:
```

# 🚩 4단계: 컨테이너 실행

Docker Compose를 통해 컨테이너를 실행합니다.

```bash
docker-compose up -d
docker-compose ps
```

# 🚩 5단계: Grafana 구성 및 데이터 소스 연동

브라우저에서 Grafana 접속:
http://localhost:3000

기본 계정은 다음과 같습니다.

```bash
ID: admin
Password: admin
```

최초 로그인 시 비밀번호 변경을 요구합니다.

왼쪽 메뉴에서 Configuration → Data sources → Add data source 선택.

Prometheus 선택.

URL에 Prometheus의 주소 입력:

http://prometheus:9090
Save & Test 버튼 클릭하여 연결 확인.

InfluxDB 선택

URL에 InfluxDB의 주소 입력:
http://InflxDB:8086

Basic Auth → OFF

Skip TLS Verify → ON (https 사용 시에만)

항목 설정값 예시
Organization | myorg | (InfluxDB에서 생성한 조직 이름)
Token | mytoken | (InfluxDB에서 생성된 API 토큰)
Default | Bucket vsphere | (Telegraf가 쓰는 bucket 이름)

Save & Test 버튼 클릭하여 연결 확인.

# 🚩 6단계: Grafana 대시보드 추가하기

Grafana에서 바로 사용할 수 있는 Prometheus 대시보드 예제:

Dashboards → Browse → Import

Grafana 공식 예제 ID 1860, 10619 입력 후 Load 클릭.(Node Exporters, cadvisor) : 서버 모니터링, 컨테이너 모니터링

데이터 소스를 아까 추가한 Prometheus로 선택하고 Import 진행.

Grafana에서 바로 사용할 수 있는 InfluxDB, Telegraf 대시보드 예제:

Dashboards → Browse → Import

Grafana 공식 예제 ID 8159, 8162, 8165 입력 후 Load 클릭 (vSphere-HOST, Overview, Datastore).

데이터 소스를 아까 추가한 InfulxDB를 선택하고 Import 진행.

### 서버 연동 방법

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz

tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
cd node_exporter-1.8.1.linux-amd64
sudo cp node_exporter /usr/local/bin/

# 서비스로 실행 (Systemd 등록)

sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Node Exporter 서비스 시작

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

# Prometheus와 Grafana에 Docker 컨테이너 모니터링 대시보드를 추가

📌 요약 (한눈에 보기)
단계 작업 핵심 내용
1 cAdvisor 설치 docker-compose에 추가
2 Prometheus 설정 prometheus.yml에 job 추가
3 Prometheus 재기동 docker-compose restart prometheus
4 Grafana 대시보드 추가 Dashboard ID: 10619
5 Grafana 데이터 확인 변수 설정 및 데이터 확인

# cAdvisor 설치 방법 (Docker Compose 추가)

현재 사용중인 docker-compose.yaml 파일에 아래 내용을 추가합니다.
docker-compose.yaml

```yaml (192.168.0.26)
services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - '8080:8080'
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: always
```

docker-compose.yaml

```yaml (192.168.0.248)
services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - '8080:8090'
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: always
```

위 서비스 정의를 기존의 docker-compose.yaml 파일 내 services 부분에 추가합니다.

```bash
docker-compose up -d cadvisor
```

cAdvisor는 8080포트를 사용하며, 이 포트가 이미 사용 중이라면 다른 포트로 바꿔도 됩니다.

# 2단계: Prometheus에 cAdvisor 설정 추가

기존 prometheus.yml 파일을 수정하여 cAdvisor의 데이터를 수집하도록 설정합니다.

```yaml
- job_name: 'cadvisor'
  static_configs:
    - targets:
        - '192.168.0.26:8080'
        - '192.168.0.248:8090'
```

기존 prometheus.yml에 다음 내용을 추가합니다.

중요: Docker Compose 환경에서는 컨테이너 이름을 그대로 사용하여 통신합니다. 여기서 cadvisor는 Docker 컨테이너의 이름입니다.

변경 후 Prometheus 컨테이너 재시작:

```bash
docker-compose restart prometheus
```

# 🚩 3단계: Prometheus에서 데이터 수집 확인

브라우저에서 아래 URL로 접속하여 cAdvisor의 데이터를 수집 중인지 확인합니다.

```bash
http://<prometheus_IP>:9090/targets
```

cadvisor 항목이 UP인지 반드시 확인합니다.

# 🚩 4단계: Grafana에서 Docker 대시보드 추가하기

Grafana 공식 Docker 대시보드를 가져와 설정합니다.

Grafana 접속:

```bash
http://<Grafana_IP>:3000
```

왼쪽 메뉴에서 Dashboards → Import 선택.
다음 ID를 입력 후 Load 클릭:
10619
(Docker Host & Container Overview)
Import 설정:
Datasource에서 기존의 prometheus 선택
이후 Import 버튼 클릭

# 🚩 5단계: Grafana에서 데이터 확인 및 변수 설정 확인

대시보드가 정상적으로 추가되면 Grafana 상단에서 변수를 확인하여 데이터를 정확히 필터링 합니다.

변수 예시:

Job: cadvisor 선택

Instance: cadvisor:8080 선택

## 그래프와 메트릭이 정상적으로 표시되는지 확인합니다.

--

# Server, docker, vsphere 통합 대시보드 모니터링 구성 정리

# 최종 docker compose.yaml

```yaml
version: '3.8'

services:
  influxdb:
    image: influxdb:2.7
    container_name: influxdb
    ports:
      - '8086:8086'
    volumes:
      - influxdb-data:/var/lib/influxdb2
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=admin
      - DOCKER_INFLUXDB_INIT_PASSWORD=adminpass
      - DOCKER_INFLUXDB_INIT_ORG=myorg
      - DOCKER_INFLUXDB_INIT_BUCKET=vsphere
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=mytoken

  telegraf:
    image: telegraf:1.25
    container_name: telegraf
    volumes:
      - ./telegraf.conf:/etc/telegraf/telegraf.conf:ro
    depends_on:
      - influxdb
    restart: always

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - '3000:3000'
    env_file:
      - .env
    environment:
      - GF_SMTP_PASSWORD_FILE=/run/secrets/smtp_password
    secrets:
      - smtp_password
    volumes:
      - grafana-data:/var/lib/grafana

    volumes:
      - grafana-data:/var/lib/grafana

    depends_on:
      - influxdb

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - '9090:9090'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    restart: always

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - '8080:8080'
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: always

volumes:
  influxdb-data:
  grafana-data:
secrets:
  smtp_password:
    file: ./secrets/smtp_password.txt
```

ubuntu@tanzu-ubuntu:~/prometheus-grafana$ cat docker-compose.yaml

```yaml
version: '3.8'

services:
  influxdb:
    image: influxdb:2.7
    container_name: influxdb
    ports:
      - '8086:8086'
    volumes:
      - influxdb-data:/var/lib/influxdb2
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=admin
      - DOCKER_INFLUXDB_INIT_PASSWORD=adminpass
      - DOCKER_INFLUXDB_INIT_ORG=myorg
      - DOCKER_INFLUXDB_INIT_BUCKET=vsphere
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=mytoken

  telegraf:
    image: telegraf:1.25
    container_name: telegraf
    volumes:
      - ./telegraf.conf:/etc/telegraf/telegraf.conf:ro
    depends_on:
      - influxdb
    restart: always

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - '3000:3000'
    volumes:
      - grafana-data:/var/lib/grafana
    depends_on:
      - influxdb

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - '9090:9090'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    restart: always

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - '8080:8080'
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: always

volumes:
  influxdb-data:
  grafana-data:
```

ubuntu@tanzu-ubuntu:~/prometheus-grafana$ cat prometheus.yml

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']

  - job_name: 'node-exporters'
    static_configs:
      - targets:
          - '192.168.0.26:9100'
          - '192.168.0.248:9100'

  - job_name: 'cadvisor'
    static_configs:
      - targets:
          - '192.168.0.26:8080'
          - '192.168.0.248:8090'
```

ubuntu@tanzu-ubuntu:~/prometheus-grafana$ cat telegraf.conf

```bash
[agent]
  interval = "60s"
  round_interval = true
  omit_hostname = true

[[outputs.influxdb_v2]]
  urls = ["http://influxdb:8086"]
  token = "mytoken"                  # <- DOCKER_INFLUXDB_INIT_ADMIN_TOKEN 값과 동일해야 함
  organization = "myorg"            # <- DOCKER_INFLUXDB_INIT_ORG 값
  bucket = "vsphere"                # <- DOCKER_INFLUXDB_INIT_BUCKET 값

[[inputs.vsphere]]
  interval = "60s"
  vcenters = [ "https://192.168.0.100/sdk" ]
  username = "administrator@vsphere.local"
  password = "VMware1!"

  insecure_skip_verify = true
  force_discover_on_init = true
  max_query_metrics = 256

  # Exclude all historical metrics
  datastore_metric_exclude = []
  cluster_metric_exclude = []
  datacenter_metric_exclude = []
  resource_pool_metric_exclude = ["*"]
  host_metric_exclude = []
  vm_metric_exclude = []

  collect_concurrency = 5
  discover_concurrency = 5
```

ubuntu@tanzu-ubuntu:~/prometheus-grafana$ cat .env

```bash

## SMTP 설정
GF_SMTP_ENABLED=true
GF_SMTP_HOST=smtp.office365.com:587
GF_SMTP_USER=jhshin@baynex.co.kr
GF_SMTP_FROM_ADDRESS=jhshin@baynex.co.kr
GF_SMTP_FROM_NAME=Grafana
GF_SMTP_SKIP_VERIFY=false

## Microsoft SSO (OIDC)
GF_AUTH_GENERIC_OAUTH_ENABLED=true
GF_AUTH_GENERIC_OAUTH_NAME=Microsoft
GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP=true
GF_AUTH_GENERIC_OAUTH_CLIENT_ID=46a6506c-f7ed-475c-ad85-87aed102b9e1
GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET=4060d369-6385-41e3-99cd-8c18d8779840
GF_AUTH_GENERIC_OAUTH_SCOPES=openid email profile
GF_AUTH_GENERIC_OAUTH_AUTH_URL=https://login.microsoftonline.com/a7ae2428-84d7-4291-a788-40b46d1e0316/oauth2/v2.0/authorize
GF_AUTH_GENERIC_OAUTH_TOKEN_URL=https://login.microsoftonline.com/a7ae2428-84d7-4291-a788-40b46d1e0316/oauth2/v2.0/token
GF_AUTH_GENERIC_OAUTH_API_URL=https://graph.microsoft.com/oidc/userinfo
GF_AUTH_SIGNOUT_REDIRECT_URL=https://login.microsoftonline.com/common/oauth2/logout
GF_SERVER_ROOT_URL=https://grafana.baynex.kr

# Grafana alert notification Webhook → Jira Webhook URL 사용
GF_ALERTING_ENABLED=true

```

ubuntu@tanzu-ubuntu:~/prometheus-grafana$ cat secrets/smtp_password.txt

```bash
orochi10!
```

# Troble shooting

1. Prometheus 연결 targets 확인 : http://192.168.0.26:9090/targets
2. Node Exporter 서비스 실행 중 확인 : systemctl status node_exporter
3. telegraf 확인 데이터가 정상적으로 들어 가는지 : docker logs -f telegraf
4. Grafana Explore를 통한 데이터 확인:

   - Prometheus : Bulider | Code 중 Code 선택
   - node_cpu_seconds_total

   - InfluxDB :
   - import "influxdata/influxdb/schema" schema.measurements(bucket: "vsphere") # : measurements 확인

```sql
from(bucket: "vsphere")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "vsphere_host_cpu")
  |> keep(columns: ["esxhostname"])
  |> distinct(column: "esxhostname")

from(bucket: "vsphere")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "vsphere_host_cpu")
  |> filter(fn: (r) => r._field == "usage_average")
  |> filter(fn: (r) => r["esxhostname"] == "192.168.0.21")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

5. Node Exporter 서비스 중 PSI 기능이 안되서 작동 대시보드 하나가 N/A 되었을 때

```bash
ls /proc/pressure/

ls: cannot access '/proc/pressure': No such file or directory
[admin@localhost ~]$ sudo ls /proc/pressure
```

🔍 PSI(Pressure Stall Information)란?
Linux 커널 4.20 이상부터 도입된 기능
/proc/pressure/cpu, /proc/pressure/memory, /proc/pressure/io 등의 경로로 노출
Node Exporter에서는 이 파일을 읽어 node*pressure*\* metric으로 Prometheus에 제공함

```bash
sudo cat /proc/cmdline
sudo grubby --update-kernel=ALL --args="psi=1"
sudo reboot
ls /proc/pressure
cpu  io  irq  memory
```
