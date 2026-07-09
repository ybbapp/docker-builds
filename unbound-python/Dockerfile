ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}-slim

LABEL org.opencontainers.image.title="unbound-python" \
      org.opencontainers.image.description="Python runtime with libunbound Python bindings" \
      org.opencontainers.image.source="https://github.com/ybbapp/docker-builds"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# python3-unbound is Debian's official Python binding for libunbound.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      dns-root-data \
      python3 \
      python3-unbound && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/local/bin/python

# Smoke-check the Python binding during build.
RUN python -c "import unbound; ctx = unbound.ub_ctx(); status, result = ctx.resolve('example.com', unbound.RR_TYPE_A, unbound.RR_CLASS_IN); assert status == 0, status; assert result.havedata; print('python-unbound ok')"

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
  CMD python -c "import unbound; ctx = unbound.ub_ctx(); status, result = ctx.resolve('example.com', unbound.RR_TYPE_A, unbound.RR_CLASS_IN); raise SystemExit(0 if status == 0 and result.havedata else 1)" || exit 1

CMD ["python"]
