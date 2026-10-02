# Constitution — {{PROYECTO}}

Principios no negociables de {{PROYECTO}} y de todos sus repos. Toda spec,
plan, PR y revisión se chequea contra este archivo, además de contra la
`specs/constitution.md` propia de cada repo tocado. Enmendarlo requiere
una nota en la descripción del PR que explique por qué.

El **por qué** de cada invariante está en los ADRs que la justifican o la
aplican ([`docs/decisions/`](../docs/decisions/README.md)), enlazados al
final de cada ítem con una línea `*Decisiones:*`.

Las reglas de flujo de trabajo (aprobación humana, ramas, merges) no van
acá: viven en [`CLAUDE.md`](../CLAUDE.md).

> **Borrador del bootstrap.** Las invariantes de abajo son un punto de
> partida que propone `agentic-sdd`. {{DUENO}} las revisa, borra las que no
> apliquen y agrega las propias antes de la primera feature. Mientras diga
> "borrador", ningún agente las trata como cerradas.

---

## I. Seguridad

1. **Ningún secreto (API key, token, credencial) se commitea en ningún
   repo.** Siempre en el mecanismo de secretos que fije un ADR, nunca en
   código ni en docs de ejemplo con un valor real.
2. **Los datos privados no salen de donde tienen que estar.** <Definir
   cuáles son: costos, datos personales, datos del cliente, etc., y qué
   repos pueden verlos.>

## II. Arquitectura

3. **Un repo, una responsabilidad.** Cada repo tiene un rol único
   (`responsibility` en `manifest.yaml`) y no absorbe el de otro. Si una
   feature no encaja limpiamente en un repo existente, necesita uno nuevo,
   no una excepción al alcance de uno existente.
4. **Un repo nuevo nunca invalida una invariante ya cerrada de otro.** Si
   una feature parece requerirlo, la resolución por defecto es poner el
   trabajo nuevo en un repo que no la viola.
5. **Costo de infraestructura.** <Definir el default: por ejemplo, "solo
   free tier y pago por uso; toda excepción es explícita, acotada a la
   feature y aprobada en un ADR".>

## III. Flujo spec-driven

6. **Una feature que toca dos o más repos, o crea uno, tiene su
   `specs/NNNN-slug/` en el repo raíz.** Una feature de un solo repo tiene
   su spec en ese repo.
7. **`plan.md` y `tasks.md` llevan una sección por agente dueño**
   (`## Frontend`, `## Backend`, `## AI`, `## Infra`), sin reescribir la de
   otro. Las divergencias se documentan y se resuelven antes de
   implementar.
8. **Nada se crea ni se aprovisiona en modo diseño.** Crear un repo o
   aprovisionar infraestructura es implementación, y requiere la misma
   aprobación humana que instalar herramientas.
