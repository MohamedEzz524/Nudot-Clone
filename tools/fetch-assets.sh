#!/usr/bin/env bash
# Re-sync the local mirror with the live site.
# Re-downloads any asset listed in assets_all.txt that is missing or empty locally.
# Run from anywhere:  bash tools/fetch-assets.sh
set -u
cd "$(dirname "$0")/.." || exit 1          # -> project root
LIST="tools/assets_all.txt"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
BASE="https://nudot.com.tw"

[ -f "$LIST" ] || { echo "Missing $LIST"; exit 1; }
ok=0; skip=0; fail=0
while IFS= read -r a; do
  [ -z "$a" ] && continue
  if [ -f "$a" ] && [ -s "$a" ]; then skip=$((skip+1)); continue; fi
  mkdir -p "$(dirname "$a")"
  code=$(curl -s --max-time 300 -o "$a" -w "%{http_code}" -A "$UA" "$BASE/$a")
  if [ "$code" = "200" ] && [ -s "$a" ]; then
    ok=$((ok+1)); echo "  OK   $a"
  else
    fail=$((fail+1)); echo "  FAIL $code $a"; rm -f "$a"
  fi
done < "$LIST"
echo "Done. downloaded=$ok  already-present=$skip  failed=$fail"
