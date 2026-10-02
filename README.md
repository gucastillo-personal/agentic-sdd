# agentic-sdd

Plugin privado de Claude Code con mi forma de trabajar: spec-driven
development con un equipo de agentes especializados, gates de aprobación
humana y una base de conocimiento por proyecto (manifest, notas, ADRs).

> Estado: en construcción. P1 (núcleo genérico) escrita; marketplace,
> manifest del plugin, `bootstrap-proyecto`, `docs-check` y hooks llegan en
> P2.

## Qué trae

| Componente | Qué hace |
|---|---|
| `/agentic-sdd:feature` | Lleva una necesidad de punta a punta: contexto → PRD/spec → UX → diseño con ADRs → implementación → testing → cierre de conocimiento. Frena en cada fase hasta la aprobación explícita del dueño del proyecto |
| 7 agentes | `product-agent`, `ux-agent`, `frontend-agent`, `backend-agent`, `ai-agent`, `devops-agent`, `tester-agent`, con el prefijo `agentic-sdd:` |

Los agentes no saben nada de ningún proyecto: lo leen de la base de
conocimiento del proyecto en la Fase 0. Qué tiene que ofrecer un proyecto
está en
[`reference/project-contract.md`](./plugins/agentic-sdd/reference/project-contract.md).

## Cómo se mantiene

- Las secciones que comparten `frontend-agent`, `backend-agent`, `ai-agent`
  y `devops-agent` viven una sola vez en
  [`reference/specialist-common.md`](./plugins/agentic-sdd/reference/specialist-common.md).
- Las fuentes de esos cuatro agentes están en `agents-src/`, con marcadores
  `{{COMMON:<sección>}}`. `plugins/agentic-sdd/agents/` se genera: no se
  edita a mano.

```sh
ruby scripts/build-agents.rb          # regenera los agentes
ruby scripts/build-agents.rb --check  # falla si alguno quedó desactualizado
```

Nada de un proyecto ni de un cliente vive en este repo.
