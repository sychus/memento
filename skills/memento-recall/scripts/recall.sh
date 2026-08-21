#!/usr/bin/env bash
# memento-recall: retrieve lessons relevant to the current task.
#   Pass 1 — anchor match: drawers that reference any of the given file paths.
#   Pass 2 — semantic:     `palace search` over the local embedding index.
# Zero LLM cost. Safe to run from hooks: exits 0 quietly when there is no palace.
#
# Usage: recall.sh "<task summary>" [changed-file ...]
set -uo pipefail

QUERY="${1:-}"
shift 2>/dev/null || true

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PALACE="$ROOT/.palace"
[ -d "$PALACE" ] || exit 0

command -v rg >/dev/null 2>&1 || { echo "memento-recall: ripgrep (rg) is required" >&2; exit 1; }

# Print a whole drawer file without cat (rg matches every line with '^').
print_drawer() { echo "--- $1"; rg -N '^' "$1"; }

echo "## Memento recall"

if [ "$#" -gt 0 ]; then
  echo
  echo "### Lessons anchored to your files"
  HITS=""
  for f in "$@"; do
    [ -n "$f" ] || continue
    # NOTE: when several globs match, ripgrep lets the LAST one win — the
    # inbox exclusion must come after the *.md include or raw lessons leak.
    MATCHES="$(rg -l --fixed-strings -g '*.md' -g '!**/inbox/**' "$f" "$PALACE" 2>/dev/null || true)"
    [ -n "$MATCHES" ] && HITS="$HITS$MATCHES"$'\n'
  done
  UNIQUE="$(printf '%s' "$HITS" | sort -u | awk 'NF && NR<=15')"
  if [ -n "$UNIQUE" ]; then
    while IFS= read -r drawer; do print_drawer "$drawer"; done <<< "$UNIQUE"
  else
    echo "(none — no drawer anchors any of these files)"
  fi
fi

if [ -n "$QUERY" ] && command -v palace >/dev/null 2>&1; then
  echo
  echo "### Semantically related"
  palace search "$QUERY" 2>/dev/null || echo "(palace search unavailable — index not built? run: palace sync)"
fi
