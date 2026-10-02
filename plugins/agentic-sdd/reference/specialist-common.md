# Shared rules for the specialists

`frontend-agent`, `backend-agent`, `ai-agent` and `devops-agent` each
include these sections verbatim. This file is the source; when one of them
changes, update the four agents in the same change.

## Context discovery (before anything else)

Build your context from the project's knowledge base, in this order,
instead of inferring it from code or from historical documents. The
orchestrator passes you a **context pack** with these paths; read them
yourself, and widen it if your work touches something it missed. The layout
is described in `${CLAUDE_PLUGIN_ROOT}/reference/project-contract.md`.

1. The project's `CLAUDE.md` (and the `CLAUDE.md` of each repo you touch) —
   its process rules add to these; they never relax them.
2. `manifest.yaml` — repos with their `responsibility`, `type`, `gate` and
   `deploy`; the contracts they produce or consume; the providers they use.
3. The spec's frontmatter and its `## Decisiones relacionadas`.
4. The relevant ADRs in `docs/decisions/`: the ones the spec lists, the
   ones it originated (`grep -l 'origin:.*NNNN' docs/decisions/ADR-*.md`),
   and the ones that mention the repos, contracts or providers you touch.
5. `specs/constitution.md` (root) and the constitution of each repo you
   touch.
6. The schema document of each contract involved (`schema` in the
   manifest).

An ADR with status `Accepted` is a constraint. If your work needs to
contradict one, stop and report it as **"requires supersede"** — never
contradict it silently and never edit the ADR to match.

## Decisions you make in design mode

Classify every decision with the levels in the project's
`docs/decisions/README.md`:

- **L0** (local, reversible in the same PR) → nothing, or a line in your
  section of `plan.md`.
- **L1** (durable library/pattern within one repo) → a row in a
  `### Decisiones` table under your own section of `plan.md`, ID
  `D-NNNN-n` (spec number + sequence).
- **L2/L3** (new or removed repo, contract change, new dependency between
  repos, new provider or cloud resource, cost exception, personal data
  going to a third party, anything touching a constitution invariant) →
  an ADR draft in `docs/decisions/` from `_template.md`, status
  `Proposed`, `origin` = this spec, using the ADR number the orchestrator
  gave you. Fill `## Alternativas consideradas` with options you actually
  weighed; link the RFC/plan for the design instead of copying it.

List every ADR draft first in your report. Never mark an ADR `Accepted`
yourself — that is the owner's call at the Phase 3 gate, ADR by ADR.

## Process rules

- Work only on a dedicated branch, never on `main`/`master`. Never merge a
  PR. Never deploy, and never run anything that changes real
  infrastructure or production data.
- Ask the owner before installing any tool, package or dependency, and
  before every `git commit` and every `git push` — a general task approval
  does not cover each one.
- Never invent secret values and never commit one: secrets come from the
  human, through whatever mechanism the project's ADRs set.
