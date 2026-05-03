# v2ray-agent Docker 部署指南

## 概述
将 v2ray-agent 项目 Docker 化，支持通过环境变量配置所有安装参数，实现一键部署。

## 文件结构
```
v2ray-agent/
├── Dockerfile              # Docker 镜像构建文件
├── docker-compose.yml      # Docker Compose 配置文件
├── docker-env.sh          # 环境变量配置脚本
└── data/                  # 持久化数据目录（自动创建）
```

## 快速开始

### 1. 配置环境变量
创建 `.env` 文件：
```bash
DOMAIN=your-domain.com
EMAIL=your-email@example.com
PORT=443
PROTOCOLS=0,1,2,3,4,5,6,7,8,9,10,11,12,13,20
```

### 2. 构建并启动
```bash
# 创建数据目录
mkdir -p data/{tls,xray,sing-box,subscribe,nginx,acme,logs}

# 构建镜像
docker-compose build

# 启动容器
docker-compose up -d
```

### 3. 查看日志
```bash
docker-compose logs -f
```

## 环境变量说明

### 必需配置
- `DOMAIN`: 你的域名（如 example.com）
- `EMAIL`: SSL 证书邮箱

### 可选配置
- `PORT`: 主端口，默认 443
- `PROTOCOLS`: 协议选择，逗号分隔，默认全选
  - 0: VLESS+TCP+TLS Vision
  - 1: VLESS+WS+TLS
  - 2: Trojan+gRPC+TLS
  - 3: VMess+WS+TLS
  - 4: Trojan+TCP+TLS
  - 5: VLESS+gRPC+TLS
  - 6: Hysteria2
  - 7: VLESS+Reality+Vision
  - 8: VLESS+Reality+gRPC
  - 9: Tuic
  - 10: NaiveProxy
  - 11: VMess+HTTPUpgrade+TLS
  - 12: VLESS+Reality+XHTTP
  - 13: AnyTLS
  - 20: Socks5
- `CUSTOM_PATH`: 自定义路径，留空则随机生成
- `UUID`: 自定义 UUID，留空则随机生成
- `HYSTERIA_PORT`: Hysteria2 端口
- `HYSTERIA_DOWNLOAD_SPEED`: 下行速度（Mbps），默认 100
- `HYSTERIA_UPLOAD_SPEED`: 上行速度（Mbps），默认 50
- `TUIC_PORT`: Tuic 端口
- `DNS_API_TYPE`: DNS API 类型（cf/ali）
- `CF_API_TOKEN`: Cloudflare API Token
- `ALI_KEY`: 阿里云 AccessKey
- `ALI_SECRET`: 阿里云 AccessSecret
- `SSL_TYPE`: SSL 证书类型，默认 zerossl

## 持久化数据
所有配置和证书都通过 volume 持久化：
- `./data/tls`: TLS 证书
- `./data/xray`: Xray 配置
- `./data/sing-box`: sing-box 配置
- `./data/subscribe`: 订阅链接
- `./data/nginx`: Nginx 配置
- `./data/acme`: acme.sh 配置
- `./data/logs`: 日志文件

## 端口映射
- 80: HTTP 端口（证书申请）
- 443: HTTPS 端口（主服务）
- 10000-30000: 协议端口范围

## 手动安装（不使用 Docker Compose）
```bash
# 构建镜像
docker build -t v2ray-agent .

# 运行容器
docker run -d \
  --name v2ray-agent \
  -p 80:80 \
  -p 443:443 \
  -p 10000-30000:10000-30000 \
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
  --restart unless-stopped \
  v2ray-agent
```

## 注意事项
1. 确保域名 DNS 解析到服务器 IP
2. 首次启动需要申请证书，可能需要几分钟
3. 证书申请需要 80 端口可访问
4. 使用 DNS API 可避免 80 端口依赖
5. 容器需要 NET_ADMIN 和 NET_RAW 权限

## 故障排除
```bash
# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs

# 进入容器
docker-compose exec v2ray-agent bash

# 重启容器
docker-compose restart
```