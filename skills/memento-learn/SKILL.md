---
name: memento-learn
description: Captures one actionable lesson from a real outcome into the project palace's inbox (staging area, never canonical). Use immediately after a QA kickback, a PR with changes requested, a failed approach, a discovered gotcha, or a confirmed-good pattern worth keeping — in any repository with a .palace/ directory.
---

# memento-learn

The Reflector. Turns an outcome into a filed lesson — into `.palace/inbox/` only. Promotion to a canonical room is a separate, gated step (`memento-curate`); nothing this skill writes can corrupt the map.

## Workflow

1. Identify the trigger — a lesson needs a *real outcome* behind it:
   - **External failure signal** (strongest): QA kickback, changes-requested review, reverted commit, production incident.
   - **Hard-won discovery**: an approach that failed, an undocumented behavior that cost time.
   - **Confirmed success**: a pattern that worked and would not be obvious to the next person.
2. Write the lesson so it can change a future decision — specific, falsifiable, anchored. Check it against [references/lesson-quality.md](references/lesson-quality.md) before filing; a vague lesson is worse than none.
3. File it:

   ```bash
   scripts/capture.sh --type pitfall|strategy|domain \
     --title "short title" \
     --body "the lesson — what happens, under what conditions, what to do instead" \
     --ref path/to/involved/file [--ref another/path] \
     --source "PR/ticket URL"
   ```

   For a QA kickback on a PR, use the wrapper — it pulls the changed files as refs automatically:

   ```bash
   scripts/kickback.sh <pr-number-or-url> "the lesson" [--repo owner/name]
   ```

4. One lesson per entry. Two lessons in one body = two capture calls.

## Rules

- **Inbox only.** Never write into `architecture/`, `decisions/`, or any canonical room from this skill, and never call `mempalace_add_drawer`.
- **No outcome, no lesson.** "This might be a problem" is a hunch, not a lesson — don't file hunches.
- **Always attach refs and source.** Refs become anchor candidates at curation time; the source (PR/ticket) is what lets a curator verify the lesson actually happened.

## Details

- What makes a lesson actionable, with good/bad examples: [references/lesson-quality.md](references/lesson-quality.md)
