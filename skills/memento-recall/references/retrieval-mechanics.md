# Retrieval mechanics

## Contents
- Why two passes
- Pass 1: anchor matching
- Pass 2: semantic search
- Output format
- Edge cases
- Cross-wing retrieval

## Why two passes

Relevance has two independent axes:

- **Spatial** — "what do we know about *these exact files*?" Deterministic, exact, cheap. This is where the highest-signal lessons live: a pitfall anchored to `server/webhooks.ts` is near-certainly relevant when you edit that file.
- **Conceptual** — "what do we know about *this kind of problem*?" A timeout lesson learned in the import path may apply to the export path too. This needs embeddings, which MemPalace computes locally.

Neither pass ranks lessons against each other. There is no global score and no top-N cutoff by merit — the scope of the task bounds the result set, which is the whole point.

## Pass 1: anchor matching

Every canonical drawer carries `anchors:` — repo-relative paths it describes (see the palace skill). The script does a fixed-string search for each task file across `.palace/**/*.md`, excluding `inbox/` (raw, unverified lessons never auto-surface into context).

Notes:
- Matching is a fixed-string search over the drawer's **full text** (anchors and body alike): a drawer surfaces when it mentions the exact path anywhere. Directory-only anchors match a file under them only if the drawer's body lists that file — scan-generated module drawers do; hand-written drawers should anchor the specific files they describe.
- Output is capped at 15 drawers. If a single file matches more than that, the palace has a granularity problem — drawers are too thin or anchors too broad; flag it for `memento-curate`.
- Inbox exclusion is enforced in **both** passes: a ripgrep glob here, and a result-block filter on the semantic pass (the palace miner indexes `inbox/` too, so filtering only one path leaks raw lessons through the other).

## Pass 2: semantic search

`palace search "<query>"` queries the derived MemPalace index. Requirements:

- The index exists (`palace sync` has been run since the last filing).
- The `palace` CLI is installed (`npm i -g github:sychus/long-horizon`).

If either is missing the script degrades gracefully — pass 1 still works because the markdown is the source of truth.

## Output format

```
## Memento recall

### Lessons anchored to your files
--- /repo/.palace/runbooks/webhook-retry-storm.md
<full drawer content>

### Semantically related
<palace search results>
```

The full drawer is printed (not a snippet) because drawers are deliberately dense and short; a truncated lesson is a misleading lesson.

## Edge cases

- **No `.palace/`**: exits 0 silently. Hook-safe by design — the hook fires in every repo, the script only speaks where a palace exists.
- **Drawer flagged by doctor**: `palace doctor` output is not merged into recall (different lifecycle). If a recalled lesson looks wrong against current code, verify — anchors may have drifted since the last doctor run.
- **Empty results**: normal in a young palace. A miss followed by a hard-won discovery is exactly the trigger for `memento-learn`.

## Cross-wing retrieval

MemPalace searches reach across wings (projects) by default — a lesson from a sibling repo can surface. That is intended: the payments repo's webhook lesson may save the events repo. Scope with `palace search --room <room>` or a wing filter when it becomes noise.
