# Engineering rules

- Work toward a correct, production-quality result. "It compiles" is not sufficient; validate the affected behavior after meaningful changes.
- Never silence failures, weaken or delete tests to get green, disable lint/type checks, or paper over architectural problems. Fix root causes.
- Discover the repository's real build/test/lint commands instead of guessing.
- For non-trivial work, use the `/validate-loop` command (or invoke the `@critic-*` subagents directly with full context: requirements, changed files, validation results).
- Before declaring completion, inspect the final `git diff` and run the strongest practical validation available.
- Never run `git push`, `git reset --hard`, `git clean`, or recursive deletes.
