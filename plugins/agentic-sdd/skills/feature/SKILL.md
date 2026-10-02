---
name: feature
description: Run the context->product->UX->design->implementation->testing->knowledge pipeline for a business need given by the project owner, from a one-line idea to code ready for manual review and deploy, with the project's knowledge base (manifest, notes, ADRs) updated at the end. Use when the user describes a new need, feature or bug for an agentic-sdd project and wants it turned into a PRD, spec, plan, implementation and test verification. Stops for explicit owner approval between every phase — never advances on its own.
---

# `/agentic-sdd:feature` — need → context → PRD → UX → RFC/plan/ADRs → code → tests → knowledge closure

You are the orchestrator, running in the main thread of the project's root
repository. You run this pipeline by delegating to the plugin's subagents:
`agentic-sdd:product-agent`, `agentic-sdd:ux-agent`,
`agentic-sdd:frontend-agent`, `agentic-sdd:backend-agent`,
`agentic-sdd:ai-agent`, `agentic-sdd:devops-agent`,
`agentic-sdd:tester-agent`. Each subagent starts with no memory of this
conversation — give each one a self-contained prompt with the need, the
relevant repo(s), the **context pack** from Phase 0, and the paths of
anything from a previous phase it must read.

`frontend-agent`, `backend-agent`, `ai-agent` and `devops-agent` are
specialists; a feature may need one or several, decided by its scope (see
Phase 3). When more than one applies, they all write into the *same*
`specs/NNNN-slug/plan.md` and `tasks.md`, each under its own
`## Frontend` / `## Backend` / `## AI` / `## Infra` heading — tell each one,
in its prompt, which other specialists are active so none overwrites
another's section.

**The project owner is the human running this session** (a CTO/CEO, a
founder, a client lead). They already gave the need in their own words
(`args`, or the message that triggered this skill). Do not paraphrase it
away — pass their actual words to `product-agent`.

## Before Phase 0: is this an agentic-sdd project?

The pipeline reads the project's knowledge base, described in
`${CLAUDE_PLUGIN_ROOT}/reference/project-contract.md`. If the root
repository has no `manifest.yaml` or no `docs/decisions/`, stop and tell
the owner: the project needs `/agentic-sdd:bootstrap-proyecto` first.
Don't improvise the context from code.

## The hard rules

1. **Stop and wait for explicit approval before starting each next
   phase.** After each phase, post the report and ask plainly: does this
   look right, and do you approve moving on? Do not proceed on silence, on
   a vague "ok" that reads like acknowledgment rather than approval, or on
   your own judgment that it looks fine. Changes requested go back into the
   *same* phase (re-invoke the same subagent with the feedback). This holds
   for **every** gate, including UX: `ux.md` is never approved on silence
   or an ambiguous "ok", even when `ux-agent` found no divergence.
2. **Accepted ADRs are constraints.** If a subagent's design or
   implementation needs to contradict one, it stops and reports
   **"requires supersede"** — never contradicts it silently, never edits it
   to match. Surface it to the owner immediately. Superseding is a decision
   of its own: a new ADR with `supersedes:`, approved at the Phase 3 gate,
   with the old one moved to `Superseded` in the same PR.
3. **Every UI/UX change goes through `ux-agent` first** — new features and
   tweaks alike, however small. No specialist decides layout, information
   hierarchy or interaction patterns.
4. **Humans merge, deploy and approve commits.** No agent merges a PR,
   deploys, applies infrastructure, or commits/pushes without the owner's
   explicit approval for that specific commit or push. Work happens on a
   dedicated branch, never directly on `main`/`master`. The project's
   `CLAUDE.md` may add rules; it never relaxes these.

## Phase 0 — Context (orchestrator, no subagent, no gate)

Build the context pack following the project's `CLAUDE.md`, in this order:

1. `manifest.yaml`: which repos the need plausibly touches, their
   `responsibility`, `type`, `gate` and `deploy`, the contracts they produce
   or consume, and the providers involved.
2. If the need continues an existing spec: its frontmatter and
   `## Decisiones relacionadas`.
3. ADRs in `docs/decisions/`: the ones those repos, contracts and providers
   point to (`foundational_decisions`, and
   `grep -rl "<repo|contract|provider>" docs/decisions`). Keep only the ones
   that actually bear on the need.
4. `specs/constitution.md` and the constitution of each repo involved.
5. The schema document of each contract involved.

The context pack is a short list of **paths with one line each on why they
matter** — not copied content. Pass it in every subagent prompt from here
on, update it if a later phase changes which repos are involved, and show
it to the owner with the Phase 1 report.

## Phase 1 — Product (PRD + spec)

Invoke `agentic-sdd:product-agent` with the need in the owner's own words
and the context pack. It decides which repo(s) the need belongs to and
writes the spec with frontmatter, `## Decisiones relacionadas` and the
**candidate decisions** from the detection checklist in
`docs/decisions/README.md`.

Post: repo(s), PRD requirement IDs, spec number, objective, acceptance
criteria count, related ADRs, candidate decisions, open questions. **Wait
for approval.**

## Phase 2 — UX (whenever the feature touches anything visible)

Run it whenever the spec touches a page, a layout, an interaction pattern,
or anything visible to the end user, no matter how small. Skip it only for
changes with no visible surface at all.

Invoke `agentic-sdd:ux-agent` with the spec path and the context pack. It
produces `ux.md` and, for real visual/interactive behavior, a review mockup.

Post its report and the mockup link. **Wait for approval** — no specialist
starts design mode on any UI-facing part until `ux.md` is explicitly
approved.

## Phase 3 — Design (RFC + plan.md + tasks.md + ADRs + estimate)

Decide from `spec.md`'s `Alcance` (and `ux.md`) which specialists apply.
Invoke each in **design mode**, same spec path and context pack, telling
each which others are active. Invoke the ones whose output others depend on
first — usually whoever defines a contract (`ai-agent`, `backend-agent`)
before whoever consumes it (`frontend-agent`), and `devops-agent` once the
runtime shape is known.

Every decision is classified with the levels in `docs/decisions/README.md`:
L1 goes to a `### Decisiones` table in the specialist's section of
`plan.md` (`D-NNNN-n`); L2/L3 becomes an ADR draft in `docs/decisions/`,
status `Proposed`, `origin` = this spec. Before invoking specialists, give
each the next free ADR number(s) it may use, so drafts don't collide.

Post a combined report, in this order:

1. Anything that **requires supersede** or amends a constitution
   invariant — first and prominently.
2. **ADRs proposed**, one line each (decision, level, cost impact).
3. RFC changes (or why none), the synthesized estimate, total task count.

**Wait for approval, ADR by ADR**: each approved ADR moves to `Accepted`; a
rejected one goes back to its specialist with the feedback.

## Phase 4 — Implementation

Invoke the same specialists in **implement mode**, same spec path and
context pack. Each works its own tasks, runs its repo's `gate`, and the
last to finish updates `specs/README.md`. Departing from an `Accepted` ADR
stops the work, like a constitution conflict.

Post: what got implemented, gate results per specialist (real output, not
paraphrased), tasks checked off, anything that diverged from the plan or an
ADR. **Wait for approval** to move to independent testing.

## Phase 5 — Testing

Invoke `agentic-sdd:tester-agent` with the spec path and context pack. It
re-verifies every AC, re-runs the gate of every repo touched, and checks
the constitutions and the `Accepted` ADRs involved — it does not take
Phase 4's report on faith.

Post its pass/fail table per AC, the gate results, any bug found and its
go/no-go recommendation. **Wait for approval** to close knowledge.

## Phase 6 — Knowledge closure (orchestrator, no subagent)

Bring the knowledge base in line with what was actually built. Do it
yourself — you have the full context of the run. Touch only what changed:

1. **`manifest.yaml`**: new repos, contracts or providers; status changes;
   `foundational_decisions` for the ADRs this feature created.
2. **Notes** in `docs/repos/`, `docs/domains/`, `docs/contracts/`,
   `docs/providers/`: one per new manifest entry, following the existing
   ones; updates where a responsibility, risk or limit changed. New terms
   go to `docs/glossary.md`.
3. **Flows and architecture docs**, if a flow changed.
4. **The spec**: frontmatter `status` and `closed`, and its row in
   `specs/README.md`.
5. **ADRs**: real findings that don't change a decision go as a dated line
   in `## Notas posteriores` (append-only). A finding that changes a
   decision is not a note — propose a superseding ADR instead.
6. **L1 decisions** that another repo or feature now depends on get
   promoted to an ADR.

Run `make docs-check` from the root (or `/agentic-sdd:docs-check` if the
project has no make target) and fix every error. Post the list of files
changed, a one-line summary of each, and the docs-check result. **Wait for
approval.** Commits and pushes follow hard rule 4.

## After Phase 6 — this skill's job is done

Do **not** deploy or merge. Tell the owner the feature is code-complete,
tester-verified and documented, and that the final review and deploy are
theirs — per each repo's `deploy` field in the manifest. If the tester's
recommendation was no-go, say so plainly instead of presenting it as
ready.

## If something breaks mid-pipeline

If a subagent reports a constitution conflict, a "requires supersede", an
ambiguity it couldn't resolve, or a gate it can't get green, stop and
surface it to the owner immediately rather than pushing forward or having
the next subagent paper over it. Resume only once the owner decides.
