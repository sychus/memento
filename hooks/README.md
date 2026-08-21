# Hooks — closing the loop mechanically

A learning loop that depends on the model *remembering* to load and save lessons isn't a loop — it's a hope. These hooks make the recall side fire deterministically in Claude Code.

## SessionStart → recall

`settings.example.json` wires `memento-recall/scripts/recall.sh` into the `SessionStart` hook. Its stdout is injected into the session context, so every session in a palace-enabled repo starts with the lessons anchored to the files currently in flight (`git diff --name-only`) plus a semantic pass on the last commit subject.

The script is hook-safe by design: in a repo without `.palace/` it exits 0 silently, so you can wire it globally in `~/.claude/settings.json` and it only speaks where a palace exists.

## Installing

1. Install the skills first (`cp -r skills/memento-* ~/.claude/skills/`).
2. Merge the `hooks` block from `settings.example.json` into your `~/.claude/settings.json` (global) or the project's `.claude/settings.json` (per-repo).
3. Start a new session — hooks are loaded at startup.

## The capture side

Capture is intentionally **not** a blind hook: filing a lesson requires judgment (was there a real outcome? what's the lesson?), so it stays an explicit act — the `memento-learn` skill, or `kickback.sh` run when QA bounces a ticket. What you *can* automate is the trigger: if your team has CI/webhook access to "changes requested" or ticket-kickback events, point that automation at `kickback.sh` so the raw lesson is staged the moment the ground-truth signal fires, and curation finds it waiting.
