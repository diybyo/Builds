# feb/20/2022 09:54:41 by RouterOS 6.49.2
# software id = J2MY-PRRA
#
# model = RouterBOARD 941-2nD
# serial number = 846108FD9EAC
/interface bridge
add fast-forward=no name=bridge1-home
add fast-forward=no name=bridge2-hotspot
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-onlyn country=philippines disabled=\
    no frequency=2462 mode=ap-bridge ssid=DIYFi wireless-protocol=802.11 \
    wps-mode=disabled
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip hotspot profile
set [ find default=yes ] dns-name=diy.wifi hotspot-address=10.0.0.1 \
    html-directory=flash/hs login-by=\
    mac,cookie,http-chap,http-pap,trial,mac-cookie
add dns-name=diy.wifi hotspot-address=10.0.0.1 html-directory=flash/hs \
    login-by=mac,cookie,http-chap,http-pap,trial,mac-cookie name=hsprof1 \
    trial-uptime-limit=3m
/ip hotspot user profile
set [ find default=yes ] on-login="{:local a [/ip hotspot user get [find name=\
    \$user] limit-uptime]; :local validity 01:00:00; :local c (\$a+\$validity)\
    ; /system scheduler add interval=\$c name=\$user on-event=\"/ip hotspot us\
    er remove [find name=\$user]; /ip hotspot active remove [find user=\$user]\
    ; /ip hotspot cookie remove [find user=\$user]; /queue simple remove [find\
    \_name=\$user]; /system sche remove [find name=\$user]\" policy=ftp,reboot\
    ,read,write,policy,test,password,sniff,sensitive,romon;\r\
    \n}\r\
    \n\r\
    \n/queue simple add max-limit=2M/2M name=\"\$user\" \\ target=\$address pa\
    rent=HS" rate-limit=2M shared-users=unlimited
add name=RATE1 on-login=":local voucher \$user;\r\
    \n:local uptime [/ip hotspot user get \$user limit-uptime];\r\
    \n:if ([/system scheduler find name=\$voucher]=\"\") do={/system scheduler\
    \_add comment=\$voucher name=\$voucher interval=1d on-event=\"/ip hotspot \
    active remove [find user=\$voucher]\\r\\n/ip hotspot user remove [find nam\
    e=\$voucher]\\r\\n/system schedule remove [find name=\$voucher]\"}"
add name=RATE2 on-login=":local voucher \$user;\r\
    \n:local uptime [/ip hotspot user get \$user limit-uptime];\r\
    \n:if ([/system scheduler find name=\$voucher]=\"\") do={/system scheduler\
    \_add comment=\$voucher name=\$voucher interval=1d on-event=\"/ip hotspot \
    active remove [find user=\$voucher]\\r\\n/ip hotspot user remove [find nam\
    e=\$voucher]\\r\\n/system schedule remove [find name=\$voucher]\"}"
add name=RATE3 on-login=":local voucher \$user;\r\
    \n:local uptime [/ip hotspot user get \$user limit-uptime];\r\
    \n:if ([/system scheduler find name=\$voucher]=\"\") do={/system scheduler\
    \_add comment=\$voucher name=\$voucher interval=1d on-event=\"/ip hotspot \
    active remove [find user=\$voucher]\\r\\n/ip hotspot user remove [find nam\
    e=\$voucher]\\r\\n/system schedule remove [find name=\$voucher]\"}"
add name=RATE4 on-login=":local voucher \$user;\r\
    \n:local uptime [/ip hotspot user get \$user limit-uptime];\r\
    \n:if ([/system scheduler find name=\$voucher]=\"\") do={/system scheduler\
    \_add comment=\$voucher name=\$voucher interval=1d on-event=\"/ip hotspot \
    active remove [find user=\$voucher]\\r\\n/ip hotspot user remove [find nam\
    e=\$voucher]\\r\\n/system schedule remove [find name=\$voucher]\"}"
add name=RATE5 on-login=":local voucher \$user;\r\
    \n:local uptime [/ip hotspot user get \$user limit-uptime];\r\
    \n:if ([/system scheduler find name=\$voucher]=\"\") do={/system scheduler\
    \_add comment=\$voucher name=\$voucher interval=1d on-event=\"/ip hotspot \
    active remove [find user=\$voucher]\\r\\n/ip hotspot user remove [find nam\
    e=\$voucher]\\r\\n/system schedule remove [find name=\$voucher]\"}"
add name=RATE6 on-login=":local voucher \$user;\r\
    \n:local uptime [/ip hotspot user get \$user limit-uptime];\r\
    \n:if ([/system scheduler find name=\$voucher]=\"\") do={/system scheduler\
    \_add comment=\$voucher name=\$voucher interval=1d on-event=\"/ip hotspot \
    active remove [find user=\$voucher]\\r\\n/ip hotspot user remove [find nam\
    e=\$voucher]\\r\\n/system schedule remove [find name=\$voucher]\"}"
/ip pool
add comment=home name=pool-home ranges=168.10.0.5-192.168.10.254
add comment=hotspot name=pool-hotspot ranges=10.0.0.5-10.0.0.254
/ip dhcp-server
add address-pool=pool-home disabled=no interface=ether2 name=server-home
add address-pool=pool-hotspot disabled=no interface=bridge2-hotspot name=\
    server-hotspot
/ip hotspot
add address-pool=pool-hotspot disabled=no interface=bridge2-hotspot name=\
    hotspot1 profile=hsprof1
/queue type
add kind=pcq name=PCQ pcq-classifier=dst-address pcq-dst-address-mask=24 \
    pcq-dst-address6-mask=64 pcq-limit=16KiB pcq-src-address-mask=24 \
    pcq-src-address6-mask=64 pcq-total-limit=640KiB
add kind=pcq name=PCQ-1M pcq-classifier=dst-address pcq-dst-address-mask=24 \
    pcq-dst-address6-mask=64 pcq-limit=16KiB pcq-rate=1M \
    pcq-src-address-mask=24 pcq-src-address6-mask=64 pcq-total-limit=640KiB
add kind=pcq name=PCQ-2M pcq-classifier=dst-address pcq-dst-address-mask=24 \
    pcq-dst-address6-mask=64 pcq-limit=15KiB pcq-rate=2M \
    pcq-src-address-mask=24 pcq-src-address6-mask=64 pcq-total-limit=640KiB
add kind=pcq name=PCQ-512k pcq-classifier=dst-address pcq-dst-address-mask=24 \
    pcq-dst-address6-mask=64 pcq-limit=16KiB pcq-rate=512k \
    pcq-src-address-mask=24 pcq-src-address6-mask=64 pcq-total-limit=640KiB
/interface bridge port
add bridge=bridge2-hotspot interface=wlan1
/ip address
add address=192.168.10.1/24 interface=ether2 network=192.168.10.0
add address=10.0.0.1/20 interface=bridge2-hotspot network=10.0.0.0
/ip cloud
set ddns-enabled=yes update-time=no
/ip dhcp-client
add disabled=no interface=ether1
/ip dhcp-server network
add address=10.0.0.0/20 comment=hotspot gateway=10.0.0.1
add address=192.168.10.0/24 comment=home gateway=192.168.10.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4
/ip firewall filter
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=fasttrack-connection chain=forward comment="Mobile legend games" \
    dst-port=5051,30100-30110,5500-5510,7275,5220-5230,32250 protocol=tcp
add action=fasttrack-connection chain=forward dst-port=5001-5100,5353,5552 \
    protocol=udp
add action=fasttrack-connection chain=forward comment="ROS game" dst-port=\
    7000,8913,10003,30000-30150,5001-5059,5101-5105,9001,5501-5559,5601-5651 \
    protocol=udp
add action=fasttrack-connection chain=forward comment=DNS dst-port=53 \
    protocol=udp
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
/ip firewall nat
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=masquerade chain=srcnat out-interface=ether1
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    src-address=10.0.0.0/24
/ip hotspot ip-binding
add mac-address=10:52:1C:66:58:80 server=hotspot1 type=bypassed
/ip hotspot user
add comment=LocalClient name=dbb6sr password=dbb6sr profile=RATE1 server=\
    hotspot1
/ip hotspot walled-garden
add comment="place hotspot rules here" disabled=yes
/ip hotspot walled-garden ip
add action=accept disabled=no dst-address=10.0.0.250 !dst-address-list \
    !dst-port !protocol !src-address !src-address-list
/system clock
set time-zone-autodetect=no time-zone-name=Asia/Manila
/system identity
set name=DIYFi
/system logging
add action=disk prefix=-> topics=hotspot,info,debug
/system ntp client
set enabled=yes primary-ntp=103.38.215.205 secondary-ntp=133.243.238.163 \
    server-dns-names=asia.pool.ntp.org
