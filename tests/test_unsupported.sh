#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# Create a temp dir with a fake uname that returns an unsupported OS
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/uname" <<'EOS'
#!/usr/bin/env bash
echo "Haiku"
EOS
chmod +x "$tmpdir/uname"

PATH="$tmpdir:$PATH" "$ROOT_DIR/bin/shed" bg echo hi 2>"$tmpdir/err" && exit 1 || rc=$?

test "$rc" -eq 2
grep -q "unsupported OS" "$tmpdir/err"

