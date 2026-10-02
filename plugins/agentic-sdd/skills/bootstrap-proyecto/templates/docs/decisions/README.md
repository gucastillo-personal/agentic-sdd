# Decisiones (ADRs) — {{PROYECTO}}

Registro de las decisiones que explican **por qué** el sistema está
construido como está. Un ADR vive independiente de la feature que lo
originó: la feature describe *qué cambia*, el ADR describe *por qué
elegimos así* y sigue vigente después de que la feature se cerró.

Todos los ADRs del proyecto viven acá, en {{REPO_RAIZ}}, con una sola
numeración global (`ADR-0001`, `ADR-0002`, …), incluso cuando una decisión
toca un solo repo. El formato está en [`_template.md`](./_template.md).

## Qué va a ADR y qué no

| Nivel | Es este nivel si… | Dónde se registra |
|---|---|---|
| **L0 — local** | Queda dentro de un módulo, se revierte en el mismo PR, no cambia contratos ni dependencias. Ej.: un `Map` en vez de un array | Nada, o una línea en `plan.md` |
| **L1 — técnica relevante** | Librería o patrón durable dentro de **un solo repo**, sin cruzar fronteras. Ej.: arquitectura hexagonal liviana en un servicio | Tabla `### Decisiones` en la sección del agente dueño en el `plan.md` de la spec, con ID `D-<spec>-<n>` (ej. `D-0003-02`). **Se promueve a ADR** cuando otra feature o repo pasa a depender de ella |
| **L2 — arquitectónica** | Crea o elimina un repo, cambia un contrato entre repos (ver `manifest.yaml`), agrega una dependencia entre repos, cambia el modo de comunicación o de persistencia, o toca una invariante de `constitution.md` | **ADR obligatorio** |
| **L3 — estratégica (proveedor/infra)** | Proveedor o cuenta externa nueva, excepción a la regla de costo de la constitution, datos personales que salen a un tercero (según la ley que aplique), recursos cloud nuevos | **ADR obligatorio**, con costo, plan de salida y tratamiento de datos |

Desempate: si alguien que llega en 6 meses se preguntaría "¿por qué
hicieron esto?" y el nivel es L1 o más, va ADR.

## Checklist de detección

Se responde en la Fase 1 de `/agentic-sdd:feature` (decisiones candidatas) y en la
Fase 3 (definitivas):

1. ¿La feature requiere una decisión arquitectónica?
2. ¿Ya hay un ADR que la resuelve? (buscar en el índice de abajo)
3. ¿Hay una decisión L1 relacionada en el `plan.md` de otra spec?
4. ¿Introduce una tecnología nueva?
5. ¿Elige un proveedor?
6. ¿Cambia un ADR `Accepted`?
7. ¿Descarta una alternativa que en su momento se eligió?
8. ¿Crea una dependencia nueva entre repos o cambia un contrato?

## Ciclo de vida

`Proposed` (se redacta en la Fase 3) → `Accepted` (aprobación explícita
del dueño del proyecto en el gate de la Fase 3, ADR por ADR) → `Superseded` /
`Deprecated`.

| Situación | Acción |
|---|---|
| La feature trabaja dentro de una decisión existente | **Reutilizar**: la spec lo lista en `## Decisiones relacionadas` |
| Amplía el alcance sin contradecir la decisión | **ADR nuevo** con `extends: ADR-x`. El viejo no se edita |
| La elección se revierte, o se adopta una alternativa que antes se había descartado | **Supersede**: ADR nuevo con `supersedes: ADR-x`; el viejo pasa a `Superseded` y gana `superseded_by`. Las dos cosas en el mismo PR |
| El componente desaparece y no hay reemplazo | `Deprecated` |
| Hallazgo real que no cambia la decisión | Nota fechada en `## Notas posteriores` (solo se agrega, nunca se edita) |
| ADR en `Proposed` | Se edita libremente |
| ADR en `Accepted` | Solo se puede editar: `status`, `superseded_by`, `## Notas posteriores` y typos. **Nunca se reescribe la decisión** |

Si en la Fase 4 la implementación se aparta de un ADR `Accepted`, el
agente se detiene y lo reporta — igual que un conflicto con
`constitution.md`. No se "corrige" el ADR para que coincida con el código.

## Cómo se linkea

- **Frontmatter** (relaciones del grafo): wikilinks entre comillas,
  `"[[ADR-0001-slug]]"`. Obsidian los toma como aristas y un
  agente los parsea como YAML.
- **Cuerpo**: links Markdown relativos,
  `[ADR-0001](./ADR-0001-slug.md)`. Funcionan en GitHub, en
  Obsidian y para agentes.
- **Cada relación se escribe una sola vez**, del lado del documento más
  nuevo o más específico. Un ADR lista su spec de origen, no las features
  que lo usan después; esas lo referencian desde su propia spec, y la
  relación inversa se obtiene por backlinks (Obsidian) o con
  `grep -rl "ADR-0001" specs docs` (agente). Así un ADR `Accepted` nunca
  tiene que editarse porque una feature nueva lo usa.

## Índice

| ADR | Decisión | Nivel | Estado | Origen |
|---|---|---|---|---|
