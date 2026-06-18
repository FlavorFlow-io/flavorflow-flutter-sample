#!/usr/bin/env bash
# Copy one contract fixture into assets/branding/ — i.e. simulate locally what
# FlavorFlow does at build time when it injects a client's branding artifact.
#
# Usage: ./scripts/apply-fixture.sh <fixture-name>
#   e.g. ./scripts/apply-fixture.sh dark_brand
set -euo pipefail

NAME="${1:-}"
if [ -z "$NAME" ]; then
  echo "usage: $0 <fixture-name>  (one of: $(ls test/fixtures | tr '\n' ' '))" >&2
  exit 1
fi

SRC="test/fixtures/$NAME"
if [ ! -f "$SRC/branding.json" ]; then
  echo "error: no fixture named '$NAME' (looked in $SRC)" >&2
  exit 1
fi

mkdir -p assets/branding
cp "$SRC/branding.json" assets/branding/branding.json
cp "$SRC/logo.png"      assets/branding/logo.png
echo "Applied fixture '$NAME' to assets/branding/."
