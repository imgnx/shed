#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tests=()
while IFS= read -r -d '' f; do tests+=("$f"); done < <(find "$ROOT_DIR/tests" -maxdepth 1 -type f -name 'test_*.sh' -print0 | sort -z)

pass=0; fail=0
for t in "${tests[@]}"; do
  printf 'Running %s... ' "$(basename "$t")"
  if bash "$t" >/tmp/shed-test.out 2>/tmp/shed-test.err; then
    echo OK; pass=$((pass+1))
  else
    echo FAIL; fail=$((fail+1))
    echo '--- STDOUT ---'; cat /tmp/shed-test.out || true
    echo '--- STDERR ---'; cat /tmp/shed-test.err || true
  fi
done

echo "Passed: $pass  Failed: $fail"
[[ $fail -eq 0 ]]

