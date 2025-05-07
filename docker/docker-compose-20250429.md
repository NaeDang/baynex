```yaml
cat docker-compose.yml
version: "2.32"
services:
  mnx_api:
    image: mnx-api-v23:develop
    environment:
      - TZ=Asia/Seoul
      - JASYPT_PASSWORD=Toswm#0501
      - TI_PATH_CTX_TOTAL_PATH=https://test.api.ctx.io/
      - SPRING_PROFILES_ACTIVE=1g
      - SPRING_APPLICATION_JSON={"logging.level.root":"WARN"}
      - UNIX_MNX_SOCKET_MODULE_VERSION=2025012101
    restart: unless-stopped
    ports:
      - "8443:8443"
    logging:
      driver: "none"
    volumes:
       - /application:/application
       - /logs:/logs
       - /etc/hostname:/etc/hostname:ro
       - /var/run:/var/run
       - /pipeline/raw:/pipeline/raw:ro
       - /data/raw:/data/raw:ro
    network_mode: host
    container_name: mnx_api_server
```

```yaml
[admin@localhost zabbix-docker]$ cat docker-compose_v3_alpine_mysql_latest.yaml
services:
 server-db-init:
  extends:
   file: compose_zabbix_components.yaml
   service: server-mysql-db-init
  image: "${ZABBIX_SERVER_MYSQL_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  volumes:
   - /etc/timezone:/etc/timezone:ro
  depends_on:
   mysql-server:
    condition: service_started
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 proxy-db-init:
  extends:
   file: compose_zabbix_components.yaml
   service: proxy-mysql-db-init
  image: "${ZABBIX_PROXY_MYSQL_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  volumes:
   - /etc/timezone:/etc/timezone:ro
  depends_on:
   mysql-server:
    condition: service_started
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-server:
  extends:
   file: compose_zabbix_components.yaml
   service: server-mysql
  image: "${ZABBIX_SERVER_MYSQL_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  volumes:
   - /etc/timezone:/etc/timezone:ro
  depends_on:
   server-db-init:
    condition: service_completed_successfully
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-proxy-sqlite3:
  extends:
   file: compose_zabbix_components.yaml
   service: proxy-sqlite3
  image: "${ZABBIX_PROXY_SQLITE3_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  volumes:
   - /etc/timezone:/etc/timezone:ro
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-proxy-mysql:
  extends:
   file: compose_zabbix_components.yaml
   service: proxy-mysql
  image: "${ZABBIX_PROXY_MYSQL_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  volumes:
   - /etc/timezone:/etc/timezone:ro
  depends_on:
   proxy-db-init:
    condition: service_completed_successfully
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-web-apache-mysql:
  extends:
   file: compose_zabbix_components.yaml
   service: web-apache-mysql
  image: "${ZABBIX_WEB_APACHE_MYSQL_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  volumes:
   - /etc/timezone:/etc/timezone:ro
  depends_on:
   server-db-init:
    condition: service_completed_successfully
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-web-nginx-mysql:
  extends:
   file: compose_zabbix_components.yaml
   service: web-nginx-mysql
  image: "${ZABBIX_WEB_NGINX_MYSQL_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  volumes:
   - /etc/timezone:/etc/timezone:ro
  depends_on:
   server-db-init:
    condition: service_completed_successfully
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-agent:
  extends:
   file: compose_zabbix_components.yaml
   service: agent
  image: "${ZABBIX_AGENT_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  volumes:
   - /etc/timezone:/etc/timezone:ro
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-java-gateway:
  extends:
   file: compose_zabbix_components.yaml
   service: java-gateway
  image: "${ZABBIX_JAVA_GATEWAY_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-snmptraps:
  extends:
   file: compose_zabbix_components.yaml
   service: snmptraps
  image: "${ZABBIX_SNMPTRAPS_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 zabbix-web-service:
  extends:
   file: compose_zabbix_components.yaml
   service: web-service
  image: "${ZABBIX_WEB_SERVICE_IMAGE}:${ZABBIX_ALPINE_IMAGE_TAG}${ZABBIX_IMAGE_TAG_POSTFIX}"
  labels:
   com.zabbix.os: "${ALPINE_OS_TAG}"

 mysql-server:
  extends:
   file: compose_databases.yaml
   service: mysql-server

 db-data-mysql:
  extends:
   file: compose_databases.yaml
   service: db-data-mysql

 elasticsearch:
  extends:
   file: compose_databases.yaml
   service: elasticsearch

 selenium:
  extends:
   file: compose_additional_components.yaml
   service: selenium

 selenium-chrome:
  platform: linux/amd64
  extends:
   file: compose_additional_components.yaml
   service: selenium-chrome

 selenium-firefox:
  extends:
   file: compose_additional_components.yaml
   service: selenium-firefox

networks:
  frontend:
    driver: bridge
    enable_ipv6: "${FRONTEND_ENABLE_IPV6}"
    ipam:
      driver: "${FRONTEND_NETWORK_DRIVER}"
      config:
      - subnet: "${FRONTEND_SUBNET}"
  backend:
    driver: bridge
    enable_ipv6: "${BACKEND_ENABLE_IPV6}"
    internal: true
    ipam:
      driver: "${BACKEND_NETWORK_DRIVER}"
      config:
      - subnet: "${BACKEND_SUBNET}"
  database:
    driver: bridge
    enable_ipv6: "${DATABASE_NETWORK_ENABLE_IPV6}"
    internal: true
    ipam:
      driver: "${DATABASE_NETWORK_DRIVER}"
  tools_frontend:
    driver: bridge
    enable_ipv6: "${ADD_TOOLS_ENABLE_IPV6}"
    ipam:
      driver: "${ADD_TOOLS_NETWORK_DRIVER}"
      config:
      - subnet: "${ADD_TOOLS_SUBNET}"

volumes:
  snmptraps:
#  mysql_socket:

secrets:
  MYSQL_USER:
    file: ${ENV_VARS_DIRECTORY}/.MYSQL_USER
  MYSQL_PASSWORD:
    file: ${ENV_VARS_DIRECTORY}/.MYSQL_PASSWORD
  MYSQL_ROOT_USER:
    file: ${ENV_VARS_DIRECTORY}/.MYSQL_ROOT_USER
  MYSQL_ROOT_PASSWORD:
    file: ${ENV_VARS_DIRECTORY}/.MYSQL_ROOT_PASSWORD
#  client-key.pem:
#    file: ${ENV_VARS_DIRECTORY}/.ZBX_DB_KEY_FILE
#  client-cert.pem:
#    file: ${ENV_VARS_DIRECTORY}/.ZBX_DB_CERT_FILE
#  root-ca.pem:
#    file: ${ENV_VARS_DIRECTORY}/.ZBX_DB_CA_FILE
#  server-cert.pem:
#    file: ${ENV_VARS_DIRECTORY}/.DB_CERT_FILE
#  server-key.pem:
#    file: ${ENV_VARS_DIRECTORY}/.DB_KEY_FILE
```

```yaml
[admin@localhost zabbix-docker]$ cat compose_zabbix_components.yaml
services:
 server:
  init: true
  ports:
   - name: zabbix-trapper
     target: 10051
     published: "${ZABBIX_SERVER_PORT}"
     protocol: tcp
     app_protocol: zabbix-trapper
  restart: "${RESTART_POLICY}"
  attach: true
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - ${DATA_DIRECTORY}/usr/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts:ro
   - ${DATA_DIRECTORY}/usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscripts:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/export:/var/lib/zabbix/export:rw
   - ${DATA_DIRECTORY}/var/lib/zabbix/modules:/var/lib/zabbix/modules:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssh_keys:/var/lib/zabbix/ssh_keys:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/mibs:/var/lib/zabbix/mibs:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssl/certs:/var/lib/zabbix/ssl/certs:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssl/keys:/var/lib/zabbix/ssl/keys:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssl/ssl_ca:/var/lib/zabbix/ssl/ssl_ca:rw
   - snmptraps:/var/lib/zabbix/snmptraps:roz
  tmpfs: /tmp
  ulimits:
   nproc: 65535
   nofile:
    soft: 20000
    hard: 40000
  deploy:
   resources:
    limits:
      cpus: '0.70'
      memory: 1G
    reservations:
      cpus: '0.5'
      memory: 512M
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_srv
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_srv_override
     required: false
  networks:
   database:
     aliases:
      - zabbix-server
   backend:
     aliases:
      - zabbix-server
   frontend:
   tools_frontend:
#  devices:
#   - "/dev/ttyUSB0:/dev/ttyUSB0"
  stop_grace_period: 30s
#  cap_add:
#    - "NET_RAW"
  sysctls:
   - net.ipv4.ip_local_port_range=1024 64999
   - net.ipv4.conf.all.accept_redirects=0
   - net.ipv4.conf.all.secure_redirects=0
   - net.ipv4.conf.all.send_redirects=0
#   - net.ipv4.ping_group_range=0 1995
  labels:
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "server"

 server-mysql-db-init:
  init: true
  attach: true
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/dbscripts:/var/lib/zabbix/dbscripts:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
#   - mysql_socket:/var/run/mysqld/
  command: init_db_only
  tmpfs: /tmp
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_mysql
     required: true
  secrets:
   - MYSQL_USER
   - MYSQL_PASSWORD
#   - client-key.pem
#   - client-cert.pem
#   - root-ca.pem
  networks:
   database:
     aliases:
      - zabbix-server-mysql-init
  labels:
   com.zabbix.description: "Zabbix server with MySQL database support (database init)"
   com.zabbix.dbtype: "mysql"

 server-pgsql-db-init:
  init: true
  attach: true
  volumes:
   - ${DATA_DIRECTORY}/var/lib/zabbix/dbscripts:/var/lib/zabbix/dbscripts:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_CA_FILE:/run/secrets/root-ca.pem:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_CERT_FILE:/run/secrets/client-cert.pem:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_KEY_FILE:/run/secrets/client-key.pem:ro
#   - pgsql_socket:/var/run/postgresql
  command: init_db_only
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_pgsql
     required: true
  secrets:
   - POSTGRES_USER
   - POSTGRES_PASSWORD
  networks:
   database:
     aliases:
      - zabbix-server-pgsql-init
  labels:
   com.zabbix.description: "Zabbix server with PostgreSQL database support (database init)"
   com.zabbix.dbtype: "pgsql"

 server-mysql:
  extends:
   service: server
#  volumes:
#   - mysql_socket:/var/run/mysqld/
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_mysql
     required: true
  secrets:
   - MYSQL_USER
   - MYSQL_PASSWORD
#   - client-key.pem
#   - client-cert.pem
#   - root-ca.pem
  networks:
   backend:
     aliases:
      - zabbix-server-mysql
  labels:
   com.zabbix.description: "Zabbix server with MySQL database support"
   com.zabbix.dbtype: "mysql"

 server-pgsql:
  extends:
   service: server
#  volumes:
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_CA_FILE:/run/secrets/root-ca.pem:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_CERT_FILE:/run/secrets/client-cert.pem:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_KEY_FILE:/run/secrets/client-key.pem:ro
#   - pgsql_socket:/var/run/postgresql
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_pgsql
     required: true
  secrets:
   - POSTGRES_USER
   - POSTGRES_PASSWORD
  networks:
   backend:
     aliases:
      - zabbix-server-pgsql
  labels:
   com.zabbix.description: "Zabbix server with PostgreSQL database support"
   com.zabbix.dbtype: "pgsql"

 proxy:
  init: true
  profiles:
   - all
  restart: "${RESTART_POLICY}"
  attach: false
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - ${DATA_DIRECTORY}/usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscripts:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/modules:/var/lib/zabbix/modules:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssh_keys:/var/lib/zabbix/ssh_keys:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/mibs:/var/lib/zabbix/mibs:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssl/certs:/var/lib/zabbix/ssl/certs:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssl/keys:/var/lib/zabbix/ssl/keys:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssl/ssl_ca:/var/lib/zabbix/ssl/ssl_ca:rw
   - snmptraps:/var/lib/zabbix/snmptraps:ro
  tmpfs: /tmp
  ulimits:
   nproc: 65535
   nofile:
    soft: 20000
    hard: 40000
  deploy:
   resources:
    limits:
      cpus: '0.70'
      memory: 512M
    reservations:
      cpus: '0.3'
      memory: 256M
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_prx
     required: true
  networks:
   backend:
   frontend:
   tools_frontend:
  stop_grace_period: 30s
#  cap_add:
#    - "NET_RAW"
  sysctls:
   - net.ipv4.ip_local_port_range=1024 64999
   - net.ipv4.conf.all.accept_redirects=0
   - net.ipv4.conf.all.secure_redirects=0
   - net.ipv4.conf.all.send_redirects=0
#   - net.ipv4.ping_group_range=0 1995
  labels:
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "proxy"

 proxy-sqlite3:
  extends:
   service: proxy
  ports:
   - name: zabbix-trapper
     target: 10051
     published: "${ZABBIX_PROXY_SQLITE3_PORT}"
     protocol: tcp
     app_protocol: zabbix-trapper
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_prx_sqlite3
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_prx_sqlite3_override
     required: false
  networks:
   backend:
    aliases:
     - zabbix-proxy-sqlite3
  labels:
   com.zabbix.description: "Zabbix proxy with SQLite3 database support"
   com.zabbix.dbtype: "sqlite3"

 proxy-mysql-db-init:
  init: true
  profiles:
   - all
  attach: true
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
#   - mysql_socket:/var/run/mysqld/
  command: init_db_only
  tmpfs: /tmp
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_mysql_proxy
     required: true
  secrets:
   - MYSQL_USER
   - MYSQL_PASSWORD
#   - client-key.pem
#   - client-cert.pem
#   - root-ca.pem
  networks:
   database:
     aliases:
      - zabbix-proxy-mysql-init
  labels:
   com.zabbix.description: "Zabbix proxy with MySQL database support (database init)"
   com.zabbix.dbtype: "mysql"

 proxy-mysql:
  extends:
   service: proxy
  ports:
   - name: zabbix-trapper
     target: 10051
     published: "${ZABBIX_PROXY_MYSQL_PORT}"
     protocol: tcp
     app_protocol: zabbix-trapper
#  volumes:
#   - mysql_socket:/var/run/mysqld/
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_mysql_proxy
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_prx_mysql
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_prx_mysql_override
     required: false
  secrets:
   - MYSQL_USER
   - MYSQL_PASSWORD
#   - client-key.pem
#   - client-cert.pem
#   - root-ca.pem
  networks:
   database:
     aliases:
      - zabbix-proxy-mysql
   backend:
    aliases:
     - zabbix-proxy-mysql
  labels:
   com.zabbix.description: "Zabbix proxy with MySQL database support"
   com.zabbix.dbtype: "mysql"

 web-apache:
  profiles:
   - all
  ports:
   - name: web-http
     target: 8080
     published: "${ZABBIX_WEB_APACHE_HTTP_PORT}"
     protocol: tcp
     app_protocol: http
   - name: web-https
     target: 8443
     published: "${ZABBIX_WEB_APACHE_HTTPS_PORT}"
     protocol: tcp
     app_protocol: https
  restart: "${RESTART_POLICY}"
  attach: false
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - ${DATA_DIRECTORY}/etc/ssl/apache2:/etc/ssl/apache2:ro
   - ${DATA_DIRECTORY}/usr/share/zabbix/modules/:/usr/share/zabbix/modules/:ro
  tmpfs:
   - /tmp
   - /var/lib/php/session:mode=770,uid=1997,gid=1995
  deploy:
   resources:
    limits:
      cpus: '0.70'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_web
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_web_override
     required: false
  healthcheck:
   test: ["CMD", "curl", "-f", "http://localhost:8080/ping"]
   interval: 1m30s
   timeout: 3s
   retries: 3
   start_period: 40s
   start_interval: 5s
  networks:
   database:
   backend:
   frontend:
  stop_grace_period: 10s
  sysctls:
   - net.core.somaxconn=65535
  labels:
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "frontend"
   com.zabbix.webserver: "apache2"

 web-apache-mysql:
  extends:
   service: web-apache
#  volumes:
#   - mysql_socket:/var/run/mysqld/
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_mysql
     required: true
  secrets:
   - MYSQL_USER
   - MYSQL_PASSWORD
#   - client-key.pem
#   - client-cert.pem
#   - root-ca.pem
  labels:
   com.zabbix.description: "Zabbix frontend on Apache web-server with MySQL database support"
   com.zabbix.dbtype: "mysql"

 web-apache-pgsql:
  extends:
   service: web-apache
#  volumes:
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_CA_FILE:/run/secrets/root-ca.pem:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_CERT_FILE:/run/secrets/client-cert.pem:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_KEY_FILE:/run/secrets/client-key.pem:ro
#   - pgsql_socket:/var/run/postgresql
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_pgsql
     required: true
  secrets:
   - POSTGRES_USER
   - POSTGRES_PASSWORD
  networks:
   backend:
    aliases:
     - zabbix-web-apache-pgsql
  labels:
   com.zabbix.description: "Zabbix frontend on Apache web-server with PostgreSQL database support"
   com.zabbix.dbtype: "pgsql"

 web-nginx:
  ports:
   - name: web-http
     target: 8080
     published: "${ZABBIX_WEB_NGINX_HTTP_PORT}"
     protocol: tcp
     app_protocol: http
   - name: web-https
     target: 8443
     published: "${ZABBIX_WEB_NGINX_HTTPS_PORT}"
     protocol: tcp
     app_protocol: https
  restart: "${RESTART_POLICY}"
  attach: false
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - ${DATA_DIRECTORY}/etc/ssl/nginx:/etc/ssl/nginx:ro
   - ${DATA_DIRECTORY}/usr/share/zabbix/modules/:/usr/share/zabbix/modules/:ro
  tmpfs:
   - /tmp
   - /var/lib/php/session:mode=770,uid=1997,gid=1995
  deploy:
   resources:
    limits:
      cpus: '0.70'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_web
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_web_override
     required: false
  healthcheck:
   test: ["CMD", "curl", "-f", "http://localhost:8080/ping"]
   interval: 1m30s
   timeout: 3s
   retries: 3
   start_period: 40s
   start_interval: 5s
  networks:
   database:
   backend:
   frontend:
  stop_grace_period: 10s
  sysctls:
   - net.core.somaxconn=65535
  labels:
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "frontend"
   com.zabbix.webserver: "nginx"

 web-nginx-mysql:
  extends:
   service: web-nginx
#  volumes:
#   - mysql_socket:/var/run/mysqld/
  env_file:
   - ${ENV_VARS_DIRECTORY}/.env_db_mysql
  secrets:
   - MYSQL_USER
   - MYSQL_PASSWORD
#   - client-key.pem
#   - client-cert.pem
#   - root-ca.pem
  networks:
   backend:
    aliases:
     - zabbix-web-nginx-mysql
  labels:
   com.zabbix.description: "Zabbix frontend on Nginx web-server with MySQL database support"
   com.zabbix.dbtype: "mysql"

 web-nginx-pgsql:
  extends:
   service: web-nginx
#  volumes:
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_CA_FILE:/run/secrets/root-ca.pem:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_CERT_FILE:/run/secrets/client-cert.pem:ro
#   - ${ENV_VARS_DIRECTORY}/.ZBX_DB_KEY_FILE:/run/secrets/client-key.pem:ro
#   - pgsql_socket:/var/run/postgresql
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_db_pgsql
     required: true
  secrets:
   - POSTGRES_USER
   - POSTGRES_PASSWORD
  networks:
   backend:
    aliases:
     - zabbix-web-nginx-pgsql
  labels:
   com.zabbix.description: "Zabbix frontend on Nginx web-server with PostgreSQL database support"
   com.zabbix.dbtype: "pgsql"

 agent:
  init: true
  profiles:
   - full
   - all
  ports:
   - name: zabbix-agent
     target: 10050
     published: "${ZABBIX_AGENT_PORT}"
     protocol: tcp
     app_protocol: zabbix-agent
  restart: "${RESTART_POLICY}"
  attach: false
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - ${DATA_DIRECTORY}/etc/zabbix/zabbix_agentd.d:/etc/zabbix/zabbix_agentd.d:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/modules:/var/lib/zabbix/modules:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssh_keys:/var/lib/zabbix/ssh_keys:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/user_scripts:/var/lib/zabbix/user_scripts:ro
  tmpfs: /tmp
  deploy:
   resources:
    limits:
      cpus: '0.2'
      memory: 128M
    reservations:
      cpus: '0.1'
      memory: 64M
   mode: global
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_agent
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_agent_override
     required: false
  privileged: true
  pid: "host"
  networks:
   backend:
    aliases:
     - zabbix-agent
     - zabbix-agent-passive
  stop_grace_period: 5s
  labels:
   com.zabbix.description: "Zabbix agent"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "agent"

 agent2:
  init: true
  profiles:
   - full
   - all
  ports:
   - name: zabbix-agent
     target: 10050
     published: "${ZABBIX_AGENT2_PORT}"
     protocol: tcp
     app_protocol: zabbix-agent
   - name: zabbix-agent-status
     target: 31999
     published: "${ZABBIX_AGENT2_STATUS_PORT}"
     protocol: tcp
  restart: "${RESTART_POLICY}"
  attach: false
  volumes:
   - /etc/localtime:/etc/localtime:ro
   - ${DATA_DIRECTORY}/etc/zabbix/zabbix_agentd.d:/etc/zabbix/zabbix_agentd.d:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/modules:/var/lib/zabbix/modules:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/ssh_keys:/var/lib/zabbix/ssh_keys:ro
   - ${DATA_DIRECTORY}/var/lib/zabbix/user_scripts:/var/lib/zabbix/user_scripts:ro
  tmpfs: /tmp
  deploy:
   resources:
    limits:
      cpus: '0.2'
      memory: 128M
    reservations:
      cpus: '0.1'
      memory: 64M
   mode: global
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_agent
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_agent_override
     required: false
  privileged: true
  pid: "host"
  networks:
   backend:
    aliases:
     - zabbix-agent
     - zabbix-agent-passive
  stop_grace_period: 5s
  labels:
   com.zabbix.description: "Zabbix agent 2"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "agent2"

 java-gateway:
  profiles:
   - full
   - all
  ports:
   - name: zabbix-java-gw
     target: 10052
     published: "${ZABBIX_JAVA_GATEWAY_PORT}"
     protocol: tcp
  restart: "${RESTART_POLICY}"
  attach: false
  volumes:
   - ${DATA_DIRECTORY}/usr/sbin/zabbix_java/ext_lib:/usr/sbin/zabbix_java/ext_lib:ro
  deploy:
   resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_java
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_java_override
     required: false
  networks:
   backend:
    aliases:
     - zabbix-java-gateway
   frontend:
  stop_grace_period: 5s
  labels:
   com.zabbix.description: "Zabbix Java Gateway"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "java-gateway"

 snmptraps:
# Override snmptrapd command arguments to receive SNMP traps by DNS
# It must be done with ZBX_SNMP_TRAP_USE_DNS=true environment variable
#  command: /usr/sbin/snmptrapd -t -X -C -c /etc/snmp/snmptrapd.conf -Lo -A --doNotFork=yes --agentuser=zabbix --agentgroup=zabbix
  profiles:
   - full
   - all
  ports:
   - name: snmptrap
     target: 1162
     published: "${ZABBIX_SNMPTRAPS_PORT}"
     protocol: udp
     app_protocol: snmptrap
  restart: "${RESTART_POLICY}"
  attach: false
  read_only: true
  volumes:
   - snmptraps:/var/lib/zabbix/snmptraps:rwz
   - ${DATA_DIRECTORY}/var/lib/zabbix/snmptrapd_config:/var/lib/zabbix/snmptrapd_config:rw
  tmpfs: /tmp
  deploy:
   resources:
    limits:
      cpus: '0.5'
      memory: 256M
    reservations:
      cpus: '0.25'
      memory: 128M
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_snmptraps
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_snmptraps_override
     required: false
  networks:
   frontend:
    aliases:
     - zabbix-snmptraps
   backend:
  stop_grace_period: 5s
  labels:
   com.zabbix.description: "Zabbix snmptraps"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "snmptraps"

 web-service:
  profiles:
   - full
   - all
  ports:
   - name: zabbix-web-service
     target: 10053
     published: "${ZABBIX_WEB_SERVICE_PORT}"
     protocol: tcp
  restart: "${RESTART_POLICY}"
  attach: false
  read_only: true
  volumes:
   - ${DATA_DIRECTORY}/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
  tmpfs: /tmp
  security_opt:
   - seccomp:${ENV_VARS_DIRECTORY}/chrome_dp.json
  deploy:
   resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
  env_file:
   - path: ${ENV_VARS_DIRECTORY}/.env_web_service
     required: true
   - path: ${ENV_VARS_DIRECTORY}/.env_web_service_override
     required: false
  networks:
   backend:
    aliases:
     - zabbix-web-service
  stop_grace_period: 5s
  labels:
   com.zabbix.description: "Zabbix web service"
   com.zabbix.company: "Zabbix SIA"
   com.zabbix.component: "web-service"
```
