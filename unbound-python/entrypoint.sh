#!/bin/sh
set -eu

mkdir -p /run/unbound /var/lib/unbound /etc/unbound/unbound.conf.d
chown -R unbound:unbound /run/unbound /var/lib/unbound

if [ "${1:-}" = "unbound" ]; then
  shift
fi

exec unbound "$@"
