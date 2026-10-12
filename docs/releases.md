# Releases

A release is named after the Exim version plus a revision: `4.100.1-r1`, `4.100.1-r2`, and so on. The revision goes up each time the image is rebuilt for the same Exim version, for a new Debian base or a change of build options, and restarts at `r1` with a new Exim version.

## Publishing

`release.yml` runs on every push to `main` that touches `Containerfile` or `Makefile-Linux`, and by hand from the Actions tab. It:

1. reads `EXIM_VERSION` from the `Containerfile` and picks the next free revision from the existing tags;
2. builds the image natively on an amd64 and an arm64 runner, runs the smoke test, and pushes each image by digest;
3. joins both into one multi-arch image tagged `<version>-r<revision>`, `<version>`, `<major>.<minor>`, `<major>` and `latest`;
4. attests its build provenance and creates the GitHub release and its tag.

## Updates

Renovate opens the pull requests:

- a new Exim release, from the `exim-X.Y.Z` tags of `https://code.exim.org/exim/exim.git`, release candidates excluded;
- a new digest or point release of the `debian:13-slim` base image, which brings the Debian security fixes;
- GitHub Actions, grouped, on Monday mornings.

Minor, patch and digest updates merge on their own once the CI is green, and each merge into `Containerfile` publishes a release. A major update (Exim 5, Debian 14) waits for a review.

When a new Exim release does not build, look at the options in `Makefile-Linux`: upstream sometimes renames or drops one.
