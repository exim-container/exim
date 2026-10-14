FROM docker.io/library/debian:13.7-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f AS base

ENV EXIM_VERSION=4.100.1
ENV DEBIAN_SNAPSHOT=20261014T141111Z

RUN \
    rm -f /etc/apt/sources.list.d/debian.sources && \
    printf '%s\n' \
        'Types: deb' \
        "URIs: http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT}" \
        'Suites: trixie trixie-updates' \
        'Components: main' \
        'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
        '' \
        'Types: deb' \
        "URIs: http://snapshot.debian.org/archive/debian-security/${DEBIAN_SNAPSHOT}" \
        'Suites: trixie-security' \
        'Components: main' \
        'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
        > /etc/apt/sources.list.d/debian.sources && \
    printf '%s\n' \
        'Acquire::Check-Valid-Until "false";' \
        'Acquire::Retries "5";' \
        > /etc/apt/apt.conf.d/99snapshot

FROM base AS builder

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        libdb-dev \
        libssl-dev \
        libpcre2-dev \
        libsasl2-dev \
        libldap2-dev \
        libpam0g-dev \
        libsqlite3-dev \
        libmariadb-dev \
        libmariadb-dev-compat \
        libpq-dev \
        libspf2-dev \
        libgsasl-dev \
        libopendmarc-dev \
        libnsl-dev \
        libjansson-dev \
        libperl-dev \
        ca-certificates

RUN git clone --depth 1 --branch "exim-${EXIM_VERSION}" https://code.exim.org/exim/exim.git /build/exim

COPY Makefile-Linux /build/exim/src/Local/Makefile-Linux

RUN \
    cp /build/exim/src/src/EDITME /build/exim/src/Local/Makefile && \
    cp /build/exim/src/exim_monitor/EDITME /build/exim/src/Local/eximon.conf && \
    make -C /build/exim/src install

FROM base

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        libperl5.40 \
        libmariadb3 \
        libldap2 \
        libsqlite3-0 \
        libsasl2-2 \
        libpq5 \
        libjansson4 \
        libgsasl18 \
        libopendmarc2 \
        netbase \
        ca-certificates \
        publicsuffix && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/apt/* /var/log/dpkg.log /var/log/alternatives.log

RUN \
    groupadd -g 1000 exim && \
    useradd -u 1000 -g exim -d /var/spool/exim -s /bin/false exim && \
    ln -s /usr/sbin/exim /usr/sbin/sendmail && \
    ln -s /usr/sbin/exim /usr/sbin/mailq && \
    ln -s /usr/sbin/exim /usr/sbin/newaliases && \
    mkdir -p /etc/exim /var/spool/exim/input /var/spool/exim/msglog /var/spool/exim/db /var/log/exim && \
    ln -s /dev/stdout /var/log/exim/main.log && \
    ln -s /dev/stderr /var/log/exim/panic.log && \
    ln -s /dev/stderr /var/log/exim/reject.log && \
    chown -R exim:exim /var/spool/exim /var/log/exim

COPY --from=builder /etc/exim/ /etc/exim/
COPY --from=builder /usr/sbin/exim /usr/sbin/exim

USER exim
WORKDIR /var/spool/exim
EXPOSE 25

VOLUME ["/etc/exim", "/var/spool/exim"]

CMD ["/usr/sbin/exim", "-bdf", "-q5m"]
