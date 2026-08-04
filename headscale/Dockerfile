ARG GO_VERSION=1.26.5

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-bookworm AS build

ARG SOURCE_REPOSITORY=ybbapp/headscale-edition
ARG SOURCE_TAG=v0.29.3-home
ARG TARGETARCH

WORKDIR /src

RUN git clone --depth 1 --branch "${SOURCE_TAG}" \
    "https://github.com/${SOURCE_REPOSITORY}.git" .

RUN CGO_ENABLED=0 GOOS=linux GOARCH="${TARGETARCH}" \
    go build -trimpath -ldflags="-s -w" -o /out/headscale ./cmd/headscale

FROM gcr.io/distroless/base-debian13:nonroot

COPY --from=build /out/headscale /headscale

ENTRYPOINT ["/headscale"]
