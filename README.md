# agentic-sdd

Plugin privado de Claude Code con mi forma de trabajar: spec-driven
development con un equipo de agentes especializados, gates de aprobación
humana y una base de conocimiento por proyecto (manifest, notas, ADRs).

Este repo es a la vez el **marketplace** (`gucastillo-tools`) y el
**plugin** (`agentic-sdd`). Nada de un proyecto ni de un cliente vive acá.

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

## Usarlo en un proyecto

En el repo raíz del proyecto:

```sh
claude plugin marketplace add gucastillo-personal/agentic-sdd --scope project
claude plugin install agentic-sdd@gucastillo-tools --scope project
```

y después, en una sesión, `/agentic-sdd:bootstrap-proyecto` (el bootstrap
corre estos dos comandos si todavía no se corrieron). El alcance de
proyecto escribe `.claude/settings.json`: quien abra el proyecto y confíe en
la carpeta recibe el plugin.

El repo es privado: cada persona necesita acceso de lectura y credenciales
de git guardadas (`gh auth login` y `gh auth setup-git`), porque Claude Code
clona sin pedir contraseña.

## El hook `guard-git`

Corre antes de cada comando de Bash y bloquea:

- `gh pr merge` y la API de merge de GitHub;
- `git push` a `main`/`master`: directo, por refspec (`HEAD:main`), con
  `--all`/`--mirror`, o borrándola — también detrás de `cd`, `git -C` o
  variables de entorno;
- un force push sin rama de destino explícita.

Deja pasar el trabajo normal en ramas, incluido `--force-with-lease` a tu
propia rama. Un repo donde el push directo a `main` es intencional (por
ejemplo, un vault de notas) se excluye con una opción local que pone una
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
  la versión** o los proyectos no reciben los cambios. `docs-check.rb`
  declara la misma versión (`make version-check` lo controla) para que
  `/agentic-sdd:docs-check` sepa si la copia de un proyecto quedó vieja.
- **Antes de cada PR**: `make check` (agentes al día, pruebas del hook,
  versiones consistentes y `claude plugin validate`).
