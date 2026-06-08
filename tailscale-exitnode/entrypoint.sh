#!/bin/sh
set -eu

NETWORK_KERNEL="${NETWORK_KERNEL:-singbox}"
SINGBOX_CONFIG="${SINGBOX_CONFIG:-/etc/sing-box/config.jsonc}"
MIHOMO_CONFIG="${MIHOMO_CONFIG:-/etc/mihomo/config.yaml}"

KERNEL_PID=""
CONTAINERBOOT_PID=""
EXPORTER_PID=""
EXPORTER_KIND=""

log() {
  printf '[tailscale-exitnode] %s\n' "$*"
}

stop() {
  trap - INT TERM
  log "stopping"
  if [ -n "$EXPORTER_PID" ]; then
    kill "$EXPORTER_PID" 2>/dev/null || true
  fi
  if [ -n "$CONTAINERBOOT_PID" ]; then
    kill "$CONTAINERBOOT_PID" 2>/dev/null || true
  fi
  if [ -n "$KERNEL_PID" ]; then
    kill "$KERNEL_PID" 2>/dev/null || true
  fi
  wait 2>/dev/null || true
}

start_exporter() {
  case "$NETWORK_KERNEL" in
    singbox | sing-box)
      if [ -n "${CLASH_EXPORTER_HOST:-}" ]; then
        EXPORTER_KIND="clash-exporter"
        log "starting clash exporter for $CLASH_EXPORTER_HOST"
        CLASH_HOST="$CLASH_EXPORTER_HOST" CLASH_TOKEN="${CLASH_EXPORTER_TOKEN:-}" CLASH_EXPORTER_LISTEN="${CLASH_EXPORTER_LISTEN:-0.0.0.0:2112}" \
          clash-exporter &
        EXPORTER_PID="$!"
      else
        log "warning: CLASH_EXPORTER_HOST is not set; clash exporter disabled"
      fi
      ;;
    mihomo)
      if [ -n "${NGINX_EXPORTER_SCRAPE_URI:-}" ]; then
        EXPORTER_KIND="nginx-exporter"
        log "starting nginx exporter for $NGINX_EXPORTER_SCRAPE_URI"
        NGINX_EXPORTER_SCRAPE_URI="$NGINX_EXPORTER_SCRAPE_URI" NGINX_EXPORTER_LISTEN="${NGINX_EXPORTER_LISTEN:-0.0.0.0:9113}" \
          nginx-exporter &
        EXPORTER_PID="$!"
      else
        log "warning: NGINX_EXPORTER_SCRAPE_URI is not set; nginx exporter disabled"
      fi
      ;;
  esac
}

restart_exporter() {
  if [ -z "$EXPORTER_KIND" ]; then
    return 0
  fi

  log "warning: $EXPORTER_KIND exited; restarting"
  EXPORTER_PID=""
  start_exporter
}

is_alive() {
  pid="$1"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

trap 'stop; exit 143' INT TERM

case "$NETWORK_KERNEL" in
  singbox | sing-box)
    log "starting sing-box with $SINGBOX_CONFIG"
    sing-box run -c "$SINGBOX_CONFIG" &
    KERNEL_PID="$!"
    ;;
  mihomo)
    log "starting mihomo with $MIHOMO_CONFIG"
    mihomo -f "$MIHOMO_CONFIG" &
    KERNEL_PID="$!"
    ;;
  *)
    log "unsupported NETWORK_KERNEL: $NETWORK_KERNEL"
    exit 1
    ;;
esac

sleep 2
if ! kill -0 "$KERNEL_PID" 2>/dev/null; then
  status=0
  wait "$KERNEL_PID" || status="$?"
  log "network kernel exited during startup with status $status"
  exit "$status"
fi

log "starting tailscale containerboot"
containerboot &
CONTAINERBOOT_PID="$!"

start_exporter

log "ready"
while :; do
  if ! is_alive "$KERNEL_PID"; then
    status=0
    wait "$KERNEL_PID" || status="$?"
    log "network kernel exited with status $status"
    exit "$status"
  fi

  if ! is_alive "$CONTAINERBOOT_PID"; then
    status=0
    wait "$CONTAINERBOOT_PID" || status="$?"
    log "containerboot exited with status $status"
    exit "$status"
  fi

  if [ -n "$EXPORTER_PID" ] && ! is_alive "$EXPORTER_PID"; then
    wait "$EXPORTER_PID" 2>/dev/null || true
    restart_exporter
  fi

  sleep 2
done
