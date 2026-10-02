# Specs — {{PROYECTO}}

Una carpeta por feature, con el formato de spec-driven development de
`agentic-sdd`.

- Una feature que vive **dentro de un solo repo** tiene su
  `specs/NNNN-slug/` en ese repo.
- Una feature que **toca dos o más repos**, o crea uno, tiene su
  `specs/NNNN-slug/` acá, en el repo raíz. Cada repo tocado registra en su
  propia PRD solo los requisitos que le tocan, apuntando acá.

## Layout

```
specs/
├── constitution.md          # invariantes no negociables
├── README.md                # este archivo
└── NNNN-slug/
    ├── spec.md               # QUÉ y POR QUÉ — criterios de aceptación
    ├── ux.md                 # cuando hay superficie visible
    ├── plan.md               # CÓMO — una sección por agente dueño
    ├── tasks.md              # ídem, tareas ordenadas
    └── rfc-*.md              # un RFC por repo nuevo o superficie técnica nueva
```

## Frontmatter de la spec

El `spec.md` de cada feature abre con un frontmatter YAML que la conecta al
grafo de conocimiento. Solo lo lleva `spec.md`.

```yaml
---
id: "NNNN"                     # entre comillas, para conservar los ceros
title: <feature en una línea>
type: spec
status: draft                  # draft | design | approved | implementing | done | done-with-debt | abandoned
created: YYYY-MM-DD
closed:                        # fecha de cierre, si aplica
repos: ["[[repo-xxx]]"]                    # repos que toca o crea
domains: ["[[domain-xxx]]"]
contracts: ["[[contract-xxx]]"]            # contratos que crea, cambia o consume
providers: ["[[provider-xxx]]"]            # proveedores que suma o usa
decisions: ["[[ADR-NNNN-slug]]"]           # ADRs existentes que reutiliza o la condicionan
---
```

`decisions` lista solo los ADRs **previos** que la feature reutiliza o que
la restringen. Los ADRs que **nacen** en la spec ya la nombran en su propio
`origin`, así que no se repiten acá: se encuentran por backlinks en
Obsidian o con `grep -l 'origin:.*NNNN' docs/decisions/ADR-*.md`. El cuerpo
de la spec repite la lista de `decisions` como links Markdown en
`## Decisiones relacionadas`.

## Feature index

| ID | Feature | Repos que toca | Status |
|----|---------|-----------------|--------|
