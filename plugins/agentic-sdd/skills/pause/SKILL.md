---
name: pause
description: Cierra la sesión dejando un resumen durable de dónde quedó el trabajo (hecho, PRs, tareas, próximo paso, abiertos) para retomarlo después con /agentic-sdd:resume, incluso desde otra terminal. Usar cuando el usuario dice "por hoy dejamos acá", "dejemos estatus", "pausar" o se va a cortar la sesión.
argument-hint: "[slug-de-la-feature, opcional]"
---

# /agentic-sdd:pause — dejar el estado para retomar

Objetivo: que otra sesión (otra consola, otro día) retome sin que el usuario repita el contexto.

## Pasos

1. **Identificar la feature**: el argumento, o la spec en curso (`specs/NNNN-slug/` del proyecto). Si hay duda, preguntar una sola vez.
2. **Leer el estado real, no la memoria de la conversación** (solo lectura):
   - Por cada repo tocado: `git branch --show-current`, `git status --short`, `git log --oneline -5`.
   - `gh pr list --state all --limit 15 --json number,title,state,isDraft,headRefName` por repo (distinguir abierto, draft, mergeado).
   - Estado de `tasks.md` de la spec (tildadas vs. hechas sin tildar).
   - Agentes en background todavía corriendo (resultados que se pierden si no se recogen).
3. **Escribir el resumen** en el archivo de memoria del proyecto `project_<slug>_estado.md` (carpeta de memoria del proyecto; si ya existe, actualizarlo, no duplicar) con frontmatter de memoria (`type: project`) y estas secciones:
   - **Decisiones del owner** (las que no se infieren del código).
   - **Estado al <fecha absoluta>**: hecho y mergeado; PRs abiertos con su número y quién tiene que actuar; ramas y último commit; trabajo sin commitear.
   - **Pendiente de docs** (tareas hechas sin tildar, tableros/Artifacts por sincronizar).
   - **Próximo paso** concreto y en orden.
   - **Abiertos / dudas** y cosas que NO se deben mezclar (archivos sueltos, punteros de submódulos).
   - **Patrón de trabajo** acordado (aprobaciones, quién mergea).
   Fechas siempre absolutas. Sin secretos ni datos de clientes.
4. **Actualizar el índice** `MEMORY.md` (una línea por memoria) si es un archivo nuevo.
5. **Sincronizar artefactos**: si la feature tiene un tablero/Artifact publicado, actualizarlo (con la skill/herramienta Artifact, `action: read` primero) para reflejar el estado. Si el cambio toca un repo, es un cambio normal: pedir aprobación antes de commit/push.
6. Si el trabajo sin commitear podría perderse (el scratchpad NO es durable), **avisar** y proponer commitear en una rama; nunca commitear sin aprobación.
7. **Responder breve**: qué quedó guardado, dónde, y la frase exacta para retomar (`/agentic-sdd:resume <slug>`).

## Reglas
- No hacer commit, push ni merge. Solo lectura de git/GitHub y escritura en la memoria.
- Verificar con comandos; no copiar de la conversación hechos que no se comprobaron.
