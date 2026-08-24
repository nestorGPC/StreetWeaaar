# BITÁCORA DE TRABAJO — Proyecto Final StreetWear CR
**Curso:** Tecnologías y Sistemas Web II (ITI-523) · **Componente:** Proceso de Trabajo y Bitácora
**Estudiante:** Nestor Palacios · **Repositorio:** github.com/nestorGPC/StreetWeaaar (rama `main`)
**Periodo:** 27 de julio – 24 de agosto de 2026 · **Control de versiones:** Git/GitHub

> Toda entrada está respaldada por un commit verificable con `git log --oneline`.

---

## 1. RESUMEN GENERAL DEL PROCESO

| # | Fecha | Actividad principal | Commit | Impacto |
|---|-------|---------------------|--------|---------|
| S1 | 27-jul | Creación del proyecto y base del catálogo | `6b68270` | 126 archivos, +18.325 líns |
| S2 | 28-jul | Identidad del proyecto + búsqueda/filtros | `bfe1f80`, `3ce2980` | +299 líns |
| S3 | 29-jul | Autenticación, checkout transaccional, pedidos, pagos, admin | `e134dd5`, `354b4cc` | 49 archivos, +3.330 |
| S4 | 29-jul | Cookies de productos recientes (rama de respaldo) | `2991367` | +184 |
| S5 | 10-ago | Integración final, despliegue alwaysdata y corrección HTTPS | `33ed2b0`→`d85c65b` | 209 archivos, +28.369 |
| S6 | 19-ago | Auditoría interna contra requisitos y plan priorizado | `e758a65` | +973 líns |
| S7 | 24-ago | Auditoría de los 32 puntos de la rúbrica + guías de defensa | `1df358a`, `eefbbc5` | +3.733 / −3.077 |
| S8 | 24-ago | Guía de pruebas y verificación final en hosting | `c88e68f` | +114 |

---

## 2. METODOLOGÍA DE TRABAJO
- Desarrollo incremental con **commits pequeños y mensajes descriptivos** en español.
- **Rama de respaldo** `backup/pre-integracion-2026-08-10` creada antes de fusionar avances a `main`.
- Cada sesión cierra con: código funcionando → commit → nota en bitácora.
- Verificación continua con la suite de pruebas PHPUnit (41 tests / 129 assertions al cierre).

---

## 3. BITÁCORA POR SESIONES

### S1 — 27 de julio, 23:31 · Base del proyecto
**Objetivo:** levantar el esqueleto de la tienda.
**Actividades:** creación del proyecto Laravel (PHP 8.2, SQLite); migraciones base (users, cache, jobs); modelos y migraciones de Category/Product; catálogo inicial con listado y detalle; layout Bootstrap con Vite.
**Problema/solución:** SQLite requería activar llaves foráneas → `foreign_key_constraints => true` en config/database.php.
**Evidencia:** commit `6b68270` (126 archivos).

### S2 — 28 de julio · Identidad y búsqueda
**Actividades:** renombrado y documentación con identidad StreetWear CR (`bfe1f80`); buscador por nombre (LIKE parametrizado) y filtros por categoría y rango de precio acumulables sobre un mismo query builder (`3ce2980`, +299 líneas).
**Problema/solución:** texto no numérico en precios rompía la consulta → guardas `filled()` + `is_numeric()`.
**Aprendizaje:** construir condiciones condicionales sobre un Query Builder evita consultas duplicadas por cada filtro.

### S3 — 29 de julio (noche) · Núcleo comercial — sesión clave
**Objetivo:** autenticación + proceso completo de compra + administración.
**Actividades:** AuthController (registro con rol customer automático, login/logout con throttle 5/min); migraciones orders/order_items/payments; checkout dentro de `DB::transaction` con `lockForUpdate` (anti sobreventa) y token de idempotencia comparado con `hash_equals`; generación de tracking único `SWCR-FECHA-XXXXXX`; panel de administración Filament con roles Spatie (`super_admin`/`customer`); seeders de datos demo (`354b4cc`).
**Problemas/soluciones:**
- Doble clic creaba dos pedidos → token de un solo uso consumido con `session()->pull()`.
- Dos compras simultáneas podían vender el último stock → bloqueo pesimista por fila.
**Evidencia:** `e134dd5` (49 archivos, +3.330 líneas) + 2 tests de idempotencia.

### S4 — 29 de julio · Productos vistos recientemente (cookies)
**Actividades:** cookie `recent_products` (JSON, máx. 5 IDs, 30 días) escrita con `Cookie::queue` al ver un producto; sección "vistos recientemente" excluyendo el actual y mostrando solo activos.
**Problema/solución:** `whereIn` no conserva el orden → reordenamiento en PHP según posición del ID en la cookie.
**Evidencia:** commit `2991367` en rama de respaldo + 3 tests dedicados.

### S5 — 10 de agosto · Integración, despliegue y HTTPS
**Objetivo:** fusionar todo en `main` y publicar en hosting siempredata.
**Actividades:** integración consolidada (`33ed2b0`, 209 archivos); suite de pruebas completas (11 suites feature); reportes PDF con DomPDF (ventas por mes y por cliente protegidos con rol); script y documentación de despliegue (`e54994f`).
**Problema principal y solución:** el sitio quedaba en HTTP tras desplegar detrás del proxy inverso de alwaysdata. Primer intento con `RewriteCond %{HTTPS}` NO funcionaba porque el proxy termina el TLS. Lectura de cabeceras → redirección correcta usando `X-Forwarded-Proto` (`b33755e`, luego ajuste fino en `d85c65b`). Verificado: http→301→https.
**Aprendizaje:** detrás de un reverse proxy, las variables estándar de TLS no reflejan la realidad; hay que confiar en la cabecera que el proxy agrega.

### S6 — 19 de agosto · Auditoría interna y planificación
**Actividades:** revisión completa contra los requisitos del curso; identificación de brechas (pasarela de pagos pendiente, permisos granulares); plan de trabajo priorizado por criticidad.
**Evidencia:** commit `e758a65` (+973 líneas de documentación de auditoría).

### S7 — 24 de agosto (madrugada) · Auditoría estricta de la rúbrica
**Objetivo:** mapear los 32 puntos de la rúbrica oficial a código real.
**Actividades:** ejecución de pruebas exigidas (git status/remote/log, artisan test/about/migrate:status/route:list); verificación en vivo del hosting (HTTP 200, imágenes, CSS); corrección de permisos Filament Shield (73 permisos asignados al rol admin); creación de 32 documentos individuales + auditoría general + guía de defensa + banco de 63 preguntas/respuestas + índice de localización; eliminación de documentación obsoleta que contenía afirmaciones ya incorrectas.
**Resultados medibles:** ✅ 23 puntos cumplen · ⚠️ 3 con deficiencias documentadas · 🔍 6 administrativos · suite 41 passed / 129 assertions.
**Evidencia:** `1df358a` (+3.733) y `eefbbc5` (−3.077 de docs viejas).

### S8 — 24 de agosto (mañana) · Guía de pruebas y verificación final
**Actividades:** guía de pruebas automatizadas y manuales (cliente 19 pasos, admin 9, seguridad 6, responsive, smoke test de hosting); re-ejecución de la suite en verde; verificación del enlace público respondiendo 200.
**Evidencia:** commit `c88e68f`; URL https://nestor-alwaysdata-net.alwaysdata.net operativa.

---

## 4. ESTADÍSTICAS FINALES
- **Commits en main:** 13 · **Rama adicional de respaldo:** 1 · **Historial total:** 16 entradas.
- **Líneas acumuladas:** >54.000 insertadas · **Archivos versionados:** 215 (sin vendor/node_modules/.env).
- **Suite de pruebas:** 41 tests, 129 assertions, 100% en verde al cierre.
- **Despliegue:** producción funcionando con HTTPS forzado y certificado gratuito.

## 5. LECCIONES APRENDIDAS
1. La consistencia de inventario exige transacción + bloqueo de fila + revalidación server-side; la sesión del carrito nunca es fuente de verdad para cobrar.
2. La idempotencia (token de un solo uso) resuelve un problema real que ningún formulario "simple" cubre.
3. Desplegar detrás de un proxy cambia supuestos básicos (HTTPS vía X-Forwarded-Proto).
4. Auditar ANTES de entregar convierte supuestos en hechos verificables y detecta contradicciones entre documentación y código.
5. Los tests primero parecen costo, después son la red que permite refactorizar sin miedo.

## 6. CÓMO VERIFICAR ESTA BITÁCORA (para el docente)
```bash
git log --oneline --all            # historial completo
git log --stat                     # detalle de archivos por commit
git shortlog -sne                  # autoría
git branch -a                      # rama de respaldo incluida
```
