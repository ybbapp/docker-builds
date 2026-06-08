#!/bin/sh
set -eu

CLASH_HOST="${CLASH_HOST:-localhost:9090}"
CLASH_TOKEN="${CLASH_TOKEN:-}"
LISTEN="${CLASH_EXPORTER_LISTEN:-0.0.0.0:2112}"

host="${LISTEN%:*}"
port="${LISTEN##*:}"

fetch_connections() {
  if [ -n "$CLASH_TOKEN" ]; then
    wget -qO- --header "Authorization: Bearer $CLASH_TOKEN" "http://$CLASH_HOST/connections" 2>/dev/null || true
  else
    wget -qO- "http://$CLASH_HOST/connections" 2>/dev/null || true
  fi
}

render_metrics() {
  body="$(fetch_connections)"
  count=0
  upload=0
  download=0

  if [ -n "$body" ]; then
    count="$(printf '%s' "$body" | grep -o '"id"' | wc -l | tr -d ' ')"
    upload="$(printf '%s' "$body" | grep -o '"upload":[0-9]*' | cut -d: -f2 | awk '{s+=$1} END{print s+0}')"
    download="$(printf '%s' "$body" | grep -o '"download":[0-9]*' | cut -d: -f2 | awk '{s+=$1} END{print s+0}')"
  fi

  cat <<EOF
# HELP clash_connections Active Clash connections.
# TYPE clash_connections gauge
clash_connections $count
# HELP clash_upload_bytes_total Clash upload bytes reported by the API.
# TYPE clash_upload_bytes_total counter
clash_upload_bytes_total $upload
# HELP clash_download_bytes_total Clash download bytes reported by the API.
# TYPE clash_download_bytes_total counter
clash_download_bytes_total $download
EOF
}

while :; do
  {
    printf 'HTTP/1.1 200 OK\r\nContent-Type: text/plain; version=0.0.4\r\n\r\n'
    render_metrics
  } | nc -l -p "$port" -s "$host"
done
