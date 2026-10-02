---
type: runbook
---

# Runbook: rollback después de un merge que rompe

Qué hacer cuando algo mergeado a `main` rompe producción. El orden es
siempre el mismo:

1. **Mitigar**: volver rápido al estado anterior, sin tocar git si se
   puede.
2. **Revertir el código** por PR, como cualquier otro cambio (nunca push
   directo a `main`, nunca merge por un agente: [`CLAUDE.md`](../CLAUDE.md)).
3. **Arreglar hacia adelante** con calma, en una rama nueva.

Cómo despliega cada repo: campo `deploy` de cada entrada en
[`manifest.yaml`](../manifest.yaml).

## Revertir un PR (cualquier repo)

- **Desde GitHub**: en el PR mergeado, botón **Revert**. Crea una rama y un
  PR que deshace el merge. Revisarlo y mergearlo a mano.
- **Desde la terminal** (equivalente):

  ```sh
  git switch -c revert/<slug> origin/main
  git revert -m 1 <sha del merge commit>
  git push -u origin revert/<slug>
  gh pr create --fill
  ```

- El PR de revert pasa por los mismos checks que cualquier otro.
- Si el repo no despliega solo al mergear, revertir el código **no
  despliega**: ver la sección de ese repo.

## Por repo

<!-- Una sección por repo con despliegue propio. Para cada uno:
     - cómo se mitiga sin desplegar (rollback del hosting, flag de
       mantenimiento, kill-switch);
     - cómo se vuelve a la versión anterior;
     - qué no se revierte solo (variables de entorno, migraciones de datos,
       mensajes ya enviados);
     - qué hay que deshacer después del rollback (por ejemplo, reactivar
       la promoción automática del hosting). -->
