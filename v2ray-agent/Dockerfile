FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TZ=Asia/Shanghai

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    lsof \
    socat \
    jq \
    openssl \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# 安装 Nginx
RUN apt-get update && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

# 安装 acme.sh 依赖
RUN apt-get update && apt-get install -y \
    cron \
    socat \
    && rm -rf /var/lib/apt/lists/*

# 创建必要的目录结构
RUN mkdir -p \
    /etc/v2ray-agent \
    /etc/v2ray-agent/xray/conf \
    /etc/v2ray-agent/sing-box/conf/config \
    /etc/v2ray-agent/tls \
    /etc/v2ray-agent/subscribe_local \
    /etc/v2ray-agent/subscribe_local/default \
    /etc/v2ray-agent/subscribe_local/clashMeta \
    /etc/v2ray-agent/subscribe_local/sing-box \
    /var/log/v2ray-agent \
    /root/.acme.sh

# 复制项目文件
COPY . /opt/v2ray-agent
WORKDIR /opt/v2ray-agent

# 设置脚本权限
RUN chmod +x install.sh shell/*.sh

# 创建入口点脚本
RUN cat > /entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# 设置时区
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 检查必需的环境变量
if [ -z "$DOMAIN" ]; then
    echo "错误: DOMAIN 环境变量未设置"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "错误: EMAIL 环境变量未设置"
    exit 1
fi

# 生成配置文件
cat > /opt/v2ray-agent/.env << EOL
DOMAIN=$DOMAIN
EMAIL=$EMAIL
PORT=${PORT:-443}
PROTOCOLS=${PROTOCOLS:-0,1,2,3,4,5,6,7,8,9,10,11,12,13,20}
CUSTOM_PATH=${CUSTOM_PATH:-}
UUID=${UUID:-}
HYSTERIA_PORT=${HYSTERIA_PORT:-}
HYSTERIA_DOWNLOAD_SPEED=${HYSTERIA_DOWNLOAD_SPEED:-100}
HYSTERIA_UPLOAD_SPEED=${HYSTERIA_UPLOAD_SPEED:-50}
TUIC_PORT=${TUIC_PORT:-}
DNS_API_TYPE=${DNS_API_TYPE:-}
CF_API_TOKEN=${CF_API_TOKEN:-}
ALI_KEY=${ALI_KEY:-}
ALI_SECRET=${ALI_SECRET:-}
SSL_TYPE=${SSL_TYPE:-zerossl}
EOL

# 复制环境变量到全局
export $(cat /opt/v2ray-agent/.env | xargs)

# 执行安装脚本（非交互模式）
echo "开始安装 v2ray-agent..."
bash /opt/v2ray-agent/install.sh << EOL
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
EOL

# 启动服务
echo "启动服务..."
/usr/sbin/nginx -g "daemon off;" &
nginx_pid=$!

# 启动 Xray/sing-box
if [ -f "/usr/local/bin/xray" ]; then
    /usr/local/bin/xray run -config /etc/v2ray-agent/xray/conf/config.json &
    xray_pid=$!
fi

if [ -f "/usr/local/bin/sing-box" ]; then
    /usr/local/bin/sing-box run -c /etc/v2ray-agent/sing-box/conf/config/config.json &
    singbox_pid=$!
fi

# 等待信号
trap "kill $nginx_pid $xray_pid $singbox_pid; exit 0" SIGINT SIGTERM
wait
EOF

RUN chmod +x /entrypoint.sh

# 暴露端口
EXPOSE 80 443 10000-30000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]