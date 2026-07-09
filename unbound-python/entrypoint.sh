#!/bin/sh
set -eu

mkdir -p /run/unbound /var/lib/unbound /var/unbound /etc/unbound/unbound.conf.d /etc/unbound/custom.conf.d
if [ ! -s /var/unbound/root.hints ] && [ -s /usr/share/dns/root.hints ]; then
  cp /usr/share/dns/root.hints /var/unbound/root.hints
fi
touch /var/unbound/root.key
chown -R unbound:unbound /run/unbound /var/lib/unbound /var/unbound

if [ "${1:-}" = "unbound" ]; then
  shift
fi

exec unbound "$@"
