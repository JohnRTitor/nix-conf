---
name: validate-loop
description: Implement a change, validate it, run adversarial read-only critic subagents, and fix confirmed findings in a bounded loop (max 3 rounds). Use only when the user explicitly invokes /validate-loop or asks for the validate loop.
---

# Validate loop

The task is whatever the user asked for when invoking this skill.

## Process

1. Understand the requested behavior. Inspect the relevant code, tests, configuration, and architecture before making assumptions. Write a short REQUIREMENTS SUMMARY (a few bullets) to hand to the critics.
2. Implement the change completely. Do not stop at the first plausible patch.
3. Run the strongest relevant validation: formatter, type checker, build, unit/integration tests, lint/static analysis. Discover the repository's real commands; do not invent them.
4. Inspect `git diff` and `git status` for accidental changes, debug code, weakened assertions, dead code, API drift, and incomplete work.
5. Launch critics with the `use_subagents` tool, all applicable ones in a single call. Subagents are read-only: they can read files, search, and run read-only commands such as `git diff` and `git log`. They cannot edit files, run tests, or start other subagents, and they start with no context.
   For each critic, read its prompt file and use that text as the start of the subagent prompt:
   - `docs/critic-correctness.md`: ALWAYS run
   - `docs/critic-tests.md`: ALWAYS run
   - `docs/critic-security.md`: run only if the diff touches input parsing, auth, crypto, filesystem/network/process interaction, serialization, privilege boundaries, or dependencies
   - `docs/critic-performance.md`: run only if the diff touches hot paths, I/O, loops over unbounded data, locking/concurrency, or startup
   Append to every subagent prompt: the REQUIREMENTS SUMMARY, the changed files and what changed, the validation commands you already ran with their results (critics cannot run them), and from round 2 onward the findings already rejected with reasons. Say which optional critics you skipped and why.
6. Treat findings as hypotheses. Reproduce or reason through every BLOCKER/HIGH. Reject a finding only when you can demonstrate it is invalid or irrelevant, and record the reason.
7. Fix every confirmed BLOCKER and HIGH. Fix MEDIUM findings that affect correctness, reliability, security, resource usage, or likely regressions.
8. Rerun focused tests first, then the broader suite.
9. Re-run only the critics whose area was affected by the fixes. Stop when a round produces no NEW confirmed BLOCKER/HIGH findings. Hard cap: 3 rounds. Do not re-litigate previously rejected findings.
10. If changed behavior lacks tests, add targeted tests.
11. Never make tests pass by weakening assertions, deleting coverage, skipping tests, broadening mocks, disabling lint/type checks, or suppressing errors without a documented technical reason.
12. Distinguish environmental/toolchain failures from code failures and gather independent evidence.
13. Never run `git push`, `git reset --hard`, `git clean`, or recursive deletes.

Completion criteria: behavior implemented; relevant tests pass; applicable build/type/lint checks pass; final diff inspected; no confirmed BLOCKER/HIGH remain; no known regression left unfixed.

## Final report

- What changed
- Validation commands actually run and results
- Critics run/skipped, findings by category
- Findings fixed vs rejected, with reasons
- Remaining limitations or environment failures
- Exact final test/build status
