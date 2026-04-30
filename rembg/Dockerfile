FROM python:3.11-slim

WORKDIR /app

ARG MODEL=u2net

# System deps: libgomp for onnxruntime, curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgomp1 curl && \
    rm -rf /var/lib/apt/lists/*

# Install rembg with CPU + CLI extras from PyPI
RUN pip install --no-cache-dir "rembg[cpu,cli]"

# Pre-download default model at build time (avoids cold-start download)
RUN rembg d ${MODEL}

EXPOSE 7000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s \
  CMD curl -f http://localhost:7000/api || exit 1

ENTRYPOINT ["rembg"]
CMD ["s"]
