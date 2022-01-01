/
/
/
/
#SET SYSTEM SETTINGS
/system identity set name=MT
/system clock set time-zone-name=Asia/Manila
/system ntp client set enabled=yes primary-ntp=103.134.252.11 secondary-ntp=162.159.200.123
/

#Set Global DNS
/ip dns set allow-remote-requests=yes servers=10.0.0.1,8.8.8.8,8.8.4.4
/


:delay 1

#Set Name for Ports
/interface wireless set [ find default-name=wlan1 ] antenna-gain=2 band=2ghz-b/g/n country=philippines disabled=no frequency-mode=regulatory-domain mode=ap-bridge ssid="TestWIFI" wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/interface ethernet set [ find default-name=ether1 ]  comment=WAN1 name=WAN1
/interface ethernet set [ find default-name=ether2 ]  comment=WAN2 name=WAN2
/interface ethernet set [ find default-name=ether3 ]  name=LAN1
/interface ethernet set [ find default-name=ether4 ]  name=LAN2
/interface ethernet set [ find default-name=ether5 ]  name=LAN3
/interface ethernet set [ find default-name=ether6 ]  name=LAN4
/interface ethernet set [ find default-name=ether7 ]  name=LAN5
/interface ethernet set [ find default-name=ether8 ]  name=LAN6
/interface ethernet set [ find default-name=ether9 ]  name=LAN7
/interface ethernet set [ find default-name=ether10 ] name=LAN8
/

#Create Bridge
/interface bridge add name=BRIDGE-PORTAL
/

#Set Route for DUAL WAN (Fail-OVer+Load-Balance)
/ip route add check-gateway=ping comment=WAN1 distance=1 gateway=1.1.1.1 routing-mark=to-WAN1
/ip route add check-gateway=ping comment=WAN2 distance=1 gateway=1.1.1.1 routing-mark=to-WAN2
/ip route add check-gateway=ping comment=WAN1 distance=1 gateway=1.1.1.1
/ip route add check-gateway=ping comment=WAN2 distance=2 gateway=1.1.1.1
/

:delay 1

#DUAL WAN
#DHCP Client Setup for DUAL WAN
/ip dhcp-client add add-default-route=no comment=WAN1 disabled=no interface=WAN1 script="\
    if (\$bound=1) do={ \\\r\
    \n/ip route set [find comment=\"WAN1\"] gateway=\$\"gateway-address\"\
    ; \r\
    \n}" use-peer-dns=no
/ip dhcp-client add add-default-route=no comment=WAN2 disabled=no interface=WAN2 script="\
    if (\$bound=1) do={ \\\r\
    \n/ip route set [find comment=\"WAN2\"] gateway=\$\"gateway-address\"\
    ; \r\
    \n}" use-peer-dns=no
/

:delay 1

#Ping Test using Winbox Terminal
ping www.google.com count 3
/


:delay 1

#ADD FIREWALL FOR CLIENT INTERNET
/ip firewall nat add action=masquerade chain=srcnat comment=DUAL-WAN1 out-interface=WAN1
/ip firewall nat add action=masquerade chain=srcnat comment=DUAL-WAN2 out-interface=WAN2
/
#ADD MANGLE FOR DUAL WAN
/ip firewall mangle add action=mark-connection chain=input      comment=WAN1-INPUT   in-interface=WAN1 new-connection-mark=WAN1 passthrough=yes
/ip firewall mangle add action=mark-routing    chain=prerouting connection-mark=WAN1 new-routing-mark=to-WAN1 passthrough=yes
/ip firewall mangle add action=mark-connection chain=input      comment=WAN2-INPUT   in-interface=WAN2 new-connection-mark=WAN2 passthrough=yes
/ip firewall mangle add action=mark-routing    chain=prerouting connection-mark=WAN2 new-routing-mark=to-WAN2 passthrough=yes
/

:delay 1

#SET DHCP SERVER - BRIDGE (BRIDGE-PORTAL)
/ip address add address=10.0.0.1/16 comment=BRIDGE-PORTAL interface=BRIDGE-PORTAL network=10.0.0.0
/ip pool add name=BRIDGE-PORTAL ranges=10.0.0.51-10.0.255.250
/ip dhcp-server network add address=10.0.0.0/16 comment=BRIDGE-PORTAL gateway=10.0.0.1
/ip dhcp-server add address-pool=BRIDGE-PORTAL disabled=no lease-time=12h interface=BRIDGE-PORTAL name=BRIDGE-PORTAL
/
#Connect to Any Port and you should be able access to internet (Open)


/queue simple add max-limit=100M/100M name=BRIDGE-PORTAL packet-marks=mgt-pkt target=BRIDGE-PORTAL
/ip dhcp-server set [find interface=BRIDGE-PORTAL] lease-script=":local \
    queueName \"\$\"lease-hostname\" -  \$leaseActMAC\";\r\
    \n\r\
    \n:if (\$leaseBound = 1) do={\r\
    \n/queue simple add name=\$queueName target=(\$leaseActIP . \"/32\")  queu\
    e=\"PCQ/PCQ\" parent=BRIDGE-PORTAL priority=1/1;\r\
    \n} else={\r\
    \n/queue simple remove \$queueName\r\
    \n}\r\
    \n" name=BRIDGE-PORTAL
/

:delay 1

#Associate Ports to Bridge Interface
/interface bridge port add bridge=BRIDGE-PORTAL interface=wlan1
/interface bridge port add bridge=BRIDGE-PORTAL interface=LAN1
/interface bridge port add bridge=BRIDGE-PORTAL interface=LAN2
/interface bridge port add bridge=BRIDGE-PORTAL interface=LAN3
/interface bridge port add bridge=BRIDGE-PORTAL interface=LAN4
/interface bridge port add bridge=BRIDGE-PORTAL interface=LAN5
/interface bridge port add bridge=BRIDGE-PORTAL interface=LAN6
/interface bridge port add bridge=BRIDGE-PORTAL interface=LAN7
/interface bridge port add bridge=BRIDGE-PORTAL interface=LAN8
/

