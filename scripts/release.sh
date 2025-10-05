#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <new-version>" >&2
  exit 1
fi

ver="$1"
date_str="$(date +%F)"

echo "Bumping version to $ver"
sed -i.bak -E "s/^(\s*version\) echo \"shed )([0-9A-Za-z\.-]+)(\"; exit 0 ;;)$/\\1$ver\\3/" bin/shed || {
  echo "Failed to update version in bin/shed" >&2; exit 1; }
rm -f bin/shed.bak

echo "Updating CHANGELOG.md"
awk -v ver="$ver" -v d="$date_str" 'BEGIN{printed=0}
  NR==1{print; next}
  !printed {print "\n## ["ver"] - "d"\n- Describe changes here."; printed=1}
  {print}
' CHANGELOG.md > CHANGELOG.md.new && mv CHANGELOG.md.new CHANGELOG.md

echo "Done. Consider committing and tagging:"
echo "  git add bin/shed CHANGELOG.md && git commit -m \"release: v$ver\" && git tag v$ver"

