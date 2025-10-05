#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
out="$("$ROOT_DIR/bin/shed" version)"
test "$out" = "shed 0.1.1"

