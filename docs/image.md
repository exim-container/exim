# Image

## Build options

`Makefile-Linux` is copied to `src/Local/Makefile-Linux` next to the upstream `src/src/EDITME`, copied as `src/Local/Makefile`. Exim's build reads `Local/Makefile` then `Local/Makefile-Linux`, and the last assignment wins, so `Makefile-Linux` only lists the options that differ from upstream.

- TLS: OpenSSL
- Mailbox formats: maildir, mailstore, mbx
- Transports: LMTP
- Lookups: cdb, dsearch, JSON, LDAP (OpenLDAP 2), MySQL (MariaDB), passwd, PostgreSQL, SQLite, lsearch, dnsdb
- Authenticators: CRAM-MD5, Cyrus SASL, Dovecot, GSASL, PLAIN, SPA, TLS
- Content scanning, DMARC (public suffix list), SPF, Perl, PAM, SOCKS, proxy protocol, UTF-8 headers, IPv6

## Runtime layout

- Binary: `/usr/sbin/exim`, also linked as `sendmail`, `mailq` and `newaliases`
- Configuration: `/etc/exim/exim.conf`, the upstream default until one is mounted
- Spool: `/var/spool/exim`
- Logs: `/var/log/exim/{main,panic,reject}.log`, linked to stdout and stderr
- User: `exim`, UID and GID 1000; a mounted spool must belong to them
- Volumes: `/etc/exim`, `/var/spool/exim`
- Command: `/usr/sbin/exim -bdf -q5m`, the daemon in the foreground with a queue run every 5 minutes

## Smoke test

`scripts/smoke-test.sh <image>` checks the reported version against `EXIM_VERSION`, looks for missing shared libraries and waits for the SMTP banner of the daemon. The CI runs it on both architectures.

```sh
docker build -f Containerfile -t exim:test .
scripts/smoke-test.sh exim:test
```
