#!/usr/bin/env bash
# memento-curate: promote a curated inbox entry into a canonical room.
# Goes through `palace file` so every write gate applies, then removes the
# inbox entry, rebuilds the index, and verifies with doctor.
#
# Usage:
#   promote.sh <inbox-file> --room <room> --title "..." \
#              --anchor <path> [--anchor <path>]... --body "curated text"
set -euo pipefail

INBOX_FILE="${1:?usage: promote.sh <inbox-file> --room R --title T --anchor P --body '...'}"
shift
[ -f "$INBOX_FILE" ] || { echo "promote.sh: $INBOX_FILE does not exist" >&2; exit 1; }
command -v palace >/dev/null 2>&1 || { echo "promote.sh: palace CLI is required (npm i -g github:sychus/long-horizon)" >&2; exit 1; }

ROOM="" TITLE="" BODY=""
ANCHOR_FLAGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --room)   ROOM="$2"; shift 2 ;;
    --title)  TITLE="$2"; shift 2 ;;
    --anchor) ANCHOR_FLAGS+=(--anchor "$2"); shift 2 ;;
    --body)   BODY="$2"; shift 2 ;;
    *) echo "promote.sh: unknown argument $1" >&2; exit 1 ;;
  esac
done

[ -n "$ROOM" ] && [ -n "$TITLE" ] && [ -n "$BODY" ] || { echo "promote.sh: --room, --title and --body are required" >&2; exit 1; }
if [ ${#ANCHOR_FLAGS[@]} -eq 0 ] && [ "$ROOM" != "glossary" ]; then
  echo "promote.sh: at least one --anchor is required (glossary is the only exception)" >&2
  exit 1
fi

palace file --room "$ROOM" --title "$TITLE" "${ANCHOR_FLAGS[@]}" --body "$BODY"
rm "$INBOX_FILE"
palace sync
palace doctor || { echo "promote.sh: doctor is unhappy — fix the map before moving on" >&2; exit 1; }
echo "promoted → $ROOM: $TITLE (inbox entry removed, index rebuilt, doctor green)"
