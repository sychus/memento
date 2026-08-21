#!/usr/bin/env bash
# memento-learn: file one lesson into .palace/inbox/ (staging — never canonical).
#
# Usage:
#   capture.sh --type pitfall|strategy|domain --title "..." --body "..." \
#              [--ref path]... [--source "PR/ticket url"]
set -euo pipefail

TYPE="" TITLE="" BODY="" SOURCE=""
REFS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --type)   TYPE="$2"; shift 2 ;;
    --title)  TITLE="$2"; shift 2 ;;
    --body)   BODY="$2"; shift 2 ;;
    --ref)    REFS+=("$2"); shift 2 ;;
    --source) SOURCE="$2"; shift 2 ;;
    *) echo "capture.sh: unknown argument $1" >&2; exit 1 ;;
  esac
done

case "$TYPE" in pitfall|strategy|domain) ;; *) echo "capture.sh: --type must be pitfall|strategy|domain" >&2; exit 1 ;; esac
[ -n "$TITLE" ] || { echo "capture.sh: --title is required" >&2; exit 1; }
[ ${#BODY} -ge 40 ] || { echo "capture.sh: --body must be at least 40 chars (the palace miner skips shorter drawers)" >&2; exit 1; }

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
INBOX="$ROOT/.palace/inbox"
[ -d "$ROOT/.palace" ] || { echo "capture.sh: no .palace/ here — run 'palace init' first" >&2; exit 1; }
mkdir -p "$INBOX"

SLUG="$(printf '%s' "$TITLE" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | awk '{gsub(/^-+|-+$/,""); print substr($0,1,60)}')"
DATE="$(date +%Y-%m-%d)"
OUT="$INBOX/$(date +%Y%m%d%H%M%S)-$SLUG.md"

{
  echo "---"
  echo "title: $TITLE"
  echo "type: $TYPE"
  echo "status: raw"
  echo "created: $DATE"
  [ -n "$SOURCE" ] && echo "source: $SOURCE"
  if [ ${#REFS[@]} -gt 0 ]; then
    echo "refs:"
    for r in "${REFS[@]}"; do echo "  - $r"; done
  fi
  echo "---"
  echo
  echo "$BODY"
} > "$OUT"

echo "filed: $OUT"
echo "status: raw — it will NOT surface in recall until promoted by memento-curate"
command -v palace >/dev/null 2>&1 && palace sync >/dev/null 2>&1 || true
