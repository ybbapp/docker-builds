# syntax=docker/dockerfile:1

FROM golang:1.24-alpine AS builder

ARG VERSION
ARG TARGETARCH

RUN apk add --no-cache git

WORKDIR /src
RUN git clone --depth 1 --branch "v${VERSION}" https://github.com/SagerNet/sing-box.git .

ENV CGO_ENABLED=0
ENV TAGS="with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,with_clash_api,with_v2ray_api,with_tailscale,with_ccm,with_ocm,with_cloudflared,badlinkname,tfogo_checklinkname0"

RUN go build -trimpath \
    -tags "${TAGS}" \
    -ldflags "-s -w -checklinkname=0 -X 'internal/godebug.defaultGODEBUG=multipathtcp=0' -X github.com/sagernet/sing-box/constant.Version=${VERSION}" \
    -o /usr/bin/sing-box \
    ./cmd/sing-box

FROM alpine:3

RUN apk add --no-cache tzdata ca-certificates

COPY --from=builder /usr/bin/sing-box /usr/bin/sing-box

ENTRYPOINT ["/usr/bin/sing-box"]
CMD ["run", "-c", "/etc/sing-box/config.json"]
