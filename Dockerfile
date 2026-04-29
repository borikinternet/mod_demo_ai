# syntax=docker/dockerfile:1.6
FROM debian:12

ARG APT_PROXY

RUN set -eux; \
    if [ -n "${APT_PROXY:-}" ]; then \
        printf 'Acquire::http::Proxy "%s";\nAcquire::https::Proxy "%s";\n' "${APT_PROXY:-}" "${APT_PROXY:-}" > /etc/apt/apt.conf.d/99proxy; \
    fi; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg2 \
        grep; \
    rm -f /etc/apt/apt.conf.d/99proxy; \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=secret,id=signalwire_token \
    set -eux; \
    if [ -n "${APT_PROXY:-}" ]; then \
        printf 'Acquire::http::Proxy "%s";\nAcquire::https::Proxy "%s";\n' "${APT_PROXY:-}" "${APT_PROXY:-}" > /etc/apt/apt.conf.d/99proxy; \
    fi; \
    TOKEN="$(cat /run/secrets/signalwire_token)"; \
    DOMAIN="freeswitch.signalwire.com"; \
    USERNAME="signalwire"; \
    GPG_KEY="/usr/share/keyrings/signalwire-freeswitch-repo.gpg"; \
    printf 'machine %s login %s password %s\n' "${DOMAIN}" "${USERNAME}" "${TOKEN}" > /etc/apt/auth.conf; \
    chmod 600 /etc/apt/auth.conf; \
    curl --fail --netrc-file /etc/apt/auth.conf --output "${GPG_KEY}" "https://${DOMAIN}/repo/deb/debian-release/signalwire-freeswitch-repo.gpg"; \
    printf 'Types: deb deb-src\nURIs: https://%s/repo/deb/debian-release/\nSuites: bookworm\nComponents: main\nSigned-By: %s\n' "${DOMAIN}" "${GPG_KEY}" > /etc/apt/sources.list.d/freeswitch.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libfreeswitch-dev \
        build-essential \
        pkg-config \
        cmake \
        clang \
        gdb; \
    apt-get build-dep -y freeswitch #; \
#    rm -f /etc/apt/apt.conf.d/99proxy; \
#    rm -f /etc/apt/auth.conf; \
#    rm -rf /var/lib/apt/lists/*;

VOLUME /usr/src/freeswitch

WORKDIR /usr/src/freeswitch