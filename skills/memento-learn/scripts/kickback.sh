#!/usr/bin/env bash
# memento-learn: ingest a QA kickback / changes-requested PR as a pitfall lesson.
# Pulls the PR's changed files via gh so the lesson lands with anchor candidates attached.
#
# Usage: kickback.sh <pr-number-or-url> "the lesson" [--repo owner/name]
set -euo pipefail

PR="${1:?usage: kickback.sh <pr-number-or-url> \"lesson\" [--repo owner/name]}"
LESSON="${2:?a lesson body is required — what did this kickback teach us?}"
shift 2
REPO_ARGS=()
[ "${1:-}" = "--repo" ] && REPO_ARGS=(--repo "$2")

command -v gh >/dev/null 2>&1 || { echo "kickback.sh: gh CLI is required" >&2; exit 1; }

JSON="$(gh pr view "$PR" "${REPO_ARGS[@]}" --json title,url,files)"
TITLE="$(printf '%s' "$JSON" | jq -r '.title')"
URL="$(printf '%s' "$JSON" | jq -r '.url')"

REF_FLAGS=()
while IFS= read -r f; do
  [ -n "$f" ] && REF_FLAGS+=(--ref "$f")
done < <(printf '%s' "$JSON" | jq -r '.files[].path' | awk 'NR<=25')

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/capture.sh" --type pitfall \
  --title "Kickback: $TITLE" \
  --body "$LESSON" \
  --source "$URL" \
  "${REF_FLAGS[@]}"
