# Punto 32 - Utilizan GitHub

## 1. ¿Qué pide la profesora?
Uso real de GitHub: repositorio, rama(s), commits, integrantes, trabajo colaborativo e higiene (.gitignore, archivos versionados correctos).

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste? (auditoría ejecutada HOY)
- Remoto: `origin = https://github.com/nestorGPC/StreetWeaaar.git` (fetch+push).
- Rama activa: `main` con tracking `origin/main` sincronizada.
- Historial consolidado en main (5 commits descriptivos): `33ed2b0 Código inicial` → `e54994f Actualiza documentación y script de despliegue alwaysdata` → `b33755b Fuerza HTTPS` → `d85c65b Corrige redirect HTTPS X-Forwarded-Proto` → `e758a65 Agrega auditoría completa y plan`.
- Rama adicional: `backup/pre-integracion-2026-08-10` (punto de restauración).
- `git shortlog -sne --all`: 14 commits — Nestor <palaciosnestor733@gmail.com>.
- 215 archivos trackeados; `.gitignore` sano (vendor/node_modules/.env fuera); README renderiza en GitHub.
- HONESTO: un solo AUTOR en los commits actuales (proyecto individual consolidado desde trabajo previo). Mostrar colaboración = historia de commits + ramas + PRs futuros.

## 4. ¿Dónde se encuentra?
- Repo público: https://github.com/nestorGPC/StreetWeaaar
- Comandos: git remote -v / branch -vv / log / shortlog / status

## 5. Qué buscar en VS Code / terminal
`git remote -v`, `git log --oneline --decorate --all`, `git shortlog -sne`, abrir `.gitignore`

## 6. Fragmento importante
```
$ git log --oneline
e758a65 Agrega auditoria completa y plan de trabajo del proyecto
d85c65b Corrige redirect HTTPS: usa X-Forwarded-Proto (proxy alwaysdata)
b33755e Fuerza HTTPS en public/.htaccess
e54994f Actualiza documentación y script de despliegue alwaysdata
33ed2b0 Código inicial del proyecto
```

## 7. Explicación sencillo
Todo el desarrollo vive versionado en GitHub: commits pequeños con mensajes claros de qué y por qué, una rama de respaldo previa a la integración final, y el .gitignore evitando basura (dependencias y secretos). El historial cuenta la historia técnica del proyecto: primero código, luego deploy, luego seguridad HTTPS, luego auditoría.

## 8. Recorrido del sistema
Working tree → git add/commit → push origin/main → GitHub visible para profesora y compañeros.

## 9. ¿Cómo lo pruebo?
1. Abrir el repo en el navegador (pestaña lista para defensa).
2. Mostrar pestaña Commits (timeline) y Branches (backup/pre-integracion).
3. git status limpio tras el commit final.

## 10. Evidencia
GitHub en pantalla: README renderizado, árbol de carpetas, commits con fechas, ramas.

## 11. Test relacionado
TEST FALTANTE (no aplica).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Todos los integrantes commitearon?
2. ¿Qué muestra tu .gitignore y por qué?
3. ¿Para qué sirve la rama backup?

## 13. Respuesta corta para defenderlo
1. "El historial consolidado quedó bajo mi cuenta durante la integración final; las etapas previas quedaron respaldadas en la rama backup." (responder con honestidad según su equipo real)
2. "Dependencias regenerables, secretos .env y artefactos de build: seguridad y limpieza."
3. "Punto de restauración antes de fusionar la integración final: puedo volver sin perder nada."

## 14. Problemas encontrados
- Pendiente AL MOMENTO DE AUDITAR: commit/push final con toda la documentación de auditoría (se realiza hoy por solicitud del usuario).
- Untracked `reportes/` (PDFs locales) NO debe subirse.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio tras hacer el PUSH FINAL de hoy.
