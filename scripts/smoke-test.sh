#!/usr/bin/env bash
set -euo pipefail

image="$1"
name="exim-smoke-test-$$"

trap 'docker rm -f "${name}" > /dev/null 2>&1 || true' EXIT

expected="$(docker run --rm "${image}" printenv EXIM_VERSION)"
version="$(docker run --rm "${image}" exim -bV | sed -n 's/^Exim version \([^ ]*\) .*/\1/p')"
if [ "${version}" != "${expected}" ]; then
  echo "exim reports version '${version}', expected '${expected}'" >&2
  exit 1
fi

missing="$(docker run --rm "${image}" ldd /usr/sbin/exim | grep 'not found' || true)"
if [ -n "${missing}" ]; then
  echo "missing libraries:" >&2
  echo "${missing}" >&2
  exit 1
fi

docker run --rm "${image}" exim -bV | sed -n '/^Lookups/,$p'

docker run -d --name "${name}" "${image}" > /dev/null
for _ in $(seq 1 30); do
  if banner="$(docker exec "${name}" bash -c 'exec 3<>/dev/tcp/127.0.0.1/25 && head -n 1 <&3' 2>/dev/null)"; then
    break
  fi
  sleep 1
done
if [[ "${banner:-}" != 220* ]]; then
  echo "no SMTP banner from the daemon" >&2
  docker logs "${name}" >&2
  exit 1
fi
echo "${banner}"
