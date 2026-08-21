---
name: memento-recall
description: Retrieves past lessons relevant to the current task from the project's memory palace, matching by file anchors and semantic search. Use at the start of any coding task, bug fix, refactor, or review in a repository that has a .palace/ directory, or when the user asks what is already known about a file, module, or error.
---

# memento-recall

Read-only. Pulls the lessons that matter for *this* task — never a global top-N.

## Workflow

1. Identify the task context:
   - **Files**: the paths you are about to touch (`git diff --name-only`, the ticket's affected files, or the files the user named).
   - **Query**: one line summarizing the task ("fix attendee bulk import timeout").
2. Run the retrieval script — it does both passes (anchored + semantic) with zero LLM cost:

   ```bash
   scripts/recall.sh "<task summary>" <file> [<file> ...]
   ```

3. Treat the output as prior experience, not gospel:
   - Lessons **anchored to your files** are the highest-signal — someone got burned exactly here.
   - Semantic hits are context — related, not necessarily applicable.
   - A lesson flagged stale by `palace doctor` is suspect; verify against current code before relying on it.
4. If retrieval surfaces nothing and you later learn something the hard way, that is the trigger for `memento-learn` — the map grows where it was needed and missing.

## Rules

- Never write to the palace from this skill. Capture belongs to `memento-learn`; promotion to `memento-curate`.
- If there is no `.palace/` in the repo, say so and continue the task normally — do not create one unprompted.
- Prefer `scripts/recall.sh` over calling MCP search tools ad hoc: the script is deterministic, works when MCP tools are not loaded, and combines both retrieval passes.

## Details

- How anchor matching and the semantic pass actually work, output format, edge cases: [references/retrieval-mechanics.md](references/retrieval-mechanics.md)
