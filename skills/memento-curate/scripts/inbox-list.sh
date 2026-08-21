#!/usr/bin/env bash
# memento-curate: list raw lessons waiting in .palace/inbox/, oldest first.
# Usage: inbox-list.sh
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
INBOX="$ROOT/.palace/inbox"
[ -d "$INBOX" ] || { echo "no inbox at $INBOX"; exit 0; }

command -v rg >/dev/null 2>&1 || { echo "inbox-list.sh: ripgrep (rg) is required" >&2; exit 1; }

COUNT=0
for f in "$INBOX"/*.md; do
  [ -e "$f" ] || break
  COUNT=$((COUNT + 1))
  TITLE="$(rg -m1 -N '^title:' "$f" | awk '{sub(/^title:[ ]*/,""); print}')"
  TYPE="$(rg -m1 -N '^type:' "$f" | awk '{print $2}')"
  CREATED="$(rg -m1 -N '^created:' "$f" | awk '{print $2}')"
  printf '%s  [%s]  %s\n    %s\n' "${CREATED:-????-??-??}" "${TYPE:-?}" "${TITLE:-(untitled)}" "$f"
done

if [ "$COUNT" -eq 0 ]; then
  echo "inbox empty — the map is caught up"
else
  echo
  echo "$COUNT raw lesson(s) awaiting curation"
fi
