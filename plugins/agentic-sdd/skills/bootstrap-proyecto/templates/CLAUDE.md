# Reglas de flujo de trabajo ({{PROYECTO}})

Estas reglas aplican a cualquier sesión de Claude Code (o cualquier agente)
que trabaje en este proyecto — {{REPO_RAIZ}} y todos sus repos —, no solo a
la sesión que las escribió. Este proyecto usa el plugin `agentic-sdd`: sus
agentes (`agentic-sdd:product-agent`, `agentic-sdd:ux-agent`,
`agentic-sdd:frontend-agent`, `agentic-sdd:backend-agent`,
`agentic-sdd:ai-agent`, `agentic-sdd:devops-agent`,
`agentic-sdd:tester-agent`) y el flujo `/agentic-sdd:feature`. Las reglas de
este archivo se suman a las del plugin; nunca las relajan.

**Quién aprueba en este proyecto:** {{DUENO}}. Cuando estas reglas dicen
"quien aprueba", es esa persona.

## Nunca commitear ni pushear directo a `main`

Ningún agente commitea ni pushea directo sobre `main`, en ningún repo del
proyecto, incluidos cambios "chicos" como docs o config. Todo trabajo
arranca en una rama dedicada (`feature/<slug>`, `hotfix/<slug>`,
`chore/<slug>`, `docs/<slug>`) y llega a `main` únicamente por Pull
Request. Vale aunque el repo no tenga una protección del lado del servidor:
es una regla de proceso, y el hook del plugin la refuerza.

## Nunca mergear Pull Requests

El merge a `main` lo ejecuta siempre una persona, sin excepción, aunque
todos los checks estén en verde. Ningún agente usa `gh pr merge` ni
equivalentes.

## Aprobación humana obligatoria antes de actuar

- Ningún agente instala herramientas, paquetes o dependencias ni ejecuta
  scripts que no sean de solo lectura sin aprobación explícita de quien
  aprueba.
- Antes de cada `git commit` y de cada `git push` hay que pedir aprobación
  explícita: no alcanza con haber aprobado la tarea en general.
- Ningún agente despliega ni aplica infraestructura real.

## Toda modificación de UI/UX pasa por `ux-agent`

Cualquier cambio que toque una página, un layout, un patrón de interacción
o la experiencia visible por el usuario final — features nuevas y ajustes
sobre pantallas existentes, por chico que sea — pasa por
`agentic-sdd:ux-agent` antes de que otro agente diseñe o implemente esa
parte. Su entregable (`ux.md` y, si corresponde, la maqueta) necesita
aprobación explícita de quien aprueba: el silencio o un "ok" ambiguo no
cuentan.

## Descubrimiento de contexto (base de conocimiento)

Antes de diseñar o implementar cualquier cosa, el agente arma su contexto
en este orden, en vez de inferirlo del código:

1. [`manifest.yaml`](./manifest.yaml): qué repos hay, qué hace cada uno,
   qué contratos producen o consumen y qué proveedores usan.
2. El frontmatter y `## Decisiones relacionadas` de la spec en curso
   (`specs/NNNN-slug/spec.md`), si la hay.
3. Los ADRs relevantes en [`docs/decisions/`](./docs/decisions/README.md):
   los que lista la spec, más los que mencionan los repos, contratos o
   proveedores involucrados (`grep -rl "<repo|proveedor>" docs/decisions`).
4. [`specs/constitution.md`](./specs/constitution.md) y la
   `specs/constitution.md` de cada repo tocado.
5. El documento de schema de cada contrato involucrado (campo `schema` del
   manifest).

Un ADR con status `Accepted` es una restricción: si un diseño o una
implementación necesita contradecirlo, el agente se detiene y lo reporta
como "requiere supersede" — nunca lo contradice en silencio ni edita el
ADR para que coincida.

## Validación

`make docs-check` valida la base de conocimiento. Se corre en la Fase 6 de
`/agentic-sdd:feature` y antes de commitear cambios de documentación.
