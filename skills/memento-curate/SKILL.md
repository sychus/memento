---
name: memento-curate
description: Reviews raw lessons in the project palace's inbox and promotes the ones that survive verification into canonical rooms — generalized, deduplicated, and anchored — then prunes what code changes or new automation have made obsolete. Use when the user asks to curate the palace, empty the inbox, or on a periodic maintenance pass; requires a repository with a .palace/ directory.
---

# memento-curate

The Curator. The **only** path into canonical memory. Everything before this step is staging; everything after it, the team relies on — so this skill is deliberately the slow, gated one.

## Workflow — per inbox entry

Copy this checklist and work through it for each entry:

```
Curation:
- [ ] 1. List inbox           (scripts/inbox-list.sh)
- [ ] 2. Verify against code  (is the lesson still true, right now?)
- [ ] 3. Generalize to class  (instance → pattern, without losing the anchor)
- [ ] 4. Dedupe               (palace search BEFORE filing — merge, don't multiply)
- [ ] 5. Promote or discard   (scripts/promote.sh / rm)
- [ ] 6. Doctor               (palace doctor — leave the map green)
```

**1. List** — `scripts/inbox-list.sh` shows every raw entry with age. Old raw entries are a smell: curate or discard, never let the inbox become a second, worse palace.

**2. Verify** — open the refs and check the lesson against the code *as it is today*. A lesson from a kicked-back PR may already be fixed, covered by a test, or wrong. If you cannot verify it, it does not get promoted.

**3. Generalize** — promote the *class*, keep the *instance* as evidence. Criteria and examples: [references/curation-playbook.md](references/curation-playbook.md).

**4. Dedupe** — `palace search "<essence of the lesson>"` first. If an existing drawer covers it: update that drawer (strengthen, add the new anchor, bump `updated:`) instead of filing a near-duplicate. Two drawers saying the same thing rank worse than one saying it well.

**5. Promote** — through the gates, never by hand-copying files:

```bash
scripts/promote.sh <inbox-file> --room <room> --title "..." \
  --anchor <path> [--anchor <path>] --body "curated lesson text"
```

Room choice guide and the discard criteria are in [references/curation-playbook.md](references/curation-playbook.md). Discarding is a valid outcome — `rm` the inbox entry and say why.

**6. Doctor** — `palace doctor` must exit clean. While there, act on its findings: a drawer whose anchors drifted gets re-verified or removed. **Prune** any lesson now enforced by an automated test or lint rule — automation supersedes memory.

## Rules

- Never promote a lesson you did not verify against current code. `reviewed: true` on an unchecked drawer poisons the whole map.
- Never write into rooms with `mempalace_add_drawer` or by creating files directly — `promote.sh` goes through `palace file`, which enforces the write gates.
- Ambiguous duplicates (same intent, different wording) are a human call: present both texts and ask; never silently merge or silently drop.
- This skill deletes only inbox entries and doctor-condemned drawers. It never touches source code.

## Details

- Generalization criteria, room selection, discard rules, pruning policy: [references/curation-playbook.md](references/curation-playbook.md)
