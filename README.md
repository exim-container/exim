# exim

Container image of the [Exim](https://www.exim.org/) mail transfer agent, built from the upstream release tags on Debian 13 (trixie), for `linux/amd64` and `linux/arm64`.

## Installation

```sh
docker run -d --name exim \
  -p 25:25 \
  -v "$(pwd)/exim.conf:/etc/exim/exim.conf:ro" \
  -v exim-spool:/var/spool/exim \
  ghcr.io/exim-container/exim:4
```

Tags: `4`, `4.<minor>`, `4.<minor>.<patch>`, `4.<minor>.<patch>-r<revision>` and `latest`. Every image is signed with a build provenance attestation:

```sh
gh attestation verify oci://ghcr.io/exim-container/exim:4 --owner exim-container
```

See [docs](docs/) for the build options, the runtime layout and the release process.
