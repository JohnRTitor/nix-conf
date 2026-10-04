---
name: review-loop
description: Read-only adversarial review of the current working tree using critic subagents, without implementing anything. Use only when the user explicitly invokes /review-loop or asks for an adversarial review of current changes.
---

# Review loop

The subject of the review is whatever the user said when invoking this skill. Do NOT modify any files, and do not run commands that change files or repository state.

## Process

1. Inspect `git status`, `git diff`, and the surrounding code. Run safe, read-only validation where useful.
2. Write a short REQUIREMENTS SUMMARY from the user's request and the diff.
3. Launch critics with the `use_subagents` tool, all applicable ones in a single call. Subagents are read-only and start with no context. Read each prompt file and use its text as the start of the subagent prompt:
   - `docs/critic-correctness.md`: ALWAYS run
   - `docs/critic-tests.md`: ALWAYS run
   - `docs/critic-security.md`: run when the diff touches input parsing, auth, crypto, filesystem/network/process interaction, serialization, privilege boundaries, or dependencies
   - `docs/critic-performance.md`: run when the diff touches hot paths, I/O, unbounded loops, locking/concurrency, or startup
   Append the REQUIREMENTS SUMMARY, the changed files, and any validation results you gathered.
4. Verify each finding to remove false positives.
5. Report only confirmed, actionable issues with severity (BLOCKER/HIGH/MEDIUM/LOW) and file/line references, then propose the smallest root-cause fixes. Do not apply them.
