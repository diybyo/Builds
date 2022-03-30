# jan/25/2022 09:27:29 by RouterOS 6.49.2
# software id = SHI3-HRWD
#
# model = 960PGS
# serial number = AD8B0BC40210
/interface bridge
add name=BRIDGE-PORTAL
/interface ethernet
set [ find default-name=ether3 ] name=LAN1
set [ find default-name=ether4 ] name=LAN2
set [ find default-name=ether5 ] name=LAN3
set [ find default-name=ether1 ] comment=WAN1 name=WAN1
set [ find default-name=ether2 ] comment=WAN2 name=WAN2
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip hotspot profile
add dns-name=wifi.local hotspot-address=10.0.0.1 html-directory=flash/hs \
    login-by=mac,http-chap mac-auth-mode=mac-as-username-and-password name=\
    BRIDGE-PORTAL rate-limit=100M
/ip hotspot
add disabled=no idle-timeout=none interface=BRIDGE-PORTAL name=BRIDGE-PORTAL \
    profile=BRIDGE-PORTAL
/ip hotspot user profile
set [ find default=yes ] add-mac-cookie=no shared-users=2
/ip pool
add name=BRIDGE-PORTAL ranges=10.0.0.51-10.0.255.250
/ip dhcp-server
add address-pool=BRIDGE-PORTAL disabled=no interface=BRIDGE-PORTAL \
    lease-script=":local queueName \"\$\"lease-hostname\" -  \$leaseActMAC\";\
    \r\
    \n\r\
    \n:if (\$leaseBound = 1) do={\r\
    \n/queue simple add name=\$queueName target=(\$leaseActIP . \"/32\")  queu\
    e=\"PCQ/PCQ\" parent=BRIDGE-PORTAL priority=1/1;\r\
    \n} else={\r\
    \n/queue simple remove \$queueName\r\
    \n}\r\
    \n" lease-time=12h name=BRIDGE-PORTAL
/ip hotspot user profile
add add-mac-cookie=no address-pool=BRIDGE-PORTAL !idle-timeout \
    !keepalive-timeout !mac-cookie-timeout name=ClientWiFi on-login=":local un\
    ame \$user;\r\
    \n:local usercount 0;\r\
    \n:local usertime \"00:00:00\";\r\
    \n:local kickable;\r\
    \n:local maxuser 2;\r\
    \n\r\
    \n   :foreach i in=[/ip hotspot active find user=\$uname] do= {\r\
    \n      :local curup [/ip hotspot active get \$i uptime];\r\
    \n      :if ( \$curup >= \$usertime ) do={\r\
    \n         :set usertime \$curup;\r\
    \n         :set kickable \$i;\r\
    \n      }\r\
    \n      :set usercount (\$usercount+1);\r\
    \n   }\r\
    \n\r\
    \n   :log info \"\$uname = \$usercount\";\r\
    \n\r\
    \n   :if (\$usercount >= \$maxuser) do={\r\
    \n      :log info \"Login user: \$uname (\$usercount/\$maxuser) - Oldest \
    \$usertime will be logout!\";\r\
    \n      /ip hotspot active remove numbers=\$kickable;\r\
    \n   } ;\r\
    \n\r\
    \n\r\
    \n\r\
    \n" on-logout="\r\
    \n:log info \"Delete used account script executed\";\r\
    \n:foreach i in [/ip hotspot user find profile=\"ClientWiFi\"] do={\r\
    \n   :if ([/ip hotspot user get \$i uptime]>=[/ip hotspot user get \$i lim\
    it-uptime]) do={\r\
    \n      /ip hotspot user remove \$i;\r\
    \n   }\r\
    \n}\r\
    \n" rate-limit=100M shared-users=2
/queue simple
add max-limit=100M/100M name=BRIDGE-PORTAL packet-marks=mgt-pkt target=\
    BRIDGE-PORTAL
/interface bridge port
add bridge=BRIDGE-PORTAL interface=LAN1
add bridge=BRIDGE-PORTAL interface=LAN2
/ip address
add address=10.0.0.1/16 comment=BRIDGE-PORTAL interface=BRIDGE-PORTAL \
    network=10.0.0.0
/ip dhcp-client
add add-default-route=no comment=WAN1 disabled=no interface=WAN1 script="if (\
    \$bound=1) do={ \\\r\
    \n/ip route set [find comment=\"WAN1\"] gateway=\$\"gateway-address\"; \r\
    \n}" use-peer-dns=no
add add-default-route=no comment=WAN2 disabled=no interface=WAN2 script="if (\
    \$bound=1) do={ \\\r\
    \n/ip route set [find comment=\"WAN2\"] gateway=\$\"gateway-address\"; \r\
    \n}" use-peer-dns=no
/ip dhcp-server lease
add address=10.0.0.2 comment=DEVTB486A6AE114C mac-address=4C:11:AE:A6:86:B4 \
    server=BRIDGE-PORTAL
add address=10.0.255.248 comment=BUGSFC393005613C mac-address=\
    3C:61:05:30:39:FC server=BRIDGE-PORTAL
add address=10.0.0.67 comment=DEVT5CB5D1BF713C mac-address=3C:71:BF:D1:B5:5C \
    server=BRIDGE-PORTAL
add address=10.0.0.59 comment=DEVT8058661C5210 mac-address=10:52:1C:66:58:80 \
    server=BRIDGE-PORTAL
add address=10.0.0.57 comment=DEVT30AA0C05613C mac-address=3C:61:05:0C:AA:30 \
    server=BRIDGE-PORTAL
/ip dhcp-server network
add address=10.0.0.0/16 comment=BRIDGE-PORTAL gateway=10.0.0.1
/ip dns
set allow-remote-requests=yes servers=10.0.0.1,8.8.8.8,8.8.4.4
/ip firewall filter
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
/ip firewall mangle
add action=mark-connection chain=input comment=WAN1-INPUT in-interface=WAN1 \
    new-connection-mark=WAN1 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=WAN1 \
    new-routing-mark=to-WAN1 passthrough=yes
add action=mark-connection chain=input comment=WAN2-INPUT in-interface=WAN2 \
    new-connection-mark=WAN2 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=WAN2 \
    new-routing-mark=to-WAN2 passthrough=yes
/ip firewall nat
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=masquerade chain=srcnat comment=DUAL-WAN1 out-interface=WAN1
add action=masquerade chain=srcnat comment=DUAL-WAN2 out-interface=WAN2
/ip hotspot ip-binding
add address=10.0.0.2 comment=DEVTB486A6AE114C mac-address=4C:11:AE:A6:86:B4 \
    server=BRIDGE-PORTAL to-address=10.0.0.2 type=bypassed
add address=10.0.255.248 comment=BUGSFC393005613C mac-address=\
    3C:61:05:30:39:FC to-address=10.0.255.248 type=bypassed
add address=10.0.0.67 comment=DEVT5CB5D1BF713C mac-address=3C:71:BF:D1:B5:5C \
    to-address=10.0.0.67 type=bypassed
add address=10.0.0.59 comment=DEVT8058661C5210 mac-address=10:52:1C:66:58:80 \
    to-address=10.0.0.59 type=bypassed
add address=10.0.0.57 comment=DEVT30AA0C05613C mac-address=3C:61:05:0C:AA:30 \
    to-address=10.0.0.57 type=bypassed
/ip hotspot user
add comment="jan/25/2022 08:34:59" name=JAFEbi28 password=JAFEbi28 profile=\
    ClientWiFi server=BRIDGE-PORTAL
/ip route
add check-gateway=ping comment=WAN1 distance=1 gateway=192.168.80.1 \
    routing-mark=to-WAN1
add check-gateway=ping comment=WAN2 distance=1 gateway=1.1.1.1 routing-mark=\
    to-WAN2
add check-gateway=ping comment=WAN1 distance=1 gateway=192.168.80.1
add check-gateway=ping comment=WAN2 distance=2 gateway=1.1.1.1
/ip service
set telnet disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/snmp
set enabled=yes
/system clock
set time-zone-name=Asia/Manila
/system identity
set name=FreeINTERNET
/system ntp client
set enabled=yes primary-ntp=103.134.252.11 secondary-ntp=162.159.200.123
/tool mac-server
set allowed-interface-list=none
/tool mac-server ping
set enabled=no
/tool netwatch
add comment="ISP No Internet" down-script=":global filename \"flash/hs/status.\
    txt\";\r\
    \n:if ( [:len [/file find name=\$filename]] <= 0 ) do={\r\
    \n/file print file=\$filename;:delay 3;\r\
    \n}\r\
    \n/file set [find name=\$filename] contents=\"NO INTERNET\";\r\
    \n:log warning \"ISP DOWN\";" host=8.8.8.8 interval=10s up-script=":global\
    \_filename \"flash/hs/status.txt\";\r\
    \n:if ( [:len [/file find name=\$filename]] <= 0 ) do={\r\
    \n/file print file=\$filename;:delay 3;\r\
    \n}\r\
    \n/file set [find name=\$filename] contents=\"ONLINE\";\r\
    \n:log warning \"ISP UP\";"
