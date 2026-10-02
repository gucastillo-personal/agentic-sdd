# Project contract — what an `agentic-sdd` project provides

The agents and the `/agentic-sdd:feature` skill know nothing about any
particular project. Everything project-specific — which repos exist, what
each one may and may not do, which decisions are already taken — lives in
the project's own knowledge base, and the agents read it in Phase 0. This
document is the contract between the plugin and that knowledge base.
`/agentic-sdd:bootstrap-proyecto` creates every file below.

## Files

All paths are relative to the project's root repository (the one that
holds the knowledge base; in a multi-repo project, the parent repo with the
others as submodules).

| Path | What it is | Who reads it |
|---|---|---|
| `CLAUDE.md` | Process rules for this project (branches, PRs, approvals) and the context-discovery order. Adds to the plugin's rules; never relaxes them | Every session and agent |
| `manifest.yaml` | Composition: repos, contracts between them, external providers | Phase 0, every agent |
| `specs/constitution.md` | Non-negotiable invariants of the whole project; each repo may have its own `specs/constitution.md` too | Every agent |
| `specs/README.md` | Spec layout, feature index and the spec frontmatter schema | `product-agent`, orchestrator |
| `specs/NNNN-slug/` | One folder per feature: `spec.md`, `ux.md`, `plan.md`, `tasks.md`, RFCs | Every phase |
| `docs/HOME.md` | Entry point of the knowledge base | Humans, orchestrator |
| `docs/decisions/README.md` | Decision levels L0–L3, detection checklist, lifecycle, index | Every agent that decides |
| `docs/decisions/_template.md` | ADR template | Specialists in design mode |
| `docs/decisions/ADR-NNNN-slug.md` | Architecture decisions; `Accepted` ones are constraints | Every agent |
| `docs/{repos,domains,contracts,providers}/` | One short note per manifest entry | Phase 0, Phase 6 |
| `docs/glossary.md` | Domain and process terms | Everyone |
| `scripts/docs-check.rb` + `make docs-check` | Validator for all of the above | Phase 6 |

## `manifest.yaml` fields the agents rely on

```yaml
system:
  name: <project>
  constitution: specs/constitution.md
  decisions: docs/decisions/README.md
  specs: specs/README.md

repositories:
  <repo-name>:
    path: <dir relative to root>      # a submodule, or "." for a single-repo project
    status: planned | in-development | production | retired
    type: <web-frontend | mobile-app | service | data-pipeline | infra | library | ...>
    responsibility: >-               # one responsibility; agents use this to decide where work goes
      ...
    stack: [...]
    gate: <command that must pass before "done", e.g. "pnpm gate", "make check">
    deploy: <how it reaches production, e.g. "vercel (manual)", "terraform (manual)">
    domains: [<domain>, ...]
    providers: [<provider>, ...]
    docs:                             # all optional; paths relative to the repo
      constitution: specs/constitution.md
      prd: docs/PRD/<file>.md
      rfc: docs/rfc/<file>.md
      specs: specs/
      brand: docs/brand.md            # UI repos: the design system ux-agent and frontend-agent follow
      runbook: docs/runbook.md
    foundational_decisions: [ADR-NNNN, ...]

contracts:
  <contract-name>:
    kind: <file/json | http/json | websocket/json | event | ...>
    producer: <repo-name>
    consumers:
      <repo-name>: <how it consumes it>
    schema: <path to the single document that defines the schema>

providers:
  <provider-name>:
    services: [...]
    cost: <free | capped by ADR-NNNN | ...>
```

How agents use it:

- **Where work goes**: `responsibility` and `type`. UI work goes to repos of
  a UI `type`; runtime goes where the ADRs put it.
- **Done means green**: each repo's `gate`. No agent declares a task done
  with the gate red or skipped.
- **Brand**: `docs.brand` of the UI repo. Missing means `ux-agent` raises an
  open question instead of inventing a visual system.
- **Contracts**: a change to a contract's schema is an L2 decision and
  touches its producer and every consumer.

## Spec frontmatter

Defined in the project's `specs/README.md`. Minimum:

```yaml
---
id: "NNNN"
title: <one line>
type: spec
status: draft | design | approved | implementing | done | done-with-debt | abandoned
created: YYYY-MM-DD
closed:
repos: ["[[repo-<name>]]"]
domains: ["[[domain-<name>]]"]
contracts: ["[[contract-<name>]]"]
providers: ["[[provider-<name>]]"]
decisions: ["[[ADR-NNNN-slug]]"]   # only pre-existing ADRs the feature reuses or is bound by
---
```

ADRs born in a spec name it in their own `origin`; the spec does not list
them (each relationship is written once).

## Naming conventions

- Notes: `docs/repos/repo-<name>.md`, `docs/domains/domain-<name>.md`,
  `docs/contracts/contract-<name>.md`, `docs/providers/provider-<name>.md`.
- ADRs: `docs/decisions/ADR-NNNN-<slug>.md`, one global numbering per
  project.
- L1 decisions: `D-NNNN-n` rows in a `### Decisiones` table under the
  owning specialist's section of `plan.md`.
- Specs: `specs/NNNN-<slug>/`, numbered per `specs/` folder.
