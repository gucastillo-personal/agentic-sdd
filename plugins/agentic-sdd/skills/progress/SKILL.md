---
name: progress
description: Muestra el avance en porcentaje de una spec según sus tareas (tasks.md): total, por sección (Backend, Frontend, Infra…), qué falta y qué está bloqueado. Usar cuando el usuario pregunta "¿cuánto llevamos de la 0017?", "progreso", "% de avance" o quiere el estado de una spec.
argument-hint: "[número o slug de la spec, ej. 0017]"
---

# /agentic-sdd:progress — avance de una spec en %

## Pasos

1. **Ubicar la spec**: `specs/NNNN-*/tasks.md` según el argumento (sin argumento: la spec en curso o la más reciente; si hay duda, preguntar una vez). Leer el `tasks.md` de **`origin/main`** y el de la rama actual si difieren (`git show origin/main:specs/NNNN-slug/tasks.md`), y avisar si el árbol local está desactualizado.
2. **Contar** con el script (solo lectura):
   `sh "${CLAUDE_PLUGIN_ROOT}/scripts/count-tasks.sh" <ruta/tasks.md>`
   Salida por línea: `sección<TAB>hechas<TAB>total<TAB>retiradas`. Las tareas tachadas (`~~`) se excluyen del total y se informan aparte.
3. **Verificar contra la realidad** antes de reportar (git/gh, solo lectura): una tarea sin tildar pero ya mergeada, o tildada pero sin código, se marca como **discrepancia** (ej. tareas hechas en un PR abierto o draft). No corregir `tasks.md` sin que el usuario lo pida.
4. **Calcular**: % = hechas / total (redondeo al entero). Dar el global y el de cada sección. Si `tasks.md` trae una tabla de horas por bloque, dar también el % ponderado por horas estimadas y decir cuál es cuál.
5. **Reportar corto**:
   - Barra de texto y % global (ej. `████░░░░░░ 38% (20/53)`).
   - Tabla por sección: hechas/total y %.
   - Tareas hechas pero en PR abierto/draft (cuentan, pero no están en main).
   - Siguiente bloque sugerido y qué lo bloquea (dependencias de `tasks.md`, tareas manuales del owner).
   - Discrepancias encontradas.

## Reglas
- Solo lectura: no editar, commitear ni pushear.
- Una tarea cuenta como hecha solo si está tildada `[x]`; lo demás es una observación, no un cambio de número.
- Mostrar siempre los conteos crudos junto al %, para poder auditarlos.
