# tailscale-exitnode

Tailscale exit node image with a pluggable network kernel started in the same container before the official Tailscale `containerboot` process.

The image keeps Tailscale startup behavior aligned with the official `tailscale/tailscale` container and only wraps it to start the selected network kernel first. The default kernel is sing-box. Mihomo variants are also built.

## Image

| Image | Description |
|:------|:------------|
| `ghcr.io/ybbapp/tailscale-exitnode:latest` | Default sing-box kernel |
| `ghcr.io/ybbapp/tailscale-exitnode:singbox` | sing-box kernel |
| `ghcr.io/ybbapp/tailscale-exitnode:singbox-dev` | sing-box kernel with debug tools |
| `ghcr.io/ybbapp/tailscale-exitnode:mihomo` | mihomo kernel |
| `ghcr.io/ybbapp/tailscale-exitnode:mihomo-dev` | mihomo kernel with debug tools |

The `*-dev` tags include common debug tools such as `curl`, `dig`, `nslookup`, `ping`, `telnet`, `nc`, and `tcpdump`.

## Files

| File | Description |
|:-----|:------------|
| `Dockerfile.singbox` | Builds from `tailscale/tailscale:latest`, copies only sing-box and a lightweight built-in Clash API exporter |
| `Dockerfile.mihomo` | Builds from `tailscale/tailscale:latest`, copies only mihomo and a lightweight built-in nginx stub_status exporter |
| `entrypoint.sh` | Starts the selected network kernel, then starts Tailscale `containerboot` |
| `.env.example` | Sanitized example environment |
| `docker-compose.yml` | Sanitized compose example |

## Usage

Copy the example environment and fill in your own values:

```bash
cp .env.example .env
```

The example compose file points at `.env.example` so it can be validated directly from the repository. For a real deployment, either update `env_file` to `.env` or provide the same variables from your runtime environment.

Create a sing-box config at `./sing-box/config.jsonc`, then start:

```bash
docker compose up -d
```

To use mihomo, set:

```env
NETWORK_KERNEL=mihomo
```

Then create a mihomo config at `./mihomo/config.yaml`.

For local mihomo builds, change the compose build file to `Dockerfile.mihomo` or use the published `:mihomo` tag.

## Environment

The Tailscale side is handled by the official `containerboot` binary, so these variables follow the official Tailscale container behavior:

| Variable | Description |
|:---------|:------------|
| `TS_AUTHKEY` | Tailscale auth key |
| `TS_AUTH_ONCE` | Only authenticate once when state already exists |
| `TS_STATE_DIR` | Persistent state directory |
| `TS_USERSPACE` | Run Tailscale in userspace networking mode |
| `TS_HOSTNAME` | Node hostname |
| `TS_ROUTES` | Subnet routes to advertise |
| `TS_ACCEPT_DNS` | Whether to accept tailnet DNS |
| `TS_EXTRA_ARGS` | Extra arguments for `tailscale up` |
| `TS_TAILSCALED_EXTRA_ARGS` | Extra arguments for `tailscaled` |
| `TS_SOCKET` | LocalAPI socket path |

The network kernel side uses:

| Variable | Description |
|:---------|:------------|
| `NETWORK_KERNEL` | `singbox` or `mihomo`, default `singbox` |
| `SINGBOX_CONFIG` | Path to the sing-box config file, default `/etc/sing-box/config.jsonc` |
| `MIHOMO_CONFIG` | Path to the mihomo config file, default `/etc/mihomo/config.yaml` |

## Exporters

Exporter startup is optional. If the matching exporter settings are not provided, the container logs a warning and continues running.

| Kernel | Exporter | Settings |
|:-------|:---------|:---------|
| `singbox` | built-in Clash API exporter | `CLASH_EXPORTER_HOST=localhost:9090`, optional `CLASH_EXPORTER_TOKEN`, optional `CLASH_EXPORTER_LISTEN=0.0.0.0:2112` |
| `mihomo` | built-in nginx stub_status exporter | `NGINX_EXPORTER_SCRAPE_URI=http://localhost:81/stub_status`, optional `NGINX_EXPORTER_LISTEN=0.0.0.0:9113` |

Exporter processes are monitored by `entrypoint.sh`; if an exporter exits, it is restarted automatically.

## Notes

- Do not commit real auth keys, route lists, control server URLs, or production sing-box configs.
- `TS_EXTRA_ARGS` must contain flags accepted by `tailscale up`.
- Set-only flags such as peer relay settings should be configured outside this image or persisted in Tailscale state.
