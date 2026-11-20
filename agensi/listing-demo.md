## The prompt

You type one line in Claude Code (or any agent that supports SKILL.md skills):

```text
/feature-sdd I want hora.rb (a Ruby CLI that prints the current time) to accept a --utc flag that prints the time in UTC.
```

The skill reads the repo, then stops and asks before touching anything. After you answer ("yes, create `specs/` and `docs/decisions/`, the gate is fine"), this is what it produces. It is a real session on a tiny demo repo, and it ends at the first approval gate.

## Phase 0 — Context (no gate)

| Path | Why it matters |
|---|---|
| `hora.rb` | The whole CLI is one line, `puts Time.now`. This is the file that changes. |
| `README.md` | Two lines in Spanish. It will get a usage note for `--utc`. |
| `specs/`, `docs/decisions/` | Don't exist yet, so the skill asked before creating them. |

- **Existing tooling:** no tests, lint, build, ADRs or specs.
- **Proposed gate:** `ruby -c hora.rb` plus a stdlib-only Minitest file run with `ruby test/hora_test.rb`.

## Phase 1 — PRD + spec

The skill writes `specs/0001-utc-flag/spec.md`:

```markdown
# 0001 — `--utc` flag for hora.rb

- Status: Draft (Phase 1, awaiting approval)
- Date: 2026-11-20

## Need (owner's words)

> I want hora.rb (a Ruby CLI that prints the current time) to accept a --utc flag that prints the time in UTC.

## Context

- `hora.rb` is currently one line: `puts Time.now` (prints local time).
- No tests, lint or build exist in the repo. No prior specs or ADRs.

## Requirements

- **R-1** `ruby hora.rb --utc` prints the current time expressed in UTC.
- **R-2** `ruby hora.rb` with no arguments keeps its current behavior (prints the current local time, same format as today).
- **R-3** `--utc` must not require any new dependency (Ruby standard library only).

## Acceptance criteria

- **AC-1** (R-1) Running `ruby hora.rb --utc` exits 0 and prints exactly one line whose zone is UTC (ends in `UTC`, e.g. `2026-11-20 15:04:05 UTC`).
- **AC-2** (R-1) With `TZ=America/Santiago`, `ruby hora.rb --utc` still prints a UTC time, and its hour differs from the local-time output when the offset is non-zero.
- **AC-3** (R-2) Running `ruby hora.rb` exits 0 and prints exactly one line in the same format as before (`YYYY-MM-DD HH:MM:SS ±HHMM`).
- **AC-4** (R-3) `hora.rb` contains no `require` of a gem and needs no `Gemfile`.

## Scope

In: the `--utc` flag on `hora.rb`; tests/checks for it; README usage note.

## Non-goals

- Other timezones (`--tz`), custom formats, `--help`, or other flags.
- Packaging, installing as a gem, or adding a test framework.

## Candidate decisions (ADR-worthy?)

- Argument parsing: plain `ARGV.include?("--utc")` vs stdlib `OptionParser`. Small and local → likely a row in the plan's Decisions table, not an ADR.
- Behavior on unknown arguments (see open questions) — becomes a public CLI contract.

## Related decisions

None (no ADRs exist yet).

## Open questions

1. **Output format with `--utc`:** Ruby's `Time#utc.to_s` gives `2026-11-20 15:04:05 UTC`. Is that acceptable, or do you want ISO 8601 (`...Z`)? Proposed default: Ruby's default (`... UTC`), consistent with the current format.
2. **Unknown arguments** (e.g. `--foo`): ignore them, or print an error and exit non-zero? Proposed default: error to stderr + exit 1. (Not in your request, so it is not a requirement until you decide.)
3. **Gate:** the repo has no test tooling. Proposed gate: `ruby -c hora.rb` (syntax) plus a small stdlib-only Minitest file `test/hora_test.rb` run with `ruby test/hora_test.rb`. Please confirm.
```

## The report, and the gate

> **Phase 1 report**
> - **Number:** 0001
> - **Requirements:** 3 (R-1 to R-3)
> - **Acceptance criteria:** 4, each an observable check
> - **Candidate decisions:** `ARGV.include?` vs `OptionParser`. Small and local, so a row in the plan, not an ADR.
> - **Open questions:** 3 (output format, unknown arguments, the gate)
>
> **Does this look right? Do you approve moving to Phase 2 (UX)?**

**Nothing moves until you say so.** Answer the open questions, ask for changes, or approve. A vague "ok" is not approval: the skill asks again. Changes are made in the same phase and re-reported.

## What comes next

Phase 2 (UX) → Phase 3 (plan, tasks, ADRs, approved one by one) → Phase 4 (implementation on a branch, with real test output) → Phase 5 (independent testing with a go / no-go table) → Phase 6 (docs and decision records brought in line). Each ends at its own gate.
