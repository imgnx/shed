#!/usr/bin/env bash
set -euo pipefail
PREFIX="${PREFIX:-/usr/local}"
echo "Installing shed to $PREFIX/bin (requires sudo if not writable)"
install -d "$PREFIX/bin"
install -m 0755 bin/shed "$PREFIX/bin/shed"
echo "Optional: source contrib/zsh/focus-burst.zsh in your ~/.zshrc"

# Install completions if common locations exist
SHAREDIR="${SHAREDIR:-$PREFIX/share}"
if [[ -d "$SHAREDIR/bash-completion/completions" ]]; then
  echo "Installing bash completion to $SHAREDIR/bash-completion/completions/shed"
  install -d "$SHAREDIR/bash-completion/completions"
  install -m 0644 contrib/completions/shed.bash "$SHAREDIR/bash-completion/completions/shed"
fi
if [[ -d "$SHAREDIR/zsh/site-functions" ]]; then
  echo "Installing zsh completion to $SHAREDIR/zsh/site-functions/_shed"
  install -d "$SHAREDIR/zsh/site-functions"
  install -m 0644 contrib/completions/_shed "$SHAREDIR/zsh/site-functions/_shed"
fi
if [[ -d "$SHAREDIR/fish/vendor_completions.d" ]]; then
  echo "Installing fish completion to $SHAREDIR/fish/vendor_completions.d/shed.fish"
  install -d "$SHAREDIR/fish/vendor_completions.d"
  install -m 0644 contrib/completions/shed.fish "$SHAREDIR/fish/vendor_completions.d/shed.fish"
fi

# Install man page if man1 dir exists
if [[ -d "$SHAREDIR/man/man1" ]]; then
  echo "Installing man page to $SHAREDIR/man/man1/shed.1.gz"
  install -d "$SHAREDIR/man/man1"
  gzip -c docs/shed.1 > "$SHAREDIR/man/man1/shed.1.gz"
fi
