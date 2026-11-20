---
name: resume
description: Retoma una feature donde quedó, leyendo el resumen dejado por /agentic-sdd:pause y contrastándolo con el estado real de git y GitHub. Usar al abrir una sesión nueva ("seguimos con la 0017", "retomar", "¿dónde quedamos?").
argument-hint: "[slug-o-número-de-spec, opcional]"
---

# /agentic-sdd:resume — continuar desde donde se dejó

## Pasos

1. **Ubicar el resumen**: `project_<slug>_estado.md` en la memoria del proyecto (o el que coincida con el argumento). Sin argumento: el más reciente entre los de tipo `project`. Si no hay, decirlo y reconstruir desde `specs/` + git.
2. **Cargar el contexto de descubrimiento** según el CLAUDE.md del proyecto (manifest, spec en curso, ADRs relevantes, constitution). Leer `tasks.md` de la spec.
3. **Contrastar con la realidad** (solo lectura), por cada repo tocado:
   - `git fetch` y estado de rama, `git status --short`, últimos commits.
   - `gh pr list --state all` y `gh pr view` de los PRs citados: ¿se mergearon, cambiaron, tienen comentarios o CI en rojo?
   - Si el resumen y los repos difieren, **manda lo que muestran los repos**; marcar las diferencias.
4. **Reportar en formato corto**:
   - Dónde estábamos (2–3 líneas).
   - Qué cambió desde entonces (PRs mergeados, CI, ramas).
   - Qué hay que actualizar antes de seguir (main local atrasado, ramas viejas, tareas sin tildar).
   - Próximo paso propuesto, con su orden.
   - Decisiones/dudas abiertas que requieren al owner.
5. **Pedir confirmación** antes de actuar: preguntar con qué tarea seguir. No lanzar agentes ni crear ramas hasta tener el OK.

## Reglas
- Mismas reglas del proyecto: nunca commit/push/merge sin aprobación explícita; nunca a `main` directo.
- No confiar en la memoria como estado actual: verificar rutas, ramas y PRs que cita antes de recomendarlos.
- Al terminar la sesión, recordar `/agentic-sdd:pause`.
