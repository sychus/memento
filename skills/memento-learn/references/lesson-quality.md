# Lesson quality

## Contents
- The bar
- Good vs bad, side by side
- The generality trap
- Phrasing template

## The bar

A lesson earns filing when it can **change a specific future decision**. Test it: imagine the next agent (or dev) about to make the same mistake — does reading this lesson stop them? If it only makes them vaguely nervous, it fails the bar.

Three properties, all required:

1. **Specific** — names the actual field, endpoint, setting, or pattern.
2. **Falsifiable** — a future reader can check whether it is still true (this is why refs/anchors are mandatory).
3. **Consequential** — states what goes wrong (or right) and under which conditions.

## Good vs bad, side by side

| ✅ Files | ❌ Doesn't |
|---|---|
| `POST /attendees silently drops "items" unless it's an array — the 200 response lies` | `Be careful with the attendees API` |
| `Auth0 tokens for the capacity service expire at 1h; the client caches for 2h — refresh on 401, don't retry` | `Watch out for token expiry` |
| `Tests that flip org-wide settings (Default Gateway, ACH) corrupt parallel workers unless the restore runs in finally` | `Be careful with shared state in tests` |
| `escapeSoqlLiteral() returns the value ALREADY quoted — wrapping it again produces invalid SOQL` | `Check the escaping` |

The bad column is what ACE calls **brevity bias** — advice compressed past the point of usefulness. It reads wise and prevents nothing.

## The generality trap

Don't over-generalize at capture time. File the concrete instance with its refs; generalizing to the bug *class* is the curator's job (`memento-curate`), done with the code open and existing drawers in view. A prematurely-general lesson loses the anchor that made it verifiable.

Inverse trap: don't file pure narration either. "PR #6224 got kicked back on Tuesday" is history, not a lesson — the lesson is *what condition caused it and what prevents it*.

## Phrasing template

When in doubt:

> **[Component/path]** [does the surprising thing] **when** [condition]. **Instead/therefore**, [the decision this should change].

Example: "`AbortSignal.timeout` aborts the fetch *and* any later `response.json()` read — when the try/catch only wraps the fetch, a mid-body abort escapes untyped. Therefore wrap every statement that can observe the signal."
