#!/usr/bin/env bash
set -euo pipefail

check_file() {
  local file="$1" backend="$2"
  echo "=== Checking $file ($backend) ==="
  while IFS= read -r line; do
    pkg=$(printf "%s" "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')
    [ -z "$pkg" ] && continue
    if $backend -Si "$pkg" >/dev/null 2>&1; then
      echo "FOUND: $pkg"
    else
      echo "MISSING: $pkg"
    fi
  done < "$file"
}

check_file "packages-repository.txt" "pacman"

if command -v yay >/dev/null 2>&1; then
  check_file "packages-repository-aur.txt" "yay"
else
  echo "=== Skipping AUR check (yay not installed) ==="
fi
