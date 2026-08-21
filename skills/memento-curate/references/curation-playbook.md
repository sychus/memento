# Curation playbook

## Contents
- Generalizing to the class
- Choosing the room
- Discard criteria
- Pruning policy
- Handling duplicates

## Generalizing to the class

A raw lesson usually arrives as an instance: "PR #6224 got kicked back because the try/catch only wrapped the fetch." The canonical drawer should carry the **class**, with the instance as evidence:

> **Class**: every statement that can observe an AbortSignal — not just the initiating call — needs to be inside the typed error handling. A signal-aware fetch aborts its own call *and* any later `response.json()` read.
> **Evidence**: shipped in PR #6224 across two review rounds.

Rules of thumb:
- The class names a **condition and a consequence**, not a ticket.
- Keep at least one concrete anchor from the instance — the class must stay falsifiable.
- If you cannot state the class without losing precision, file the instance as-is. A precise instance beats a mushy generalization (that's brevity bias with extra steps).
- One class per drawer. A lesson that generalizes two ways becomes two drawers.

## Choosing the room

| The lesson is about... | Room |
|---|---|
| A boundary, seam, or invariant of the system ("SF never calls the capacity service from a trigger") | `architecture` |
| A choice and its rejected alternatives ("we retry only transport errors, because...") | `decisions` |
| Something that breaks and how to respond ("webhook retry storm: do X, then Y") | `runbooks` |
| What is verified, how, and what is not ("org-singleton tests are serialized via the mutex helper") | `tests` |
| What a word means in this codebase | `glossary` |
| How to use something (setup, workflow) | `docs` |

Pitfall-type lessons usually land in `runbooks` (if operational) or `tests`/`architecture` (if structural). If no room fits comfortably, the lesson may be two lessons — or not a lesson.

## Discard criteria

Discarding is success, not failure. Discard when:

- **Already fixed and covered**: the bug has a regression test or lint rule → automation supersedes memory (see Pruning).
- **Cannot verify**: refs don't demonstrate the claim and the source PR/ticket doesn't either. Unverifiable claims never enter the map.
- **Duplicate**: an existing drawer covers it → strengthen that drawer instead (add the new anchor/evidence, bump `updated:`).
- **Narration, not lesson**: it records *that* something happened but no condition/consequence that changes a future decision.
- **Expired**: the code it described no longer exists.

Always state the reason when discarding — the discard reasons themselves reveal capture-quality problems worth fixing in how lessons get filed.

## Pruning policy

Run on every curation pass, not just when the inbox has entries:

1. `palace doctor` — anchors pointing at moved/deleted code: re-verify the drawer or remove it.
2. **Automation supersedes memory**: a lesson now enforced by a test, lint rule, or CI check gets removed (note the enforcer in the removal commit). The palace holds what *only* memory can hold.
3. Drawers whose anchored code changed since filing (`doctor` reports this): re-read, re-verify, bump `updated:` — or remove.

The goal is a map that is small and right, not large and impressive. "A palace that is 90% right is worse than none."

## Handling duplicates

- **Exact/normalized duplicate** (same claim, same scope): merge mechanically into the older drawer, keep the union of anchors.
- **Same intent, different wording**: human call — present both texts side by side and ask whether they are one lesson, two permutations, or a contradiction. Never resolve silently; a contradiction between drawers is itself high-signal (one of them is wrong, and the map must not contain it).
