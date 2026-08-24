# AUDITORÍA RÚBRICA COMPLETA — StreetWear CR
Fecha: 2026-08-24 · Verificación en vivo: hosting OK (200) · Tests: 41 passed / 129 assertions · Repo: nestorGPC/StreetWeaaar @ main e758a65

| # | Requisito | Estado | Puntaje | Evidencia | Qué falta |
|---|-----------|--------|--------:|-----------|-----------|
| 1 | Entrega a tiempo | 🔍 NO VERIFICABLE | manual | Confirmación de plataforma | Subir ZIP dentro del plazo |
| 2 | ZIP ProyectoFinal-NombreEstudiantes | 🔍 NO VERIFICABLE (NO existe aún) | manual | ZIP creado | Crearlo hoy |
| 3 | Autenticación y gestión de usuarios | ✅ CUMPLE | 3 | Shield 73 permisos asignados; /admin Filament; canAccessPanel; AuthTest | — |
| 4 | Registro de usuarios nuevos | ✅ CUMPLE | 3 | AuthController@register → rol customer; test específico | — |
| 5 | Login/logout (+rate limit) | ✅ CUMPLE | 3 | throttle:5,1; AuthTest ×5 | — |
| 6 | Perfil editable + historial pedidos | ✅ CUMPLE | 3 | AccountController; AccountTest ×5 (incluye 403 ajeno) | — |
| 7 | Catálogo por categorías | ✅ CUMPLE | 3 | Relación Category↔Product; filtro; CRUD admin | — |
| 8 | Lista y detalle de productos | ✅ CUMPLE | 3 | index/show; imágenes storage 200 en hosting | — |
| 9 | Búsqueda y filtros combinables | ✅ CUMPLE | 3 | search/category/min/max; ProductCatalogTest ×3 | — |
| 10 | Carrito add/update/remove+stock | ⚠️ DEFICIENCIAS | 2 | CartTest ×7 verdes | Falta chequeo `active` en add() (~5 líneas) |
| 11 | Total con IVA y envío | ✅ CUMPLE | 3 | CartCalculator (13% / ₡3000); consistente carrito=checkout=order=payment | — |
| 12 | Tabla compra/factura | ✅ CUMPLE | 3 | orders (user_id, fecha, montos, tracking); relaciones ítems+pago | — |
| 13 | Opciones de pago + pasarela segura | ⚠️ DEFICIENCIAS | 2 | Selector card/paypal funcional; Payment pending registrado | Pasarela real no conectada (sin SDK/capture); README adelanta PayPal — alinear |
| 14 | Confirmación + tracking | ✅ CUMPLE | 3 | checkout.success; SWCR-YYYYMMDD-XXXXXX único | — |
| 15 | Reportes ventas mes/cliente PDF | ✅ CUMPLE | 3 | DomPDF real: ventasPorMes + ventasPorCliente + productos; solo super_admin | — |
| 16 | Backend PHP + Laravel + SQLite | ✅ CUMPLE | 3 | PHP8.2/Laravel12/SQLite; 9 migraciones; desplegado | — |
| 17 | Frontend adecuado | ✅ CUMPLE | 3 | Bootstrap/Vite; errores 403/404/500 propios; flash messages | — |
| 18 | Validación de entradas | ✅ CUMPLE | 3 | validate() en todos los controllers; tests negativos | (cubierto con fix del 10) |
| 19 | Cookies productos recientes | ✅ CUMPLE | 3 | recent_products JSON máx 5 / 30 días; RecentProductsTest ×3 | — |
| 20 | Mostrar recientes al usuario | ✅ CUMPLE | 3 | Sección en show excluyendo actual, solo activos | — |
| 21 | Código fuente completo | ✅ CUMPLE | 3 | 215 archivos trackeados; vendor/.env ignorados | Commit final de docs |
| 22 | Documentación detallada A–E | ✅ CUMPLE | 3 | README(instalación/credenciales) + MANUAL + diagrama-uso-compra | Alinear párrafo PayPal |
| 23 | Documento pruebas unitarias | ✅ CUMPLE | 3 | docs/PRUEBAS_UNITARIAS.md + suite 41/129 HOY | — |
| 24 | Exposición | 🔍 NO VERIFICABLE | manual | GUIA_DEFENSA_RUBRICA.md listo | Presentarse con guion |
| 25 | TODAS las funcionalidades | ⚠️ DEFICIENCIAS | 2 | Conclusión global puntos 3–23 | Depende de 10 y 13 |
| 26 | Responsive UX | ✅ CUMPLE | 3 | Bootstrap breakpoints; navbar hamburguesa | Pasada manual DevTools 10 min |
| 27 | Seguridad y datos sensibles | ✅ CUMPLE | 3 | bcrypt; CSRF; Eloquent puro (cero DB::raw); cero {!! !!}; HTTPS forzado; .env fuera de Git | APP_DEBUG=false en servidor |
| 28 | Calidad de código | ✅ CUMPLE | 3 | Transacción+lockForUpdate+idempotencia hash_equals; Service layer | — |
| 29 | Pregunta docente 1 | 🔍 PREPARACIÓN | manual | Banco grupo 1 (arquitectura) | Estudiar banco |
| 30 | Pregunta docente 2 | 🔍 PREPARACIÓN | manual | Banco grupo 2 (datos/cookies/reportes) | Estudiar banco |
| 31 | Pregunta docente 3 | 🔍 PREPARACIÓN | manual | Banco grupo 3 (seguridad/GitHub/honestidad pagos) | Estudiar banco |
| 32 | Utilizan GitHub | ✅ CUMPLE | 3 | Repo público, main sincronizada, rama backup, historial limpio | Push final de hoy |

## CONTEO
- ✅ Cumple a cabalidad: **23 / 32**
- ⚠️ Funciona con deficiencias: **3 / 32** (10, 13, 25)
- ❌ No cumple: **0 / 32**
- 🔍 No verificables (humanos/administrativos): **6 / 32** (1, 2, 24, 29, 30, 31)

## PUNTAJE TÉCNICO ESTIMADO (NO es nota oficial)
- Sobre los 26 puntos evaluables por código: **75 / 78 ≈ 96%**
- Si la parte manual (entrega/exposición/preguntas) se ejecuta bien sobre los 32: **93 / 96**
