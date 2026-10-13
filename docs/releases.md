# Releases

A release is named after the Exim version plus a revision: `4.100.1-r1`, `4.100.1-r2`, and so on. The revision goes up each time the image is rebuilt for the same Exim version, for a new Debian base or a change of build options, and restarts at `r1` with a new Exim version.

## Debian packages

Every package, including those of the base image, comes from one [snapshot](https://snapshot.debian.org/) of the Debian archive, set by `DEBIAN_SNAPSHOT` in the `Containerfile`: apt reads `trixie`, `trixie-updates` and `trixie-security` as they were at that moment, and upgrades the base packages to it. A snapshot never changes nor disappears, so rebuilding any commit gives the same package versions, years later.

## Publishing

`release.yml` runs on every push to `main` that touches `Containerfile` or `Makefile-Linux`, and by hand from the Actions tab. It:

1. reads `EXIM_VERSION` from the `Containerfile` and picks the next free revision from the existing tags;
2. builds the image natively on an amd64 and an arm64 runner, runs the smoke test, lists the installed packages, and pushes each image by digest;
3. compares the Exim version, the build files (apart from the snapshot line) and the package lists with the `release.txt` of the previous release, and stops there if nothing changed;
4. otherwise joins both images into one multi-arch image tagged `<version>-r<revision>`, `<version>`, `<major>.<minor>`, `<major>` and `latest`, attests its build provenance, and creates the GitHub release with its `release.txt` and the list of updated packages;
5. deletes the untagged images left behind.

A manual run with `force` publishes even when nothing changed.

## Updates

Renovate opens the pull requests:

- a new Exim release, from the `exim-X.Y.Z` tags of `https://code.exim.org/exim/exim.git`, release candidates excluded;
- the latest `debian-security` snapshot, whenever Renovate runs, from `https://snapshot.debian.org/mr/timestamp/?archive=debian-security`;
- a new digest or point release of the `debian:13-slim` base image;
- GitHub Actions, grouped, on Monday mornings.

Exim minor and patch releases, snapshots and digests merge on their own once the CI is green. A snapshot that changes none of the installed packages merges without publishing anything. A major update (Exim 5, Debian 14) waits for a review.

When a new Exim release does not build, look at the options in `Makefile-Linux`: upstream sometimes renames or drops one.
