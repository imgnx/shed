#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

tmpdir="$(mktemp -d)"; trap 'rm -rf "$tmpdir"' EXIT

# Fake uname to force Linux path
cat >"$tmpdir/uname" <<'EOS'
#!/usr/bin/env bash
echo Linux
EOS
chmod +x "$tmpdir/uname"

# Fake nice to capture arguments; no ionice present
cat >"$tmpdir/nice" <<'EOS'
#!/usr/bin/env bash
echo "$@"
exit 0
EOS
chmod +x "$tmpdir/nice"

PATH="$tmpdir:$PATH"

out_bg="$("$ROOT_DIR/bin/shed" bg echo hi)"
out_work="$("$ROOT_DIR/bin/shed" work echo hi)"
out_focus="$("$ROOT_DIR/bin/shed" focus echo hi)"

case "$out_bg" in
  "-n +10 echo hi"|"+10 echo hi") : ;; * ) echo "bg fallback unexpected: $out_bg" >&2; exit 1;; esac
case "$out_work" in
  "-n 0 echo hi"|"0 echo hi") : ;; * ) echo "work fallback unexpected: $out_work" >&2; exit 1;; esac
case "$out_focus" in
  "-n -5 echo hi"|"-5 echo hi") : ;; * ) echo "focus fallback unexpected: $out_focus" >&2; exit 1;; esac
