CentOS에 Docker Engine 설치
CentOS에서 Docker Engine을 시작하려면 필수 구성 요소를 충족 하는지 확인한 다음 설치 단계를 따르세요 .

필수 조건
OS 요구 사항
Docker Engine을 설치하려면 다음 CentOS 버전 중 하나의 유지 관리된 버전이 필요합니다.

CentOS 9 (스트림)
저장소 centos-extras를 활성화해야 합니다. 이 저장소는 기본적으로 활성화되어 있습니다. 비활성화한 경우 다시 활성화해야 합니다.

이전 버전 제거
Docker Engine을 설치하기 전에 충돌하는 모든 패키지를 제거해야 합니다.

귀하의 Linux 배포판은 Docker에서 제공하는 공식 패키지와 충돌할 수 있는 비공식 Docker 패키지를 제공할 수 있습니다. Docker Engine의 공식 버전을 설치하기 전에 이러한 패키지를 제거해야 합니다.

```bash
 sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

dnf이러한 패키지가 하나도 설치되지 않았다고 보고할 수 있습니다.

/var/lib/docker/Docker를 제거해 도 이미지, 컨테이너, 볼륨 및 네트워크는 자동으로 제거되지 않습니다.

설치 방법
사용자의 요구 사항에 따라 Docker Engine을 다양한 방법으로 설치할 수 있습니다.

설치 및 업그레이드 작업을 쉽게 하기 위해 Docker의 저장소를 설정 하고 이를 통해 설치할 수 있습니다 . 이는 권장되는 접근 방식입니다.

RPM 패키지를 다운로드하고, 수동으로 설치하고 , 업그레이드를 완전히 수동으로 관리할 수 있습니다. 이는 인터넷에 접속할 수 없는 에어갭 시스템에 Docker를 설치하는 것과 같은 상황에서 유용합니다.

테스트 및 개발 환경에서는 자동화된 편의 스크립트를 사용하여 Docker를 설치할 수 있습니다.

rpm 저장소를 사용하여 설치
새 호스트 머신에 처음으로 Docker Engine을 설치하기 전에 Docker 저장소를 설정해야 합니다. 그런 다음 저장소에서 Docker를 설치하고 업데이트할 수 있습니다.

저장소 설정
패키지 를 설치합니다 dnf-plugins-core(DNF 저장소를 관리하는 명령을 제공합니다) 그리고 저장소를 설정합니다.

```bash
 sudo dnf -y install dnf-plugins-core
 sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

Docker 엔진 설치
Docker 패키지를 설치합니다.

최신 특정 버전
최신 버전을 설치하려면 다음을 실행하세요.

```bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

GPG 키 수락 메시지가 표시되면 지문이 일치하는지 확인하고 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35, 일치하면 수락합니다.

이 명령은 Docker를 설치하지만 Docker를 시작하지는 않습니다. 또한 docker그룹을 생성하지만 기본적으로 그룹에 사용자를 추가하지 않습니다.

Docker Engine을 시작합니다.

```bash
sudo systemctl enable --now docker
```

이렇게 하면 Docker systemd 서비스가 시스템을 부팅할 때 자동으로 시작되도록 구성합니다. Docker가 자동으로 시작되는 것을 원하지 않으면 sudo systemctl start docker대신 를 사용합니다.

이미지를 실행하여 설치가 성공적으로 완료되었는지 확인하세요 hello-world.

# 유저권한 주고 실행

```bash
sudo usermod -aG docker admin

docker run hello-world
```

이 명령은 테스트 이미지를 다운로드하여 컨테이너에서 실행합니다. 컨테이너가 실행되면 확인 메시지를 인쇄하고 종료합니다.

이제 Docker Engine을 성공적으로 설치하고 시작했습니다.

팁

루트 없이 실행하려고 하면 오류가 발생합니까?

사용자 docker그룹은 존재하지만 사용자를 포함하지 않으므로 Docker 명령을 실행하려면 를 사용해야 합니다 sudo. 권한이 없는 사용자가 Docker 명령을 실행하고 다른 선택적 구성 단계를 수행하려면 Linux postinstall 을 계속합니다.

Docker 엔진 업그레이드
Docker Engine을 업그레이드하려면 설치 지침 에 따라 설치하려는 새 버전을 선택하세요.

패키지에서 설치
rpmDocker의 저장소를 사용하여 Docker Engine을 설치할 수 없는 경우 .rpm릴리스용 파일을 다운로드하여 수동으로 설치할 수 있습니다. Docker Engine을 업그레이드할 때마다 새 파일을 다운로드해야 합니다.

https://download.docker.com/linux/centos/ 로 가서 CentOS 버전을 선택하세요. 그런 다음 설치하려는 Docker 버전에 대한 파일을 찾아서 x86_64/stable/Packages/ 다운로드하세요 ..rpm

Docker 패키지를 다운로드한 경로로 다음 경로를 변경하여 Docker Engine을 설치합니다.

```bash
sudo dnf install /path/to/package.rpm
```

Docker가 설치되었지만 시작되지 않았습니다. docker그룹은 생성되었지만 그룹에 사용자가 추가되지 않았습니다.

Docker Engine을 시작합니다.

```bash
sudo systemctl enable --now docker
```

이렇게 하면 Docker systemd 서비스가 시스템을 부팅할 때 자동으로 시작되도록 구성합니다. Docker가 자동으로 시작되는 것을 원하지 않으면 sudo systemctl start docker대신 를 사용합니다.

이미지를 실행하여 설치가 성공적으로 완료되었는지 확인하세요 hello-world.

```bash
sudo docker run hello-world
```

이 명령은 테스트 이미지를 다운로드하여 컨테이너에서 실행합니다. 컨테이너가 실행되면 확인 메시지를 인쇄하고 종료합니다.

이제 Docker Engine을 성공적으로 설치하고 시작했습니다.

팁

루트 없이 실행하려고 하면 오류가 발생합니까?

사용자 docker그룹은 존재하지만 사용자를 포함하지 않으므로 Docker 명령을 실행하려면 를 사용해야 합니다 sudo. 권한이 없는 사용자가 Docker 명령을 실행하고 다른 선택적 구성 단계를 수행하려면 Linux postinstall 을 계속합니다.

Docker 엔진 업그레이드
Docker Engine을 업그레이드하려면 최신 패키지 파일을 다운로드하고 대신 를 사용하여 설치 절차를 반복 하고 새 파일을 가리키세요.dnf upgradednf install

편의 스크립트를 사용하여 설치
Docker는 https://get.docker.com/ 에서 Docker를 비대화형으로 개발 환경에 설치하는 편의 스크립트를 제공합니다 . 편의 스크립트는 프로덕션 환경에는 권장되지 않지만, 필요에 맞게 조정된 프로비저닝 스크립트를 만드는 데 유용합니다. 또한 패키지 리포지토리를 사용하여 설치 하는 설치 단계에 대해 알아보려면 리포지토리를 사용하여 설치하는 단계를 참조하세요. 스크립트의 소스 코드는 오픈 소스이며 docker-installGitHub의 리포지토리 에서 찾을 수 있습니다 .

로컬에서 실행하기 전에 인터넷에서 다운로드한 스크립트를 항상 검토하세요. 설치하기 전에 편의 스크립트의 잠재적 위험과 제한 사항을 숙지하세요.

스크립트를 실행하려면 root또는 권한이 필요합니다.sudo
스크립트는 사용자의 Linux 배포판과 버전을 감지하고 패키지 관리 시스템을 구성하려고 시도합니다.
이 스크립트를 사용하면 대부분의 설치 매개변수를 사용자 정의할 수 없습니다.
스크립트는 확인을 요청하지 않고 종속성과 권장 사항을 설치합니다. 호스트 머신의 현재 구성에 따라 많은 수의 패키지를 설치할 수 있습니다.
기본적으로 스크립트는 Docker, containerd 및 runc의 최신 안정 릴리스를 설치합니다. 이 스크립트를 사용하여 머신을 프로비저닝하는 경우 Docker의 예상치 못한 주요 버전 업그레이드가 발생할 수 있습니다. 프로덕션 시스템에 배포하기 전에 항상 테스트 환경에서 업그레이드를 테스트하세요.
스크립트는 기존 Docker 설치를 업그레이드하도록 설계되지 않았습니다. 스크립트를 사용하여 기존 설치를 업데이트할 때 종속성이 예상 버전으로 업데이트되지 않아 오래된 버전이 생성될 수 있습니다.
팁

실행하기 전에 스크립트 단계를 미리 봅니다. 스크립트를 실행하면 --dry-run호출 시 스크립트가 실행할 단계를 알아볼 수 있는 옵션이 있습니다.

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh --dry-run
```

이 예제에서는 https://get.docker.com/ 에서 스크립트를 다운로드 하고 이를 실행하여 Linux에 Docker의 최신 안정 릴리스를 설치합니다.

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Executing docker install script, commit: 7cae5f8b0decc17d6571f9f52eb840fbc13b2737

<...>
이제 Docker Engine을 성공적으로 설치하고 시작했습니다. docker 서비스는 Debian 기반 배포판에서 자동으로 시작됩니다. RPMCentOS, Fedora, RHEL 또는 SLES와 같은 기반 배포판에서는 적절한 systemctl또는 service명령을 사용하여 수동으로 시작해야 합니다. 메시지에서 알 수 있듯이 루트가 아닌 사용자는 기본적으로 Docker 명령을 실행할 수 없습니다.

권한이 없는 사용자로 Docker를 사용하거나 루트리스 모드로 설치하시겠습니까?

설치 스크립트는 Docker를 설치하고 사용하기 위해 root또는 sudo권한이 필요합니다. 루트가 아닌 사용자에게 Docker에 대한 액세스 권한을 부여하려면 Linux의 설치 후 단계를 참조하세요 . 권한 없이 Docker를 설치하거나 루트리스 모드에서 실행하도록 구성할 수도 있습니다 . 루트리스 모드에서 Docker를 실행하는 방법에 대한 지침은 루트가 아닌 사용자로 Docker 데몬 실행(루트리스 모드)을root 참조하세요 .

사전 릴리스 설치
Docker는 또한 Linux에서 Docker의 사전 릴리스를 설치하기 위한 편의 스크립트를 https://test.docker.com/get.docker.com 에서 제공합니다. 이 스크립트는 의 스크립트와 동일 하지만 패키지 관리자가 Docker 패키지 저장소의 테스트 채널을 사용하도록 구성합니다. 테스트 채널에는 Docker의 안정 버전과 사전 릴리스(베타 버전, 릴리스 후보)가 모두 포함됩니다. 이 스크립트를 사용하여 새 릴리스에 조기에 액세스하고 안정적으로 릴리스되기 전에 테스트 환경에서 평가하세요.

테스트 채널에서 Linux에 Docker의 최신 버전을 설치하려면 다음을 실행하세요.

```bash
curl -fsSL https://test.docker.com -o test-docker.sh
sudo sh test-docker.sh
```

편의 스크립트 사용 후 Docker 업그레이드
편의 스크립트를 사용하여 Docker를 설치한 경우 패키지 관리자를 직접 사용하여 Docker를 업그레이드해야 합니다. 편의 스크립트를 다시 실행하는 데는 이점이 없습니다. 다시 실행하면 호스트 머신에 이미 있는 리포지토리를 다시 설치하려고 하면 문제가 발생할 수 있습니다.

Docker Engine 제거
Docker Engine, CLI, containerd 및 Docker Compose 패키지를 제거합니다.

```bash
sudo dnf remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
```

호스트의 이미지, 컨테이너, 볼륨 또는 사용자 지정 구성 파일은 자동으로 제거되지 않습니다. 모든 이미지, 컨테이너 및 볼륨을 삭제하려면:

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo dnf remove runc
sudo dnf -y install dnf-plugins-core


sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

# docker zabbix install

```bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo yum install -y git

sudo systemctl enable --now docker

sudo usermod -aG docker zabbix
```

# Zabbix Git clone

git clone https://github.com/zabbix/zabbix-docker.git

vi /home/admin/zabbix-docker/env_vars/.env_srv

# config 수정!!!!!

ZBX_STARTVMWARECOLLECTORS=3
ZBX_VMWAREFREQUENCY=60
ZBX_VMWAREPERFFREQUENCY=60
ZBX_VMWARECACHESIZE=64M
ZBX_VMWARETIMEOUT=10

docker compose -f ./docker-compose_v3_alpine_mysql_latest.yaml up

cat docker-compose_v3_alpine_mysql_latest.yaml

```bash
1. mysql 컨테이너 접속

docker exec -it zabbix-docker-mysql-server-1 mysql -uzabbix -pzabbix zabbix

2. docker 컨테이너 삭제
docker rm -f $(docker ps -a -q --filter "name=zabbix-")

```

UPDATE users SET passwd = '$2a$10$ZXIvHAEP2ZM.dLXTm6uPHOMVlARXX7cqjbhM6Fn0cANzkCQBWpMrS' WHERE username = 'Admin';

docker exec -it zabbix-docker-mysql-server-1 /bin/bash

# ESXI HOST UUID 설정 확인

vim-cmd hostsvc/hostsummary | grep uuid

```

```
