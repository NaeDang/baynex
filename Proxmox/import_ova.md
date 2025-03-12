OVA 파일이 있으면 VM을 직접 설치하고 구성하는 데 드는 시간을 절약할 수 있습니다. 이 글에서는 OVA를 Proxmox로 가져오는 모든 단계를 설명했습니다.

전체 Proxmox 코스 링크는 다음과 같습니다.

OVA 파일이란?
OVA 파일 또는 OVA 확장자를 가진 파일은 Open Virtual Appliance로 알려져 있으며, Oracle Virtual Box나 VMWare와 같은 가상화 플랫폼으로 가져올 수 있는 준비된 가상 머신(VM)의 아카이브 형식을 의미합니다.

이 파일에는 VMDK 파일이 있는 Archive 형식으로 OVF가 포함되어 있습니다. OVF는 설명자 XML 기반 파일입니다. 이 Archive에는 ISO 또는 기타 관련 리소스 파일도 포함될 수 있습니다.

OVA 아카이브에는 OVF와 VMDK가 포함됩니다.

OVA를 Proxmox로 가져오는 단계별 가이드.
여기에서는 OVF 파일이 필요하지 않지만 가상 디스크인 VMDK가 필요합니다. Proxmox에서 VM의 가상 디스크로 사용할 디스크가 필요합니다.

입력해야 할 명령은 두세 가지가 있습니다.

추가 OVA 파일
VM 설정 가져오기
VMDK를 VM으로 가져오기
아래는 OVA를 Proxmox로 가져오는 데 도움이 되는 단계별 가이드입니다.

1단계: 소스에서 OVA 파일을 다운로드합니다.
제 경우에는 OpenPPM OVA 프로덕션 파일을 다운로드했습니다.

2단계: Proxmox에 OVA 파일 업로드
WinSCP를 사용하여 파일을 모든 디렉토리에 업로드할 수 있습니다. 저는 이미 다운로드했습니다.

제 경우에는 루트 디렉토리의 ova_import 폴더에 이 파일을 업로드했습니다. 필요한 디렉토리를 선택했는지 확인하세요.

3단계: Proxmox Server에서 OVA 파일 추출
SSH를 사용하여 proxmox 서버에 로그인합니다. 저는 putty를 사용할 것입니다. 폴더를 찾아서 파일을 추출한 동일한 위치로 정확히 옮기세요. 아래 튜토리얼에서는 이러한 모든 단계를 자세히 설명했습니다.

다음 명령을 사용하여 추출합니다(파일 이름을 .ova로 변경해야 함)

OVA 파일 추출
tar xvf openppm.ova
xvf는 extract –verbose –file을 의미합니다. 여기서 x는 아카이브 추출을 의미하고, v는 Verbose 정보를 표시하고, f는 파일 이름을 지정하는 것을 의미합니다.

4단계: Proxmox로 VM 설정 가져오기
Proxmox에서 직접 VM을 만들 수도 있지만, 이 명령을 사용하면 필요한 구성으로 Proxmox에 VM이 자동으로 생성됩니다.

추출된 OVA에 두 개의 파일이 들어 있는 것을 볼 수 있습니다. 하나는 VM의 구성을 포함하는 OVF이고 다른 하나는 Disk입니다.

먼저, 구성 파일을 사용하여 VM을 생성하겠습니다.

SSH에서 아래 명령을 사용하세요

Vm 설정(OVF) 파일 가져오기
qm importovf 137 ./openppm.ovf proxthin --format qcow2
한 가지 방법은 직접 VM을 만드는 것입니다.

5단계: VM 디스크(VMDK)를 가상 머신(VM)으로 가져오기
마지막으로 VMDK를 내 가상 머신으로 가져올 것입니다. VM 번호는 136이므로 아래 명령을 사용합니다.

가상 머신으로 디스크 가져오기
qm importdisk 136 openppm.vmdk local-lvm -format qcow2
위 명령에 대한 설명은 다음과 같습니다.

qm : QEMU의 약자로 Quick Emulator를 의미합니다.

importdisk : 디스크를 가져오는 데 사용되는 명령

136 – Proxmox의 VM ID는 1단계에 따라 내가 만든 새 머신입니다.

Udemy의 Proxmox 코스
openppm.vmdk 3단계에서 추출된 VMDK 파일 이름

local-lvm: 내 설치의 LVM 볼륨의 저장소 이름입니다. 사용자의 설치 이름을 사용할 수 있습니다.

– format : 디스크의 포맷

qcow2 : 가상 디스크의 저장 형식. QCOW는 QEMU copy-on-write의 약자입니다. QCOW2 형식은 논리적 블록과 물리적 블록 간의 매핑을 추가하여 물리적 저장 계층을 가상 계층에서 분리합니다.

6단계: VM에 디스크 추가
디스크가 VM에 추가되었지만 아직 VM에 추가되거나 연결되지 않은 것을 알 수 있습니다.

이것을 클릭하여 추가하세요.

7단계: VM 시작
이제 VM을 시작하세요. 위의 모든 단계를 따르면 VM이 확실히 작동할 것입니다.

8단계: 가상 네트워크 인터페이스 추가
VM의 하드웨어 섹션에서 하드웨어를 추가하고 네트워크 카드를 연결해야 합니다. VM의 네트워크 설정을 변경해야 할 수도 있습니다. VM의 운영 체제에 따라 구성해야 합니다.

9단계: 전체 과정에 참여하세요
Proxmox Udemy 코스는 다음과 같습니다.
