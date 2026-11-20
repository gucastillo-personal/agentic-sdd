# agentic-sdd

[English](#english) · [Español](#español)

## English

A Claude Code plugin for **spec-driven development with a team of specialist
agents**, **human approval gates** and a **per-project knowledge base**
(manifest, notes, ADRs). This repo is both the marketplace
(`agentic-sdd-marketplace`) and the plugin (`agentic-sdd`). Licensed MIT.

**Install** (from the root of your project):

```sh
claude plugin marketplace add gucastillo-personal/agentic-sdd --scope project
claude plugin install agentic-sdd@agentic-sdd-marketplace --scope project
```

Then run `/agentic-sdd:bootstrap-proyecto` in a session to create the
knowledge base (`CLAUDE.md`, `manifest.yaml`, constitution, `docs/`, ADR
templates).

**Approval-gate model.** `/agentic-sdd:feature` takes a need from a one-line
idea to tested code through seven phases: context → PRD/spec → UX → design
with ADRs → implementation → testing → knowledge closure. It **stops after
every phase** and only advances on the owner's explicit approval; requested
changes go back into the same phase. Accepted ADRs are constraints: changing
one requires a new superseding ADR, approved at the design gate. Humans
merge, deploy and approve commits — agents never do.

**`guard-git` hook.** A safety net that runs before every Bash command, in
any permission mode, and blocks `gh pr merge`, the GitHub merge API, pushes
to `main`/`master` (direct, via refspec, `--all`/`--mirror`, or deletion)
and force pushes without an explicit target branch. Normal branch work,
including `--force-with-lease` to your own branch, passes. It is not a shell
parser: it can't see pushes made inside scripts, git aliases or make
targets. A repo where pushing to `main` is intentional can opt out with
`git config agentic-sdd.allowDirectMain true`.

A standalone, self-contained version of `/feature` (no plugin or subagents
needed) lives in [`agensi/feature-sdd/SKILL.md`](./agensi/feature-sdd/SKILL.md).

---

## Español

Plugin de Claude Code con mi forma de trabajar: spec-driven
development con un equipo de agentes especializados, gates de aprobación
humana y una base de conocimiento por proyecto (manifest, notas, ADRs).

Este repo es a la vez el **marketplace** (`agentic-sdd-marketplace`) y el
**plugin** (`agentic-sdd`). Nada de un proyecto ni de un cliente vive acá.
Licencia MIT.

## Qué trae

| Componente | Qué hace |
|---|---|
| `/agentic-sdd:feature` | Lleva una necesidad de punta a punta: contexto → PRD/spec → UX → diseño con ADRs → implementación → testing → cierre de conocimiento. Frena en cada fase hasta la aprobación explícita del dueño del proyecto |
| `/agentic-sdd:bootstrap-proyecto` | Crea la base de conocimiento en un proyecto nuevo o existente: `CLAUDE.md`, `manifest.yaml`, constitution, `docs/` con plantillas, `specs/README.md`, `docs-check` y el plugin habilitado para el proyecto |
| `/agentic-sdd:docs-check` | Valida la base de conocimiento y avisa si la copia del proyecto quedó vieja |
| 7 agentes | `product-agent`, `ux-agent`, `frontend-agent`, `backend-agent`, `ai-agent`, `devops-agent`, `tester-agent` (con el prefijo `agentic-sdd:`) |
| Hook `guard-git` | Bloquea, en cualquier modo de permisos, el merge de PRs y el push a `main`/`master`. Ver abajo |

Los agentes no saben nada de ningún proyecto: lo leen de su base de
conocimiento en la Fase 0. Qué tiene que ofrecer un proyecto está en
[`reference/project-contract.md`](./plugins/agentic-sdd/reference/project-contract.md).

## Instalación y uso

En el repo raíz del proyecto:

```sh
claude plugin marketplace add gucastillo-personal/agentic-sdd --scope project
claude plugin install agentic-sdd@agentic-sdd-marketplace --scope project
```

y después, en una sesión, `/agentic-sdd:bootstrap-proyecto` (el bootstrap
corre estos dos comandos si todavía no se corrieron). El alcance de
proyecto escribe `.claude/settings.json`: quien abra el proyecto y confíe en
la carpeta recibe el plugin.

## Ejemplo: `/feature` de punta a punta

Tras el bootstrap, el dueño del proyecto escribe:

```text
/agentic-sdd:feature Quiero que los usuarios puedan exportar sus reportes a CSV
```

1. **Contexto**: el orquestador lee `manifest.yaml`, las ADRs y la
   constitution, y arma una lista corta de rutas relevantes. Sin gate.
2. **Producto**: `product-agent` escribe `specs/0007-exportar-csv/spec.md`
   (requisitos, criterios de aceptación, decisiones candidatas).
   → *"¿Aprobás el spec?"* Respondés "aprobado" o pedís cambios.
3. **UX**: `ux-agent` produce `ux.md` y una maqueta. → gate.
4. **Diseño**: los especialistas (`backend-agent`, `frontend-agent`…) escriben
   `plan.md`, `tasks.md` y ADRs en estado `Proposed`. Aprobás ADR por ADR y
   pasan a `Accepted`.
5. **Implementación**: cada especialista hace sus tareas y corre el `gate` de
   su repo (tests/lint). → gate.
6. **Testing**: `tester-agent` reverifica cada criterio de aceptación y vuelve
   a correr los gates; devuelve una tabla pass/fail y go/no-go. → gate.
7. **Cierre de conocimiento**: se actualizan manifest, notas, spec y ADRs, y
   corre `docs-check`. → gate.

Al final el código está completo, verificado y documentado; el merge y el
deploy los hacés vos (el hook `guard-git` impide que un agente los haga).

## El hook `guard-git`

Corre antes de cada comando de Bash y bloquea:

- `gh pr merge` y la API de merge de GitHub;
- `git push` a `main`/`master`: directo, por refspec (`HEAD:main`), con
  `--all`/`--mirror`, o borrándola — también detrás de `cd`, `git -C` o
  variables de entorno;
- un force push sin rama de destino explícita.

Deja pasar el trabajo normal en ramas, incluido `--force-with-lease` a tu
propia rama. Un repo donde el push directo a `main` es intencional (por
ejemplo, un repo de notas) se excluye con una opción local que pone una
persona y no se commitea:

```sh
git config agentic-sdd.allowDirectMain true
```

Es una red de seguridad, no un parser de shell: no ve pushes hechos dentro
de scripts, aliases de git o targets de make.

## Mantenimiento

- **Secciones comunes**: las que comparten `frontend-agent`, `backend-agent`,
  `ai-agent` y `devops-agent` viven una sola vez en
  [`reference/specialist-common.md`](./plugins/agentic-sdd/reference/specialist-common.md).
  Las fuentes de esos cuatro están en `agents-src/` con marcadores
  `{{COMMON:<sección>}}`; `plugins/agentic-sdd/agents/` se genera con
  `make agents` y no se edita a mano.
- **Versiones**: `plugin.json` fija `version`, así que **cada release sube
  la versión** o los proyectos no reciben los cambios. `docs-check.rb` tiene
  **su propia** `VERSION`, que sube solo cuando cambia su código (no los
  comentarios): cada proyecto lleva una copia y `/agentic-sdd:docs-check`
  avisa cuando quedó vieja. `make script-version-check` falla si el código
  cambió y la versión no.
- **Antes de cada PR**: `make check` (agentes al día, pruebas del hook,
  pruebas de `docs-check` sobre un proyecto armado con las plantillas del
  bootstrap, versión del script y `claude plugin validate`).
