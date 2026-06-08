#!/bin/sh
set -eu

SCRAPE_URI="${NGINX_EXPORTER_SCRAPE_URI:-http://localhost:81/stub_status}"
LISTEN="${NGINX_EXPORTER_LISTEN:-0.0.0.0:9113}"

host="${LISTEN%:*}"
port="${LISTEN##*:}"

fetch_status() {
  wget -qO- "$SCRAPE_URI" 2>/dev/null || true
}

render_metrics() {
  body="$(fetch_status)"
  active=0
  accepts=0
  handled=0
  requests=0
  reading=0
  writing=0
  waiting=0

  if [ -n "$body" ]; then
    active="$(printf '%s\n' "$body" | awk '/Active connections/ {print $3}')"
    set -- $(printf '%s\n' "$body" | awk 'NR==3 {print $1, $2, $3}')
    accepts="${1:-0}"
    handled="${2:-0}"
    requests="${3:-0}"
    reading="$(printf '%s\n' "$body" | awk '/Reading:/ {print $2}')"
    writing="$(printf '%s\n' "$body" | awk '/Writing:/ {print $4}')"
    waiting="$(printf '%s\n' "$body" | awk '/Waiting:/ {print $6}')"
  fi

  cat <<EOF
# HELP nginx_connections_active Active client connections.
# TYPE nginx_connections_active gauge
nginx_connections_active ${active:-0}
# HELP nginx_connections_reading Connections where nginx is reading the request header.
# TYPE nginx_connections_reading gauge
nginx_connections_reading ${reading:-0}
# HELP nginx_connections_writing Connections where nginx is writing the response.
# TYPE nginx_connections_writing gauge
nginx_connections_writing ${writing:-0}
# HELP nginx_connections_waiting Idle client connections.
# TYPE nginx_connections_waiting gauge
nginx_connections_waiting ${waiting:-0}
# HELP nginx_connections_accepted_total Accepted client connections.
# TYPE nginx_connections_accepted_total counter
nginx_connections_accepted_total ${accepts:-0}
# HELP nginx_connections_handled_total Handled client connections.
# TYPE nginx_connections_handled_total counter
nginx_connections_handled_total ${handled:-0}
# HELP nginx_http_requests_total Total HTTP requests.
# TYPE nginx_http_requests_total counter
nginx_http_requests_total ${requests:-0}
EOF
}

while :; do
  {
    printf 'HTTP/1.1 200 OK\r\nContent-Type: text/plain; version=0.0.4\r\n\r\n'
    render_metrics
  } | nc -l -p "$port" -s "$host"
done
