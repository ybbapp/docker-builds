# v2ray-agent Docker 部署指南

## 概述
将 v2ray-agent 项目 Docker 化，支持通过环境变量配置所有安装参数，实现一键部署。

## 镜像

| 架构 | 镜像 |
|:-----|:-----|
| amd64 | `ghcr.io/ybbapp/v2ray-agent:latest` |
| arm64 | `ghcr.io/ybbapp/v2ray-agent:latest` |

## 快速开始（使用预构建镜像）

### 1. 创建数据目录
```bash
mkdir -p data/{tls,xray,sing-box,subscribe,nginx,acme,logs}
```

### 2. 创建 .env 配置文件
```bash
cat > .env << EOF
DOMAIN=your-domain.com
EMAIL=your-email@example.com
PORT=443
PROTOCOLS=0,1,2,3,4,5,6,7,8,9,10,11,12,13,20
EOF
```

### 3. 启动容器
```bash
docker run -d \
  --name v2ray-agent \
  --restart unless-stopped \
  -p 80:80 -p 443:443 -p 10000-30000:10000-30000 \
  -e DOMAIN=your-domain.com \
  -e EMAIL=your-email@example.com \
  -v $(pwd)/data/tls:/etc/v2ray-agent/tls \
  -v $(pwd)/data/xray:/etc/v2ray-agent/xray \
  -v $(pwd)/data/sing-box:/etc/v2ray-agent/sing-box \
  -v $(pwd)/data/subscribe:/etc/v2ray-agent/subscribe_local \
  -v $(pwd)/data/nginx:/etc/nginx/conf.d \
  -v $(pwd)/data/acme:/root/.acme.sh \
  -v $(pwd)/data/logs:/var/log/v2ray-agent \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  ghcr.io/ybbapp/v2ray-agent:latest
```

### 4. 查看日志
```bash
docker logs -f v2ray-agent
```

## 使用 Docker Compose

### 1. 创建配置文件
```bash
mkdir -p data/{tls,xray,sing-box,subscribe,nginx,acme,logs}

cat > docker-compose.yml << 'EOF'
services:
  v2ray-agent:
    image: ghcr.io/ybbapp/v2ray-agent:latest
    container_name: v2ray-agent
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "10000-30000:10000-30000"
    environment:
      - DOMAIN=your-domain.com
      - EMAIL=your-email@example.com
      - PORT=443
      - PROTOCOLS=0,1,2,3,4,5,6,7,8,9,10,11,12,13,20
    volumes:
      - ./data/tls:/etc/v2ray-agent/tls
      - ./data/xray:/etc/v2ray-agent/xray
      - ./data/sing-box:/etc/v2ray-agent/sing-box
      - ./data/subscribe:/etc/v2ray-agent/subscribe_local
      - ./data/nginx:/etc/nginx/conf.d
      - ./data/acme:/root/.acme.sh
      - ./data/logs:/var/log/v2ray-agent
    cap_add:
      - NET_ADMIN
      - NET_RAW

EOF
```

### 2. 启动
```bash
docker-compose up -d
```

## 环境变量

### 必需
| 变量 | 说明 | 示例 |
|:-----|:-----|:-----|
| `DOMAIN` | 你的域名 | `example.com` |
| `EMAIL` | SSL 证书邮箱 | `admin@example.com` |

### 可选
| 变量 | 默认值 | 说明 |
|:-----|:-------|:-----|
| `PORT` | 443 | 主端口 |
| `PROTOCOLS` | 0-13,20 | 协议编号，逗号分隔 |
| `CUSTOM_PATH` | 随机 | 自定义路径 |
| `UUID` | 随机 | 自定义 UUID |
| `HYSTERIA_PORT` | 随机 | Hysteria2 端口 |
| `HYSTERIA_DOWNLOAD_SPEED` | 100 | 下行速度（Mbps） |
| `HYSTERIA_UPLOAD_SPEED` | 50 | 上行速度（Mbps） |
| `TUIC_PORT` | 随机 | Tuic 端口 |
| `DNS_API_TYPE` | - | DNS API（cf/ali） |
| `CF_API_TOKEN` | - | Cloudflare API Token |
| `ALI_KEY` | - | 阿里云 AccessKey |
| `ALI_SECRET` | - | 阿里云 AccessSecret |
| `SSL_TYPE` | zerossl | SSL 证书类型 |

### 协议编号
| 编号 | 协议 |
|:-----|:-----|
| 0 | VLESS+TCP+TLS Vision |
| 1 | VLESS+WS+TLS |
| 2 | Trojan+gRPC+TLS |
| 3 | VMess+WS+TLS |
| 4 | Trojan+TCP+TLS |
| 5 | VLESS+gRPC+TLS |
| 6 | Hysteria2 |
| 7 | VLESS+Reality+Vision |
| 8 | VLESS+Reality+gRPC |
| 9 | Tuic |
| 10 | NaiveProxy |
| 11 | VMess+HTTPUpgrade+TLS |
| 12 | VLESS+Reality+XHTTP |
| 13 | AnyTLS |
| 20 | Socks5 |

## 数据持久化
| 路径 | 说明 |
|:-----|:-----|
| `./data/tls` | TLS 证书 |
| `./data/xray` | Xray 配置 |
| `./data/sing-box` | sing-box 配置 |
| `./data/subscribe` | 订阅链接 |
| `./data/nginx` | Nginx 配置 |
| `./data/acme` | acme.sh 配置 |
| `./data/logs` | 日志文件 |

## 端口
| 端口 | 用途 |
|:-----|:-----|
| 80 | HTTP（证书申请） |
| 443 | HTTPS（主服务） |
| 10000-30000 | 协议端口 |

## 故障排除
```bash
docker logs -f v2ray-agent
docker exec -it v2ray-agent bash
docker restart v2ray-agent
```

## 注意事项
1. 域名 DNS 需解析到服务器 IP
2. 首次启动需申请证书，约需 1-2 分钟
3. 证书申请需 80 端口可访问（DNS API 可免）
4. 容器需要 NET_ADMIN 和 NET_RAW 权限