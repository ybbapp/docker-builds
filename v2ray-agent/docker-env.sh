#!/bin/bash
# v2ray-agent Docker 环境变量配置脚本
# 用于将交互式安装转换为环境变量驱动的非交互安装

set -e

# 检查必需环境变量
if [ -z "$DOMAIN" ]; then
    echo "错误: DOMAIN 环境变量未设置"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "错误: EMAIL 环境变量未设置"
    exit 1
fi

# 默认值设置
PORT=${PORT:-443}
PROTOCOLS=${PROTOCOLS:-"0,1,2,3,4,5,6,7,8,9,10,11,12,13,20"}
CUSTOM_PATH=${CUSTOM_PATH:-""}
UUID=${UUID:-""}
HYSTERIA_PORT=${HYSTERIA_PORT:-""}
HYSTERIA_DOWNLOAD_SPEED=${HYSTERIA_DOWNLOAD_SPEED:-100}
HYSTERIA_UPLOAD_SPEED=${HYSTERIA_UPLOAD_SPEED:-50}
TUIC_PORT=${TUIC_PORT:-""}
DNS_API_TYPE=${DNS_API_TYPE:-""}
CF_API_TOKEN=${CF_API_TOKEN:-""}
ALI_KEY=${ALI_KEY:-""}
ALI_SECRET=${ALI_SECRET:-""}
SSL_TYPE=${SSL_TYPE:-"zerossl"}

# 生成自动应答文件
cat > /tmp/install_answers.txt << EOF
$DOMAIN
$EMAIL
$PORT
$PROTOCOLS
$CUSTOM_PATH
$UUID
$HYSTERIA_PORT
$HYSTERIA_DOWNLOAD_SPEED
$HYSTERIA_UPLOAD_SPEED
$TUIC_PORT
$DNS_API_TYPE
$CF_API_TOKEN
$ALI_KEY
$ALI_SECRET
$SSL_TYPE
EOF

echo "配置已生成到 /tmp/install_answers.txt"
echo "使用以下命令进行非交互安装:"
echo "cat /tmp/install_answers.txt | bash install.sh"