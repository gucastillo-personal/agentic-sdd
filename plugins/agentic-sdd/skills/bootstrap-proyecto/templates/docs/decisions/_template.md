---
id: ADR-NNNN
title: <decisión en una línea>
status: Proposed              # Proposed | Accepted | Superseded | Deprecated
date: YYYY-MM-DD              # fecha de la decisión (en backfill: la original)
deciders: <rol del dueño del proyecto>
level: L2                     # L2 arquitectónica | L3 proveedor/infra (ver README)
repos: ["[[repo-xxx]]"]
domains: ["[[domain-xxx]]"]
providers: []                 # ej. ["[[provider-aws]]"]
origin: ""                    # spec que la originó, ej. "[[specs/0003-slug/spec|0003]]"
supersedes: []                # ej. ["[[ADR-0003-xxx]]"]
extends: []
superseded_by:
constitution: []              # invariantes que toca o justifica, ej. ["§II.5 costo de infra"]
cost_impact: ""               # ej. "$0 (free tier)" o "≤ USD 20/mes"
personal_data: false          # true si involucra datos personales (según la ley que aplique)
reversibility: media          # baja | media | alta
retroactive: false            # true si se documentó después de tomada (backfill)
detail: ""                    # dónde está el diseño completo, ej. "specs/NNNN/rfc-xxx.md §5"
---

# ADR-NNNN — <título>

## Contexto

<!-- Qué pasaba y qué lo disparó. 3–6 líneas. Linkear la spec, no copiarla. -->

## Problema

<!-- Una frase: la pregunta que esta decisión responde. -->

## Restricciones

<!-- Invariantes de constitution.md y ADRs previos que condicionan la decisión, con link. -->

## Decisión

<!-- Lo elegido, corto y en presente: "Usamos X para Y." -->

## Alternativas consideradas

| Opción | A favor | En contra | Por qué no |
|---|---|---|---|
| | | | |

## Por qué

<!-- Las razones que inclinaron la elección. -->

## Consecuencias

<!-- Positivas y negativas. Qué queda obligado a partir de ahora (dependencias, contratos, operación). -->

## Trade-offs y riesgos

<!-- Riesgo → mitigación. -->

## Salida / reversión

<!-- Qué costaría deshacerla o cambiar de proveedor. Obligatorio en L3. -->

## Detalle técnico

<!-- Solo un link a la sección del RFC/plan con el diseño. No copiar el diseño acá. -->

## Notas posteriores

<!-- Append-only. Hallazgos reales que no cambian la decisión, con fecha:
- YYYY-MM-DD — ...
Si el hallazgo cambia la decisión, no va acá: corresponde un ADR nuevo que la reemplace. -->
