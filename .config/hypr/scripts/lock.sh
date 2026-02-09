#!/usr/bin/env bash
set -euo pipefail

if command -v hyprlock >/dev/null 2>&1; then
  exec hyprlock
else
  echo "hyprlock not installed" >&2
  exit 1
fi
