# 외장 하드 NTFS 파일 시스템 VM에 연결 하는 2가지 방법

0. 외장하드 HOST에 연결
1. PCI Pass-through
   - 설정 편집 호스트 USB 연결 - 외장하드 선택
2. RDM vmdk 파일 변환 후 연결
   - 해당 HOST에 /etc/init.d/usbarbitrator stop (VM 자동 인식 연결 해제)
   - ls -lh /vmfs/devices/disks
   - mpx.xxxx 확인
   - -rw------- 1 root root 1.8T Apr 18 07:21 mpx.vmhba36:C0:T0:L0

```bash
vmkfstools -z /vmfs/devices/disks/mpx.vmhba36:C0:T0:L0 /vmfs/volumes/20-Datastore-1-1TB/usbraw.vmdk
```

- vmdk 생기는 것 확인

```bash
ls -lh /vmfs/volumes/20-Datastore-1-1TB/
-rw-------    1 root     root        1.8T Apr 18 07:25 usbraw-rdmp.vmdk
-rw-------    1 root     root         476 Apr 18 07:25 usbraw.vmdk
```

- 해당 vmdk vm 설정편집에 기존 디스크로 연결
- 다 끝나면 /etc/init.d/usbarbitrator start 변경
