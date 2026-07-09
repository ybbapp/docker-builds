ARG DEBIAN_VERSION=trixie
ARG UNBOUND_VERSION=1.25.1

FROM debian:${DEBIAN_VERSION}-slim

ARG UNBOUND_VERSION

LABEL org.opencontainers.image.title="unbound-python" \
      org.opencontainers.image.description="Unbound DNS server built from source with cachedb and Python module support" \
      org.opencontainers.image.source="https://github.com/ybbapp/docker-builds"

ENV DEBIAN_FRONTEND=noninteractive

# Build from upstream source, following NLnetLabs/pythonunbound's approach, but
# also enable cachedb so the server can run module-config: "cachedb iterator python".
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      dns-root-data \
      dnsutils \
      libevent-dev \
      libhiredis-dev \
      libssl-dev \
      pkg-config \
      python3 \
      python3-dev \
      swig && \
    curl -fsSLo /tmp/unbound.tar.gz "https://www.nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz" && \
    mkdir -p /tmp/unbound-src && \
    tar -xzf /tmp/unbound.tar.gz -C /tmp/unbound-src --strip-components=1 && \
    cd /tmp/unbound-src && \
    PYTHON_VERSION=3 ./configure \
      --prefix=/usr/local \
      --sysconfdir=/etc \
      --localstatedir=/var \
      --runstatedir=/run \
      --with-pidfile=/run/unbound/unbound.pid \
      --with-rootkey-file=/usr/share/dns/root.key \
      --with-libevent \
      --with-libhiredis \
      --with-pyunbound \
      --with-pythonmodule \
      --enable-cachedb && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig && \
    useradd --system --home /var/lib/unbound --shell /usr/sbin/nologin unbound && \
    mkdir -p /etc/unbound/python /etc/unbound/unbound.conf.d /var/lib/unbound /run/unbound && \
    chown -R unbound:unbound /var/lib/unbound /run/unbound /etc/unbound/python && \
    cd / && \
    rm -rf /tmp/unbound.tar.gz /tmp/unbound-src /var/lib/apt/lists/*

COPY unbound.conf /etc/unbound/unbound.conf
COPY noop.py /etc/unbound/python/noop.py
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    chown unbound:unbound /etc/unbound/python/noop.py && \
    python3 -c "import unbound; print('pyunbound ok')" && \
    test -f /usr/local/lib/python3.13/dist-packages/unboundmodule.py && \
    unbound -V 2>&1 | tee /tmp/unbound-version.txt && \
    grep -q -- '--with-pythonmodule' /tmp/unbound-version.txt && \
    grep -q -- '--enable-cachedb' /tmp/unbound-version.txt && \
    grep -q 'Linked modules: .*python.*cachedb.*iterator' /tmp/unbound-version.txt && \
    rm /tmp/unbound-version.txt

EXPOSE 53/tcp 53/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
  CMD dig @127.0.0.1 example.com A +time=3 +tries=1 +short >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-d", "-c", "/etc/unbound/unbound.conf"]
