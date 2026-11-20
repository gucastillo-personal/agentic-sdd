#!/bin/sh
# Uso: contar.sh <tasks.md>
# Cuenta tareas "- [ ]" / "- [x]" de primer nivel por sección "## ", ignorando
# las retiradas (texto tachado con ~~) y las subtareas indentadas.
awk '
/^## / { sec=substr($0,4); if (!(sec in orden)) { orden[sec]=++n; nombre[n]=sec } next }
/^- \[[ xX]\] / {
  if ($0 ~ /~~/) { ret[sec]++; next }
  if ($0 ~ /^- \[[xX]\]/) hechas[sec]++; else pend[sec]++
}
END {
  for (i=1;i<=n;i++) { s=nombre[i]; t=hechas[s]+pend[s]; if (t+ret[s]==0) continue
    printf "%s\t%d\t%d\t%d\n", s, hechas[s]+0, t, ret[s]+0 }
}' "$1"
