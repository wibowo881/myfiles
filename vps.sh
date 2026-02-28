#!/bin/bash


sudo apt-get update -y
sudo apt-get install -y ufw

## wget https://raw.githubusercontent.com/lizsvr/XRAY-MULTI/main/setup.sh && chmod +x setup.sh && ./setup.sh

sudo rm -rf /etc/zivpn 
sudo mkdir /etc/zivpn

sleep 2
#cd /usr/local/bin
wget -P /usr/local/bin https://github.com/wibowo881/myfiles/blob/13ac3961787274b9e57eac4a7273738ff4a3fa37/badvpn-udpgw && chmod +x /usr/local/bin/badvpn-udpgw

sleep 2
wget -P /usr/local/bin https://github.com/wibowo881/myfiles/blob/ec03ad971e38116ca5228ec46adfa34c37bbe850/zivpn && chmod +x /usr/local/bin/zivpn

sleep 2
sed -i 's/Listen 80/Listen 8880/g' /etc/apache2/ports.conf

# sudo cat <<EOF > /etc/nginx/conf.d/xray.conf
# server {
#              listen 80;
#              listen [::]:80;
#              listen 443 ssl http2 reuseport;
#              listen [::]:443 http2 reuseport;             
#              server_name sgdo.ckpp.xyz;
#              ssl_certificate /etc/xray/ca.pem;
#              ssl_certificate_key /etc/xray/prive.pem;
#              ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
#              ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
#              root /home/vps/public_html;
# location = /xrayws
# {
# proxy_redirect off;
# proxy_pass http://unix:/run/xray/vless_ws.sock;
# proxy_http_version 1.1;
# proxy_set_header X-Real-IP $remote_addr;
# proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";
# proxy_set_header Host $http_host;
# }
# location = /xrayvws
# {
# proxy_redirect off;
# proxy_pass http://unix:/run/xray/vmess_ws.sock;
# proxy_http_version 1.1;
# proxy_set_header X-Real-IP $remote_addr;
# proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";
# proxy_set_header Host $http_host;
# }
# location = /xraytrojanws
# {
# proxy_redirect off;
# proxy_pass http://unix:/run/xray/trojan_ws.sock;
# proxy_http_version 1.1;
# proxy_set_header X-Real-IP $remote_addr;
# proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";
# proxy_set_header Host $http_host;
# }
# location = /xrayssws
# {
# proxy_redirect off;
# proxy_pass http://127.0.0.1:30300;
# proxy_http_version 1.1;
# proxy_set_header X-Real-IP $remote_addr;
# proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";
# proxy_set_header Host $http_host;
# }
# location /
# {
# proxy_redirect off;
# proxy_pass http://127.0.0.1:8880;
# proxy_http_version 1.1;
# proxy_set_header X-Real-IP $remote_addr;
# proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";
# proxy_set_header Host $http_host;
# }
# location ^~ /vless-grpc
# {
# proxy_redirect off;
# grpc_set_header X-Real-IP $remote_addr;
# grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# grpc_set_header Host $http_host;
# grpc_pass grpc://unix:/run/xray/vless_grpc.sock;
# }
# location ^~ /vmess-grpc
# {
# proxy_redirect off;
# grpc_set_header X-Real-IP $remote_addr;
# grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# grpc_set_header Host $http_host;
# grpc_pass grpc://unix:/run/xray/vmess_grpc.sock;
# }
# location ^~ /trojan-grpc
# {
# proxy_redirect off;
# grpc_set_header X-Real-IP $remote_addr;
# grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# grpc_set_header Host $http_host;
# grpc_pass grpc://unix:/run/xray/trojan_grpc.sock;
# }
# location ^~ /ss-grpc
# {
# proxy_redirect off;
# grpc_set_header X-Real-IP $remote_addr;
# grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# grpc_set_header Host $http_host;
# grpc_pass grpc://127.0.0.1:30310;
# }
#         }
# EOF

sleep 2
sudo setcap cap_net_bind_service=+ep /usr/local/bin/zivpn
echo 1 >/proc/sys/net/ipv4/ip_forward
netfilter-persistent save >/dev/null 2>&1
echo "net.ipv4.ip_forward=1"
sudo echo "net.ipv4.ip_forward=1
net.ipv4.tcp_keepalive_time = 90
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_fastopen = 3
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
fs.file-max = 65535000" >> /etc/sysctl.conf

sleep 2

sudo cat <<EOF > /usr/local/bin/ports.sh
#!/bin/bash
/usr/sbin/iptables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp
ufw allow 5667/udp
EOF
sudo chmod +x /usr/local/bin/ports.sh
sudo cat <<EOF > /usr/local/bin/cc.sh
#!/bin/sh
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
EOF
sudo chmod +x /usr/local/bin/cc.sh

sudo cat <<EOF > /etc/xray/ca.pem
-----BEGIN CERTIFICATE-----
MIIEnDCCA4SgAwIBAgIUZ2sAvVmSJm1aVqlKKQ0UW7o83WIwDQYJKoZIhvcNAQEL
BQAwgYsxCzAJBgNVBAYTAlVTMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTQw
MgYDVQQLEytDbG91ZEZsYXJlIE9yaWdpbiBTU0wgQ2VydGlmaWNhdGUgQXV0aG9y
aXR5MRYwFAYDVQQHEw1TYW4gRnJhbmNpc2NvMRMwEQYDVQQIEwpDYWxpZm9ybmlh
MB4XDTI1MDYwNTA5MDQwMFoXDTQwMDYwMTA5MDQwMFowYjEZMBcGA1UEChMQQ2xv
dWRGbGFyZSwgSW5jLjEdMBsGA1UECxMUQ2xvdWRGbGFyZSBPcmlnaW4gQ0ExJjAk
BgNVBAMTHUNsb3VkRmxhcmUgT3JpZ2luIENlcnRpZmljYXRlMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqQG2d1+NeIc9DCMIkBvqzq2A5lODemKlFCoK
lBxQbxraB9LCsY53v+Bdj3YV1Q7Q5D5tSeI/9dkX9cDLu4jdI/vWqmdoBf4bVimx
DbF5GH0/AP6tEj83VxQJi/D+L3W2wqbWdLScHDzmBl7LmuwOKnaL82/Wv+hIHnqO
pwDaETi5XpX5KLWe6QS8eMd3I0G9ZmrntcoV9P+SRwbfWnVdYbgioUMnwZkpqyG4
K2IExtc0f7V5kKyqnTXcwKngptGDn+KjNF16g0uSjLG6gdELbU4ePSvqk4WD9aK2
80yDxD8zOfeWp93hdz3028sMHaJsst+b07as09G/L8mJYjhplQIDAQABo4IBHjCC
ARowDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
ATAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQMlB1lt+iR/av+1U3Vyp1zan8NnDAf
BgNVHSMEGDAWgBQk6FNXXXw0QIep65TbuuEWePwppDBABggrBgEFBQcBAQQ0MDIw
MAYIKwYBBQUHMAGGJGh0dHA6Ly9vY3NwLmNsb3VkZmxhcmUuY29tL29yaWdpbl9j
YTAfBgNVHREEGDAWggoqLmNrcHAueHl6gghja3BwLnh5ejA4BgNVHR8EMTAvMC2g
K6AphidodHRwOi8vY3JsLmNsb3VkZmxhcmUuY29tL29yaWdpbl9jYS5jcmwwDQYJ
KoZIhvcNAQELBQADggEBAHiEkzN0ml5PTAcf0N9sNiGy5XwxHIdUEMx5xudOKpNB
4Wqesud3U9LhGftyX75b8LsxLFgZA33nWFSELLpi39YM410msFATTcILt2y9f0ES
hdyPbpsMHOK96wJewftlbnjeuxEdqAtapwQQ+JJsZodcSI5KNlmu7q0h1bPbSw/j
ch643HZj7NwklzuHkCSpH9bIbWIYrlEvcPOgdho+n8FIWD1/HX4uv74qpcoqXZGk
5St9l1BGWwUcJKUUaEHKmeUkz43flORI/KixfER92XSv1ESuZIQjH/NncYxsipSt
CFbVabk8Ha6Bsqhbi1esF43P+/6ndFWVRVptSDKGSBQ=
-----END CERTIFICATE-----
EOF

sudo cat <<EOF > /etc/xray/prive.pem
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCpAbZ3X414hz0M
IwiQG+rOrYDmU4N6YqUUKgqUHFBvGtoH0sKxjne/4F2PdhXVDtDkPm1J4j/12Rf1
wMu7iN0j+9aqZ2gF/htWKbENsXkYfT8A/q0SPzdXFAmL8P4vdbbCptZ0tJwcPOYG
Xsua7A4qdovzb9a/6Egeeo6nANoROLlelfkotZ7pBLx4x3cjQb1maue1yhX0/5JH
Bt9adV1huCKhQyfBmSmrIbgrYgTG1zR/tXmQrKqdNdzAqeCm0YOf4qM0XXqDS5KM
sbqB0QttTh49K+qThYP1orbzTIPEPzM595an3eF3PfTbywwdomyy35vTtqzT0b8v
yYliOGmVAgMBAAECggEADH2LajQeJP+9s8VtDxV5G5A4HA2lBGkA8UYQJRUYnrV5
0qUxbWTtlbkzwPQFtgrTxmKUuial+nnyat+2TuRVD6E/orVkuzil9Y68PppUrEop
W133FYelg+J/uB918bT97lHdPJ/Sf8XCbEsaOhdjDqFXQ4UK9oDov5PoMhB+jVIo
kQxrgJ7Sf2XXusY4OlHyAfnqZfjrNv8fDg6AspINKZzcMVfPxzpP33u/BFIolLxt
YkF3YCHLlwzgLx55RfIl4E38MziNcjRlr6AbhOVUZV6JGHXgSItsjxemDZihUYDl
FkMxi/L/oJtmqnTwJpPitzSsJJ4/gHpM0VwtreXKYQKBgQDf0AJI11SGjoXbtSCF
ng2Ag08EzIH9frusINfeuJ9muRlsKZBNKnW2NdqN0vLnFcP+umYl+D4/ejxJdG5/
e6G/WePss9dWMJJuyX35z3Gskp+3eXHVcLz6mo4M3pSP//IBHCY70hzv5hyc67f7
4xEa5ETD8diMIZWbl/vKi4o6BQKBgQDBT/H6auQJF+hXkxusEU/Pe5kGkUMrksMr
Z8XV17vroT7fJ5kAbpgsq6invSODVg82lI9F+vFaeCADuCAxE1O3kIAgYoQLmaK1
dE0xx0jQDsXYHGQ79inPOnVoFE/+A3OCqH4lT/oZ/rIfoQZ6dxV+JaKseTjLAeWZ
0daEZ3M2UQKBgQCMPGGyEno79YGaMNu33VjIdX5Fm363v3kIWWvpefUnAEQVqdVp
BHnNOeE/jDX25YRxT4pBsFIQpB6yR+oUpvqqU0ClR+pdbwHRuR7eMEUhxJ2e8NGK
06EVxVHMborXz59rYp/yS60mBCFZkbkucxB8sRsFS7xL0Z9UZt62AskRoQKBgAol
mB383ltb1eZC4oD1p6rMYgvmNBBlc7kjiU7gNAz6OcKc4XsUUwiFOiUT2HlcWxAS
XDLgKSsGgyeu0oHA8fQAsbkBcszpE5FSuXqTa08Ad4IQe3JqSWeHOgJsjoZWyAlj
rrtmp0oWBGOEoEJtXcNxVkiXVFPTlamtSgVJKNMBAoGBALwdoJD5mYuFeW4l09ZC
0tP45lHLDDZdopw9H5kC5mxj6U7NDTQxFObCWwnzcw6jvgpUze5M57Ze2cUtLX/R
cJCGJGQtYlm60rR42G6y+3IPjDDu3i7T/qeyAUQdqy+Z+UhUJ2/obdKHPEVyaQ9w
bjnYlywnRZ8g3OrCW8gOwtku
-----END PRIVATE KEY-----
EOF

sudo chmod -R 655 /root/cert
sudo chmod -R 655 /etc/xray/*.pem

sudo cat <<EOF > /etc/zivpn/config.json
{
  "listen": ":5667",
  "cert": "/etc/zivpn/ca.pem",
  "key": "/etc/zivpn/prive.pem",
   "obfs":"zivpn",
   "auth": {
    "mode": "passwords",
    "config": ["zi","ziv"]
  },
  "disableUDP": false,
  "ignoreClientBandwidth": true,
  "quic": {
    "initStreamReceiveWindow": 25165824,
    "maxStreamReceiveWindow": 50331648,
    "initConnReceiveWindow": 50331648,
    "maxConnReceiveWindow": 100663296,
    "maxIdleTimeout": "30s",
    "keepAliveInterval": "15s",
    "maxIncomingStreams": 4096,
  }
}
EOF
sudo cp /etc/xray/*.pem /etc/zivpn/
sudo chmod -R 655 /etc/zivpn/*.pem

sudo cat <<EOF > /etc/systemd/system/badvpn-udpgw.service
[Unit]
Description=UDP forwarding for badvpn-tun2socks
After=nss-lookup.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --loglevel none --listen-addr 127.0.0.1:7300
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable badvpn-udpgw
sudo systemctl start badvpn-udpgw

sleep 2

systemctl restart apach2 && systemctl restart nginx && systemctl restart zivpn

netstat -tunlp

