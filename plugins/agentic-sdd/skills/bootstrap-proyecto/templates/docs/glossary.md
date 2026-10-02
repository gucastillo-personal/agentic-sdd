# Glosario — {{PROYECTO}}

Términos del dominio y del proceso. Una línea por término; si un término
necesita más, linkea a la nota o al ADR que lo explica.

## Proceso

| Término | Significado |
|---|---|
| ADR | Architecture Decision Record: una decisión con su contexto, alternativas y consecuencias. Ver [`decisions/`](./decisions/README.md) |
| Spec | La definición de una feature (`specs/NNNN-slug/spec.md`): problema, objetivo, alcance y criterios de aceptación |
| AC | Criterio de aceptación: un resultado observable y testeable de una spec |
| Gate | El comando que tiene que pasar antes de dar algo por terminado (`gate` de cada repo en el manifest), o la aprobación humana entre fases de `/agentic-sdd:feature` |
| Requiere supersede | Un cambio que contradice un ADR `Accepted`: no se hace sin un ADR nuevo que lo reemplace |

## Dominio

| Término | Significado |
|---|---|
