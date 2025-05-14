```bash
PW8024F#show running-config
!Current Configuration:
!System Description "Powerconnect 8024F, 3.1.4.5, VxWorks 6.5"
!System Software Version 3.1.4.5
!
configure
vlan database
vlan  10,30
exit
hostname "PW8024F"
ip address 192.168.0.251 255.255.255.0
ip domain-name baynex.local
ip name-server 192.168.0.44
ip routing
interface vlan 10
routing
ip address  172.168.100.100  255.255.255.0
exit
interface vlan 30
routing
ip address  192.168.30.200  255.255.255.0
exit


username "admin" password ec2f14ca4b09a90aeffc35efe55b6bce level 1 encrypted
ip ssh pubkey-auth
iscsi cos vpt 5
!
interface ethernet 1/xg1
switchport access vlan 10
exit
!
interface ethernet 1/xg2
switchport access vlan 10
exit
!
interface ethernet 1/xg3
switchport access vlan 10
exit
!
interface ethernet 1/xg12
mtu 9216
exit
!
interface ethernet 1/xg13


switchport access vlan 30
exit
!
interface ethernet 1/xg14
switchport access vlan 30
exit
!
interface ethernet 1/xg15
switchport access vlan 30
exit
!
interface ethernet 1/xg16
mtu 9216
exit
!
interface ethernet 1/xg17
mtu 9216
exit
!
interface ethernet 1/xg18
mtu 9216


exit
!
interface ethernet 1/xg19
mtu 9216
exit
!
interface ethernet 1/xg20
mtu 9216
exit
!
interface ethernet 1/xg22
switchport access vlan 30
exit
exit

PW8024F#show interfaces status

Port   Type                            Duplex  Speed    Neg  Link  Flow Control
                                                             State Status
-----  ------------------------------  ------  -------  ---- ----- ------------
1/xg1  10G - Level                     Full    10000    Off  Up     Active
1/xg2  10G - Level                     Full    10000    Off  Up     Active
1/xg3  10G - Level                     Full    10000    Off  Up     Active
1/xg4  10G - Level                     N/A     Unknown  Auto Down   Inactive
1/xg5  10G - Level                     N/A     Unknown  Auto Down   Inactive
1/xg6  10G - Level                     Full    10000    Off  Down   Inactive
1/xg7  10G - Level                     Full    10000    Off  Up     Active
1/xg8  10G - Level                     Full    10000    Off  Up     Active
1/xg9  10G - Level                     Full    10000    Off  Up     Active
1/xg10 10G - Level                     Full    10000    Off  Down   Inactive
1/xg11 10G - Level                     Full    10000    Off  Down   Inactive
1/xg12 10G - Level                     Full    10000    Off  Up     Active
1/xg13 10G - Level                     Full    10000    Off  Up     Active
1/xg14 10G - Level                     Full    10000    Off  Up     Active
1/xg15 10G - Level                     Full    10000    Off  Up     Active
1/xg16 10G - Level                     Full    10000    Off  Up     Active
1/xg17 10G - Level                     Full    10000    Off  Up     Active
1/xg18 10G - Level                     Full    10000    Off  Up     Active
1/xg19 10G - Level                     Full    10000    Off  Up     Active
--More-- or (q)uit
1/xg20 10G - Level                     Full    10000    Off  Up     Active
1/xg21 10G - Level                     N/A     Unknown  Auto Down   Inactive
1/xg22 10G - Level                     Full    100      Auto Up     Active
1/xg23 10G - Level                     Full    100      Auto Up     Active
1/xg24 10G - Level                     Full    1000     Auto Up     Inactive


Oob  Type                            Link
                                     State
---  ------------------------------  -----
oob  Out-Of-Band                     Down


Ch   Type                            Link
                                     State
---  ------------------------------  -----
ch1  Link Aggregate                  Down
ch2  Link Aggregate                  Down
ch3  Link Aggregate                  Down
ch4  Link Aggregate                  Down
ch5  Link Aggregate                  Down
ch6  Link Aggregate                  Down
ch7  Link Aggregate                  Down
--More-- or (q)uit
ch8  Link Aggregate                  Down
ch9  Link Aggregate                  Down
ch10 Link Aggregate                  Down
ch11 Link Aggregate                  Down
ch12 Link Aggregate                  Down

Flow Control:Enabled


PW8024F#show vlan

VLAN       Name                         Ports          Type      Authorization
-----  ---------------                  -------------  -----     -------------
1      Default                          ch1-12,        Default   Required
                                        1/xg4-1/xg12,
                                        1/xg16-1/xg21,
                                        1/xg23-1/xg24
10                                      1/xg1-1/xg3    Static    Required
30                                      1/xg13-1/xg15, Static    Required
                                        1/xg22

interface range ethernet 1/xg1-1/xg3
description 12F_Frontend_172.168.100.x

interface range ethernet 1/xg13-1/xg15
description 12F_Workload_192.168.30.x



PW8024F#show interfaces description

Port    Description
-----   ----------------------------------------------------------------------
1/xg1   12F_Frontend_172.168.100.x
1/xg2   12F_Frontend_172.168.100.x
1/xg3   12F_Frontend_172.168.100.x
1/xg4
1/xg5
1/xg6
1/xg7
1/xg8
1/xg9
1/xg10
1/xg11
1/xg12  11F_reqeust_joo_storagetest250508
1/xg13  12F_Workload_192.168.30.x
1/xg14  12F_Workload_192.168.30.x
1/xg15  12F_Workload_192.168.30.x
1/xg16  hpe_main_b10k_iscsi(gfs)
1/xg17  hpe_main_b10k_iscsi(gfs)
1/xg18  hpe_main_vmehost01~03_10g
1/xg19  hpe_main_vmehost01~03_10g
1/xg20  hpe_main_vmehost01~03_10g
--More-- or (q)uit
1/xg21
1/xg22  UP_LINK_192.168.30.1
1/xg23
1/xg24





```
