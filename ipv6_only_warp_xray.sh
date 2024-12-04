#!/usr/bin/env bash


# All of the files the script involves are provided by official sources. 
# Specifically, CloudFlare-Warp is given by CloudFlare, as Xray-install is regarded as the offical installing script for Xray and hosted by Github. 

## Gobal verbals
GLOBAL_CFPORT=""
GLOBAL_XPORT=""


## Defining a function to derive CloudFlare-Warp port the user'd like it to listen on. 
function get_cfport() {
    echo -e "\033[1;36;45mPlease specify the port you'd like CloudFlare-Warp to listen on (default 40000).\033[0m"
    read cfport
    if [ -z "$cfport" ]; then
    cfport=40000
    fi
    if [[ $cfport =~ ^[0-9]+$ ]] && [ $cfport -ge 1 ] && [ $cfport -le 65535 ]; then
        GLOBAL_CFPORT=$cfport
    else
        echo -e "\033[1;36;45mInvalid port number. Please enter a number between 1 and 65535.\033[0m"
        get_cfport
    fi
}

## Defining a function to derive Xray port the user'd like it to listen on. 
function get_xport() {
    echo -e "\033[1;36;45mPlease specify the port you'd like Xray to listen on (default 12345).\033[0m"
    read xport
    if [ -z "$xport" ]; then
    xport=12345
    fi
    if [[ $xport =~ ^[0-9]+$ ]] && [ $xport -ge 1 ] && [ $xport -le 65535 ]; then
        GLOBAL_XPORT=$xport
    else
        echo -e "\033[1;36;45mInvalid port number. Please enter a number between 1 and 65535.\033[0m"
        get_xport
    fi
}

## Installing dependencies
echo -e "\033[1;36;45mInstalling dependencies utilized by CloudFlare-Warp and Xray-install.\033[0m"
sudo apt update
sudo apt -y install wget
sudo apt -y install curl
sudo apt -y install gpg


## Installing CloudFlare-Warp
echo -e "\033[1;36;45mCloudFlare-Warp installation in process.\033[0m"
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
sudo apt-get update && sudo apt-get install cloudflare-warp
echo -e "\033[1;36;45mWait for warp daemon to get started.\033[0m"
sleep 36

## Registering CloudFlare-Warp
echo -e "\033[1;36;45mNew warp registration in process.\033[0m"
sudo systemctl enable warp-svc.service
sudo systemctl start warp-svc.service
sudo warp-cli registration new
sleep 3

## Setting CloudFlare-Warp port
get_cfport
sudo warp-cli proxy port $GLOBAL_CFPORT

## Setting Proxy mode
echo -e "\033[1;36;45mCloudFlare-Warp switched to Proxy mode.\033[0m"
sudo warp-cli mode proxy

## Launching CloudFlare-Warp
echo -e "\033[1;36;45mConnecting warp.\033[0m"
sudo warp-cli connect
sleep 3
## Installing Xray-install
sudo bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh --proxy socks://localhost:$GLOBAL_CFPORT)" @ install -u root --proxy socks://localhost:$GLOBAL_CFPORT

## Stopping Xray service
sudo systemctl stop xray

## Configuring Xray
echo -e "\033[1;36;45mXray outbound configuration in process.\033[0m"
get_xport
xray_pw=$(openssl rand -base64 16)
> "/usr/local/etc/xray/config.json"
cat <<EOL > "/usr/local/etc/xray/config.json"
{
    "log": {
        "access": "/var/log/xray/access.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "warning"
    },
    "inbounds": [{
        "port": $GLOBAL_XPORT,
        "protocol": "shadowsocks",
        "settings": {
            "method": "2022-blake3-aes-128-gcm",
            "password": "$xray_pw",
            "network": "tcp,udp"
        }
    }],
    "outbounds": [
        {
            "protocol": "socks",
            "settings": {
                "servers": [{
                    "address": "localhost",
                    "port": $GLOBAL_CFPORT,
                    "domainStrategy": "UseIPv4"
                }]
        },
            "tag": "warp-bound"
        },
        {
            "protocol": "freedom",
            "tag": "direct",
            "settings": {
                "domainStrategy": "UseIPv6"
            }
        },
        
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
}
EOL
sudo systemctl start xray
echo -e "\033[1;36;45mXray Port: $GLOBAL_XPORT\nXray method: 2022-blake3-aes-128-gcm\nXray password: $xray_pw\033[0m"
echo -e "\nYou can modify xray configuration manually later, specifically the inbound sector."
