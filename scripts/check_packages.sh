#!/usr/bin/env bash
set -euo pipefail
file="packages-repository.txt"
while IFS= read -r line; do
  if [[ "$line" == '```'* ]]; then
    continue
  fi
  pkg=$(printf "%s" "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')
  [ -z "$pkg" ] && continue
  if pacman -Si "$pkg" >/dev/null 2>&1; then
    echo "FOUND: $pkg"
  else
    echo "MISSING: $pkg"
  fi
done < "$file"
