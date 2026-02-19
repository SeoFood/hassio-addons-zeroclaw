ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:bookworm

FROM rust:1.93-slim-bookworm AS builder
ARG ZEROCLAW_VERSION=v0.1.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src
RUN git clone --depth 1 --branch "${ZEROCLAW_VERSION}" https://github.com/zeroclaw-labs/zeroclaw.git

WORKDIR /usr/src/zeroclaw
RUN cargo build --release --locked \
    && install -D target/release/zeroclaw /usr/local/bin/zeroclaw \
    && strip /usr/local/bin/zeroclaw

FROM ${BUILD_FROM}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        git \
        jq \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/zeroclaw /usr/local/bin/zeroclaw
COPY run.sh /run.sh
RUN chmod a+x /run.sh

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Marco SeoFood" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="ZeroClaw Home Assistant Add-ons" \
    org.opencontainers.image.authors="Marco" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/SeoFood/hassio-addons-zeroclaw" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

CMD ["/run.sh"]
