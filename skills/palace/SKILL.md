# Palace Skill

## Purpose

Maintain a per-project memory palace: a curated, verifiable map of a codebase's
architecture, decisions, documentation, tests, runbooks and vocabulary.

The palace is not a transcript archive. It is a map, and a map is only worth
having if it is exact. A palace that is 90% right is worse than none, because
you stop verifying and the wrong 10% is where you get hurt.

## When to use

- The user says "palace init", "set up a palace", "create a palace for this project"
- The user asks to record architecture, an ADR, a runbook, or a domain term
- The user says "file this", "remember this", "add this to the palace"
- The user asks "where is X" / "why is X this way" about the current project
- After completing meaningful work, at a natural checkpoint
- The user says "palace doctor", "check the palace", "is the map accurate"

---

## The model

```
<repo>/
  .palace/
    mempalace.yaml       generated taxonomy — never hand-edit
    architecture/        how it is put together, and where the seams are
    decisions/           why it is this way, and what was rejected
    docs/                how to use it
    tests/               what is verified, how, and what is not
    runbooks/            it is broken at 3am — what do I do
    glossary/            what a word means here
    inbox/               worth keeping, not yet placed — never canonical
  .mcp.json              wires this project's palace into Claude Code
```

Three rules that everything else follows from:

1. **The repository is the source of truth.** Markdown under `.palace/` is the
   palace. The docker volume is a derived index, rebuildable at any time with
   `palace sync`. Losing the volume is never data loss.
2. **The directory decides the room.** A file in `.palace/decisions/` is filed
   under `decisions` regardless of its name or its frontmatter. Verified: a file
   named `adr-002-tests-harness-choice.md` in `decisions/` routes to `decisions`,
   not `tests`.
3. **One wing per project, one shared store** (`mempalace-atlas`). Every project
   is a wing in the same palace, so a search can reach across projects and any
   two wings can be linked by a tunnel.

---

## Commands

| Command | Use |
|---|---|
| `palace init` | Scaffold the palace and wire it into Claude Code. Idempotent — also repairs drift. |
| `palace scan` | Map an existing codebase into the skeleton. Run once per project, right after init. `--dry-run` to preview. |
| `palace file --room R --title T --anchor P` | Author a drawer with write-time validation. |
| `palace sync` | Rebuild the index from `.palace/`. Run after filing anything. |
| `palace status` | What is filed, on disk and in the index. |
| `palace doctor` | Verify the map is accurate. Exits non-zero when it is not. |
| `palace search "..."` | Query the palace from the shell. **Works when the MCP tools do not.** `--room`, `--all-wings`. |
| `palace update` | Rebuild the index. Alias of `sync`. |
| `palace monitor` | Watch live: auto-sync, code drift, agent retrieval. Long-running — do not call it from a tool invocation that expects to return. |
| `palace list` | Every wing in the shared store. |

---

## Rules

### If the `mempalace` tools are missing, use `palace search` — never fall back to reading the repo

Claude Code loads MCP servers at startup and cannot reload them, so a palace
created during the current session has no tools until the next one. That is not a
reason to read the whole codebase: `palace search "..."` queries the same index
through the shell, right now. Check for the tools; if they are absent, shell out.

### Never call `mempalace_add_drawer` to write into a project palace

Write through `palace file`. The MCP write tools bypass every gate — room
validation, anchor checking, the minimum-content guard — and produce drawers
that `palace doctor` will later flag as unverifiable. Read tools
(`mempalace_search`, `mempalace_traverse`, `mempalace_get_drawer`) are fine and
expected; retrieval is what the palace is for.

### Always anchor

An anchor is a repo-relative path the drawer describes:

```bash
palace file --room architecture --title "Auth boundary" \
  --anchor src/auth/session.ts --anchor src/auth/provider.ts \
  --body "Authentication is isolated behind one module so swapping providers never reaches request handling."
```

Anchors are the only thing that makes a drawer falsifiable later. When
`src/auth/session.ts` moves, `palace doctor` can prove the note is suspect.
A drawer with no anchors can never be checked, and will drift silently.

`glossary` is the sole exception — a definition describes language, not code.

### Write what is not recoverable from the code

The code already says what it does. File the things reading it cannot recover:
why this shape, what was rejected and why, which invariant must hold, what
breaks at 3am and how to fix it. Do not paraphrase implementation.

### Sync after filing, doctor before trusting

`palace file` writes to disk. Nothing is searchable until `palace sync`. A
drawer under ~40 characters is silently skipped by the miner — the file exists,
looks filed, and is not in the index. `palace doctor` is what catches that.

### inbox is a holding pen, not a room

Use it when something is worth keeping but its home is unclear. Empty it
deliberately. Anything left there is not part of the map.

---

## Workflows

### Setting up any project (new or with years of history)

```bash
palace init      # scaffold + wire — seven empty rooms
palace scan      # map what already exists
palace sync      # build the index
palace doctor    # confirm, and see what is still unverified
```

Requires the tool installed once per machine:

```bash
npm i -g github:sychus/long-horizon
```

That provides `long-horizon`, `palace` (alias) and `long-horizon-proxy`. If
`doctor` reports the proxy command is missing, that install is the fix — MemPalace
will not start without it.

**Always use `palace <subcommand>` in your own tool calls.** Running
`long-horizon` with no arguments opens an interactive menu that will hang
waiting for a keypress you cannot send.

Then commit `.palace/` and `.mcp.json`. The palace is reviewed in pull requests
like any other part of the repository — that is what keeps it honest.

### Reviewing what scan produced

Scan writes the factual skeleton — module inventory, entry points, test topology
— stamped `origin: scan, reviewed: false`. It is on the map immediately, but
nobody has checked it.

This is high-value work for an agent. For each scanned drawer:

1. Read it against the actual code.
2. Correct anything wrong, and add what the facts do not say — what the module is
   responsible for, what it must not know about, where its seams are.
3. Set `reviewed: true`.
4. `palace sync`.

`palace doctor` reports **mapped** vs **verified** coverage. Straight after a
scan, mapped is ~100% and verified is 0%. Only step 3 moves the second number.
Never set `reviewed: true` on a drawer you have not actually checked — that flag
is the only thing separating generated inventory from real knowledge.

Scan never overwrites a drawer that is reviewed or hand-edited, so re-running it
later is always safe.

### Filing at a checkpoint

After meaningful work, ask what a newcomer could not recover by reading the
diff, and file that:

```bash
palace file --room decisions --title "ADR 004 Per-project volumes" \
  --anchor cli/project.ts \
  --body "Each project gets its own docker volume so no project can see another's memory. Trade-off accepted: cross-project tunnels are impossible, because MemPalace tunnels only link wings inside one store."
palace sync
```

Prefer few, dense, anchored drawers over many thin ones.

### Answering "where is X" / "why is X"

Search the palace first — that is what it is for. If the answer is not there and
you had to work it out from the code, file it. That is how the map grows in the
places it is actually used.

### When doctor reports failures

Failures mean the map is actively wrong. Fix them before relying on it:

| Report | Meaning |
|---|---|
| taxonomy has drifted | `mempalace.yaml` was hand-edited — run `palace init` |
| file(s) outside any room | will land in the fallback bucket, not where intended |
| frontmatter disagrees with room | the note claims one room, the directory files it in another |
| anchors point at paths that no longer exist | the code moved; update the note or the anchor |
| under 40 chars | the miner skips these entirely — they are not searchable |
| disk and index disagree | run `palace sync`; if it persists, drawers are being skipped |
| anchored code changed after the note | re-read the note and bump `updated:` |

---

## Notes

- One wing per project inside the shared store `mempalace-atlas`, with a proxy
  port derived from the slug. Store, wing and port are all recorded in `.mcp.json`.
- The store is **not** `mempalace-data`. That one holds auto-mined conversation
  transcripts; this one holds curated project maps. Keep them separate.
- Searches reach across wings by default, so a query can surface another
  project's decision. That is intended — pass a `wing` filter to scope it.
- Two projects syncing at once is normal. Only `mine` takes the palace lock, so
  MCP reads are never blocked; `palace sync` retries automatically when another
  project holds it. If a sync reports the palace stayed locked, nothing was
  filed — just run it again.
- Long Horizon (the VS Code extension) visualizes a palace and never writes to
  it. Every mutation goes through the CLI.
