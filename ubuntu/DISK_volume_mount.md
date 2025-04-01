# https://aeong-dev.tistory.com/11

# LVM 사용 (PV, VG, LV)

# https://nayoungs.tistory.com/entry/Linux-LVMLogical-Volume-Manage-PV-VG-LV

# 디스크 확인

sudo fdisk -l

```bash
ubuntu@rke-node:~$ sudo fdisk -l
Disk /dev/loop0: 63.97 MiB, 67080192 bytes, 131016 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop1: 87.04 MiB, 91267072 bytes, 178256 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop2: 38.83 MiB, 40714240 bytes, 79520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sda: 52.2 GiB, 56048484352 bytes, 109469696 sectors
Disk model: QEMU HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: E6B137D0-95DE-4C44-B5D1-1C74DE40F141

Device      Start       End   Sectors  Size Type
/dev/sda1  227328 109469662 109242335 52.1G Linux filesystem
/dev/sda14   2048     10239      8192    4M BIOS boot
/dev/sda15  10240    227327    217088  106M EFI System

Partition table entries are not in disk order.


Disk /dev/sdb: 200 GiB, 214748364800 bytes, 419430400 sectors
Disk model: QEMU HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

# 파티션 생성

```bash
ubuntu@rke-node:~$ sudo parted /dev/sdb
GNU Parted 3.4
Using /dev/sdb
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel gpt
(parted) unit GB
(parted) mkpart
Partition name?  []?
File system type?  [ext2]? ext4
Start? 0
End? 200
(parted) print
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sdb: 215GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End    Size   File system  Name  Flags
 1      0.00GB  200GB  200GB  ext4

(parted)
```

# 포맷하기

```bash
ubuntu@rke-node:~$ sudo mkfs -t ext4 /dev/sdb
mke2fs 1.46.5 (30-Dec-2021)
Found a gpt partition table in /dev/sdb
Proceed anyway? (y,N) y
Discarding device blocks: done
Creating filesystem with 52428800 4k blocks and 13107200 inodes
Filesystem UUID: 1036082a-5ecb-4b0a-b185-b5bbf0690a2e
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done
Writing inode tables: done
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done
```

# 디스크 마운트 하기

```bash
ubuntu@rke-node:~$ sudo mkdir /var/rancher
ubuntu@rke-node:~$ sudo mount /dev/sdb /var/rancher/
ubuntu@rke-node:~$ sudo chmod 777 /var/rancher/
```

# fstab 등록 (부팅시 없어짐 방지)

```bash
ubuntu@rke-node:~$ sudo vim /etc/fstab
--- vim
LABEL=cloudimg-rootfs   /        ext4   discard,errors=remount-ro       0 1
LABEL=UEFI      /boot/efi       vfat    umask=0077      0 1
/dev/sdb /var/rancher ext4 defaults 0 0

ubuntu@rke-node:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           1.6G  996K  1.6G   1% /run
/dev/sda1        51G  1.5G   49G   3% /
tmpfs           7.9G     0  7.9G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda15      105M  6.1M   99M   6% /boot/efi
tmpfs           1.6G  4.0K  1.6G   1% /run/user/1000
/dev/sdb        196G   28K  186G   1% /var/rancher
```
