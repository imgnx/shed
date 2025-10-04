#!/usr/bin/env bash
set -euo pipefail
PREFIX="${PREFIX:-/usr/local}"
echo "Installing shed to $PREFIX/bin (requires sudo if not writable)"
install -d "$PREFIX/bin"
install -m 0755 bin/shed "$PREFIX/bin/shed"
echo "Optional: source contrib/zsh/focus-burst.zsh in your ~/.zshrc"
