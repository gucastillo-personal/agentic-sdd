---
name: bootstrap-proyecto
description: Set up the agentic-sdd knowledge base in a project — CLAUDE.md with the process rules, manifest.yaml, constitution, docs/ (HOME, ADR index and template, note templates, glossary, rollback runbook), specs/README.md, a vendored docs-check with its make target, and the plugin enabled at project scope. Works on a new project or on one with existing repos (surveying them first). Use when the user wants to start using agentic-sdd in a project, or when /agentic-sdd:feature reports the project has no knowledge base. Asks before every change, commit and push.
---

# `/agentic-sdd:bootstrap-proyecto`

Creates the knowledge base that the `agentic-sdd` agents read in Phase 0 of
`/agentic-sdd:feature`. What it must contain is defined in
`${CLAUDE_PLUGIN_ROOT}/reference/project-contract.md`; the starting files
are in `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap-proyecto/templates/`.

The person running the session is the **project owner**. Every change this
skill makes is shown to them first, and every commit and push needs their
explicit approval.

## Step 1 — Check where you are

1. Confirm the current directory is the project's **root repository** (a
   git repo). In a multi-repo project, that is the parent repo that holds
   the others as submodules. If it isn't a git repo, or the owner wants the
   knowledge base somewhere else, stop and ask.
2. List which template destinations already exist (`CLAUDE.md`,
   `manifest.yaml`, `specs/`, `docs/`, `scripts/docs-check.rb`, `Makefile`).
   **Never overwrite an existing file.** For each one that exists, show it
   to the owner and agree whether to keep it, merge the template into it,
   or skip that file.
3. Work on a branch: `chore/agentic-sdd-bootstrap`. If the repository has
   no commits yet, the first commit necessarily goes to `main`; say so and
   ask before making it.

## Step 2 — Ask what the project is

Ask the owner (one round, short questions; use `AskUserQuestion` when
available):

- **Project name** and the **owner's role** as it should appear in the
  rules (for example "el CTO/CEO", "el líder técnico del cliente").
- **Shape**: a single repo, or a root repo with submodules.
- **Starting point**: a new project with no code yet, or existing repos.
- For a new project: the repos it will have, each with its single
  responsibility, type (`web-frontend`, `mobile-app`, `service`,
  `data-pipeline`, `infra`, `library`), stack, gate command and deploy
  method — or "todavía no se sabe", which is a valid answer.
- Known external **providers** (hosting, cloud, payment, AI) and any
  constraint the owner already knows: cost limits, personal data, client
  infrastructure that must be used.

## Step 3 — Existing repos: survey before writing

Skip for a new project. Otherwise, for each repo, read without modifying:
README, package/build manifests (`package.json`, `pyproject.toml`,
`go.mod`, …), CI workflows, IaC folders, and any existing docs, ADRs or
specs. From that, draft:

- the `repositories`, `contracts` and `providers` entries of the manifest,
  marking every field you inferred rather than read;
- a **backlog of decisions already taken** (architecture, providers,
  contracts, data handling) that deserve a retroactive ADR, each with the
  source where you found it.

Show both to the owner and correct them together. Do **not** write ADRs in
this skill: once the bootstrap is merged, write them one by one with
`retroactive: true`, each approved by the owner before it becomes
`Accepted`.

## Step 4 — Write the knowledge base

Copy every file under `templates/` to the same path in the project, except
`Makefile.docs-check`, and replace the placeholders:

| Placeholder | Value |
|---|---|
| `{{PROYECTO}}` | project name |
| `{{REPO_RAIZ}}` | name of the root repository |
| `{{DUENO}}` | the owner's role, as agreed in Step 2 |

Then:

1. **`manifest.yaml`**: replace the empty `repositories: {}`,
   `contracts: {}` and `providers: {}` with the entries agreed in Steps 2–3
   (keep `{}` for a section that is still empty), and delete the commented
   examples you filled in.
2. **Notes**: for every manifest entry, create its note from the matching
   `_template.md` (`docs/repos/repo-<name>.md`,
   `docs/contracts/contract-<name>.md`,
   `docs/providers/provider-<name>.md`), and one
   `docs/domains/domain-<name>.md` per domain listed in the repos. Fill what
   you know; leave the HTML comments where you don't.
3. **Constitution**: it ships as a draft. Walk the owner through it: which
   proposed invariants apply, what counts as private data here, what the
   default cost rule is. Leave the "Borrador" notice until they approve it.
4. **docs-check**: copy `${CLAUDE_PLUGIN_ROOT}/scripts/docs-check.rb` to
   `scripts/docs-check.rb`, and append `templates/Makefile.docs-check` to
   the project's `Makefile` (create the `Makefile` if there is none).
5. **UI repos**: if a repo has a visual surface and no brand/design-system
   document, note it as an open question in its repo note —
   `ux-agent` needs `docs.brand`.

## Step 5 — Enable the plugin for this project

With the owner's approval (it writes `.claude/settings.json`), run from the
project root:

```sh
claude plugin marketplace add gucastillo-personal/agentic-sdd --scope project
claude plugin install agentic-sdd@gucastillo-tools --scope project
```

Project scope keeps the plugin, and its git-safety hooks, to this project.
Anyone who opens the project and trusts the folder is offered the plugin;
the marketplace repo is private, so they need read access to it and git
credentials stored on their machine (`gh auth login` + `gh auth setup-git`).

If the project has a repository where pushing directly to `main` is
intended (rare — for example, a notes vault), the owner can opt that repo
out of the push guard locally: `git config agentic-sdd.allowDirectMain true`.
Never set it yourself.

## Step 6 — Validate and hand over

1. Run `make docs-check`. It must end with 0 errors; fix the knowledge
   base until it does (never the validator).
2. Show the owner the list of files created or merged, the docs-check
   result, and the open items: constitution still in draft, the
   retroactive ADR backlog (if any), missing brand documents, repos with
   "todavía no se sabe".
3. Ask for approval to commit, then separately to push and open a PR. The
   owner merges it.

Once merged, the project is ready for `/agentic-sdd:feature`.
