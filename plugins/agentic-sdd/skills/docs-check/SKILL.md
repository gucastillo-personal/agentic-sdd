---
name: docs-check
description: Validate an agentic-sdd project's knowledge base — relative links and wikilinks, ADR and spec frontmatter, supersede relations, the ADR index, manifest ↔ notes consistency, and leaked account IDs or webhook URLs. Use when the user asks to check the docs/knowledge base, before committing documentation changes, in Phase 6 of /agentic-sdd:feature, or to see whether the project's vendored copy of docs-check is out of date. Read-only.
---

# `/agentic-sdd:docs-check`

Runs the validator that ships with this plugin against the current
project, and tells the owner whether the project's vendored copy is
behind.

## Steps

1. Find the project root: the directory with `manifest.yaml` (usually the
   current working directory). If there is none, say so and point the
   owner to `/agentic-sdd:bootstrap-proyecto`; stop.
2. Run the plugin's copy, from the project root:

   ```sh
   ruby "${CLAUDE_PLUGIN_ROOT}/scripts/docs-check.rb" <project-root>
   ```

   It is read-only. Ruby's standard library is enough; nothing to install.
3. Compare versions. The plugin's copy declares `VERSION = '…'` near the
   top; so does the project's vendored `scripts/docs-check.rb`, if it has
   one. If the project's copy is missing or older, tell the owner and offer
   to update it by copying the plugin's file over it — that is a change to
   the project, so it needs the owner's approval and goes through the
   project's normal branch/PR flow.
4. Report: the summary line, every error (`✗`) grouped by file, and the
   warnings (`⚠`) separately. Warnings are expected for specs that live on
   an unmerged branch and for submodules that aren't initialized in this
   checkout; say which of those apply instead of treating them as errors.

Do not fix anything unless the owner asks. When asked, fix errors in the
knowledge base itself (links, frontmatter, index, notes); never weaken the
validator to make an error disappear.
