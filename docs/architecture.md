# Memento — architecture notes

## Contents
- The ACE mapping, precisely
- Why the storage layer is a palace and not a playbook file
- Signals: where lessons come from
- The lifecycle of a lesson
- Team distribution
- What Memento deliberately does not do

## The ACE mapping, precisely

The ACE paper ([Zhang et al., 2025, arXiv:2510.04618](https://arxiv.org/abs/2510.04618)) structures self-improvement as three roles operating on an itemized, delta-updated playbook:

| ACE role | Memento implementation | Authority |
|---|---|---|
| **Generator** — performs the task using the playbook | The working agent, fed by `memento-recall` (hook-driven) | read-only |
| **Reflector** — extracts lessons from outcomes | `memento-learn` → `.palace/inbox/` | writes to staging only |
| **Curator** — merges lessons as incremental deltas | `memento-curate` → `palace file` into rooms | sole write path to canonical memory, gated |

The paper's two failure modes and how each is handled:

- **Context collapse** (wholesale rewrites lose detail): nothing in Memento ever rewrites accumulated memory in bulk. Lessons are individual files; updates are per-drawer deltas; `palace scan` never overwrites reviewed drawers.
- **Brevity bias** (iteration drifts toward generic advice): the quality bar is enforced at both ends — capture (`lesson-quality.md`: specific, falsifiable, consequential) and curation (generalize to the *class* without losing the anchor; "a precise instance beats a mushy generalization").

Where Memento deliberately departs from the reference ACE-style implementations: **no helpful/harmful counters, no global score, no top-N selection.** See the next section for why.

## Why the storage layer is a palace and not a playbook file

Single-file scored playbooks (e.g. [self-learning-claude](https://github.com/reshadat/self-learning-claude)) select by `helpful_count - harmful_count` with a global cap. Four structural problems:

1. **Score measures the past, not the present task.** A lesson helpful ten times in January outranks the one you need today. Memento replaces merit-competition with *scope*: retrieval is bounded by the task's files (anchors) and meaning (semantic search), so nothing needs to compete for slots.
2. **Read-modify-write on one JSON** loses updates under concurrency and is unmergeable in git. Memento's unit of storage is one markdown file per lesson; git handles the rest.
3. **Counter-based staleness is statistics; anchor-based staleness is evidence.** `palace doctor` proves a lesson suspect the moment its anchored code moves — no usage data required.
4. **A blob can't be reviewed.** `.palace/` changes go through pull requests like code, which is what keeps a *shared* memory honest.

The derived index (MemPalace's embedding store) is rebuildable at any time (`palace sync`); losing it is never data loss. Source of truth stays diffable, greppable, reviewable.

## Signals: where lessons come from

Ranked by trust:

1. **External ground truth** — QA kickback, changes-requested review, revert, incident. Somebody *other than the author* established the failure. `kickback.sh` ingests these with the PR's changed files attached as anchor candidates.
2. **Hard-won discovery** — an approach that failed in front of the agent, an undocumented behavior verified by direct experiment.
3. **Self-assessed success** — the weakest signal, which is precisely why in Memento it can only reach staging. An agent grading its own work as "helpful" is the known bias of self-report loops; the curation gate (verify against code, evidence required) is the correction.

## The lifecycle of a lesson

```
outcome ──capture──▶ inbox (raw, never surfaces in recall)
                        │
                   curation gate: verify → generalize → dedupe → anchor
                        │                                   │
                     promote                             discard (with reason)
                        │
                   canonical drawer ──recall──▶ future task context
                        │
                   doctor / pruning:
                     · anchors drift → re-verify or remove
                     · automation now covers it → remove
                     · contradicted by review → remove
```

A lesson has three exits, and two of them are deletions. That asymmetry is the design: the map must stay small and right, because every drawer recalled into context spends attention.

## Team distribution

`.palace/` and the memento skills travel in git; each machine rebuilds its own local index. That gives cross-pollination without infrastructure:

- Lessons reach teammates as **reviewable PRs**, not silent state mutations.
- A bad lesson gets caught in review — the same immune system code has.
- No shared database, no sync service, no conflict resolution beyond git's, which markdown-per-lesson makes trivial.

For an organization: the memento skills live in the shared tooling repo; each product repo carries its own `.palace/`. Cross-project lessons travel through MemPalace's cross-wing search on each machine that has both wings mined.

## What Memento deliberately does not do

- **No automatic capture.** Filing requires judgment about whether an outcome carries a lesson; automating it fills the inbox with narration. Automate the *trigger* (kickback webhooks → `kickback.sh`), not the judgment.
- **No LLM in the retrieval path.** Recall is ripgrep + a local embedding index. Bookkeeping that costs tokens eventually gets skipped; bookkeeping that costs nothing runs every time.
- **No self-scoring.** The system never asks the agent "was this lesson helpful?" — the honest version of that signal already exists (did the work survive review?) and arrives from outside.
