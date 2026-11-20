---
name: feature-sdd
description: Take a feature, bug or business need from a one-line idea to tested code through seven human-gated phases — context, PRD/spec, UX, design with ADRs, implementation, testing, knowledge closure. Stops after every phase until you explicitly approve. Use when you describe a new feature or change and want it specified, designed, built and verified step by step with a written trail (spec, plan, tasks, decisions) in the repo.
summary: Seven-phase, human-gated pipeline that takes a feature from idea to tested code, leaving spec, plan, ADRs and docs in the repo.
version: 0.2.0
license: MIT
tags: [spec-driven-development, workflow, adr, testing, planning]
keywords: [feature, prd, spec, ux, design, adr, implementation, testing, approval gates]
use_cases:
  - Turn a one-line feature idea into a spec, plan and tasks before writing code
  - Build a feature with explicit approval after each phase
  - Keep decisions (ADRs) and docs in sync with what was built
docs_url: https://github.com/gucastillo-personal/agentic-sdd
---

# feature-sdd — spec-driven feature pipeline with approval gates

You run the whole pipeline yourself, in this conversation, one phase at a
time. The user is the **project owner**; their words are the need. Never
paraphrase the need away: quote it in the spec.

## Hard rules

1. **Gate after every phase.** End each phase with a short report and ask:
   "Does this look right? Do you approve moving to <next phase>?" Advance
   only on an explicit approval ("approved", "go ahead"). Silence, "ok" or
   "looks fine" is not approval — ask again. Requested changes are made in
   the **same** phase, then re-reported.
2. **Accepted decisions are constraints.** If the work contradicts an
   Accepted ADR, stop and say **"requires supersede"**. Never edit an
   accepted ADR to fit; propose a new one that supersedes it and get it
   approved at the design gate.
3. **Humans merge, deploy and approve commits.** Work on a dedicated branch,
   never `main`/`master`. Never merge, deploy, apply infrastructure, or
   commit/push without the owner's explicit OK for that specific action.
4. **Never invent facts.** Anything you cannot find in the repo or in the
   user's words goes to "Open questions", not into the spec.
5. **No secrets** in files, specs or ADRs. Real values come from the human.

## Files you create (adapt paths to the repo's conventions)

- `specs/NNNN-slug/spec.md` — need, requirements (R-1…), acceptance criteria
  (AC-1…), scope / non-goals, related decisions, open questions.
- `specs/NNNN-slug/ux.md` — only if anything user-visible changes.
- `specs/NNNN-slug/plan.md` and `tasks.md` — design and checklist.
- `docs/decisions/ADR-NNNN-slug.md` — one per significant decision.

## Phase 0 — Context (no gate)

Read, don't assume: `README`, `CLAUDE.md`/contributing docs, the repo layout,
how to run the tests/lint/build (the **gate**), existing ADRs/specs/docs
that bear on the need. Output a short list of **paths with one line on why
each matters**, plus the gate command(s). If the repo has no `specs/` or
`docs/decisions/`, propose creating them and wait for a yes. Show the list
with the Phase 1 report.

## Phase 1 — PRD + spec

Write `spec.md`. Keep it testable: every requirement maps to at least one
acceptance criterion written as an observable check. List non-goals and
**candidate decisions** (choices worth an ADR: new dependency, data model,
public contract, infra, anything hard to reverse).
Report: number, objective, # requirements, # ACs, candidate decisions, open
questions. **STOP — wait for approval.**

## Phase 2 — UX (skip only if nothing is user-visible)

Write `ux.md`: user flow, screens/states (empty, loading, error, success),
information hierarchy, copy, accessibility notes. Reuse the existing design
system and patterns; call out any divergence. Offer a quick mockup if the
interaction is non-trivial. No visual decisions are made later outside this
document. **STOP — wait for explicit approval, even if you found no issues.**

## Phase 3 — Design (plan, tasks, ADRs)

Write `plan.md` (approach per area touched, data/contract changes, risks,
rollout) and `tasks.md` (small ordered checkboxes, each tied to ACs).
Classify decisions: small and local → a row in a "Decisions" table in the
plan; significant or costly to reverse → an ADR with status `Proposed`
(context, options, decision, consequences, cost, how to undo).
Report first: anything that **requires supersede**; then ADRs proposed (one
line each); then task count and rough estimate. **STOP — approval is given
ADR by ADR**: approved → `Accepted`; rejected → revise.

## Phase 4 — Implementation

Work the tasks in order on a feature branch, tick them off as you go, run
the gate after each meaningful chunk. If reality diverges from plan or an
Accepted ADR, stop and report instead of improvising. Do not commit without
approval. Report with **real gate output**, tasks done, any divergence.
**STOP — wait for approval to test.**

## Phase 5 — Testing

Verify independently of your own phase 4 report: for each AC, run or write
the check and record pass/fail with evidence; re-run the full gate; check
the change against the Accepted ADRs and project conventions; try the
obvious edge cases and one failure path. Report a table (AC → pass/fail →
evidence), bugs found, and a plain **go / no-go**. Fix bugs only with
approval, then re-test. **STOP — wait for approval.**

## Phase 6 — Knowledge closure

Bring the docs in line with what was actually built — touch only what
changed: spec status and date, `specs/` index, affected docs and diagrams,
glossary terms, README/changelog if user-facing. Findings that don't change
a decision go as dated notes in the ADR; ones that do need a new
superseding ADR. Report files changed with one line each.
**STOP — wait for approval.**

## Finish

Say plainly that the feature is code-complete, tested and documented (or
**no-go**, with why). Final review, merge and deploy belong to the owner.

## If something breaks

On a constraint conflict, an unresolved ambiguity, or a gate you can't get
green: stop, say what and why, and wait for the owner's decision.
