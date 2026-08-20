# Auditoría Completa — StreetWear CR

> Fecha: 2026-08-19  
> Auditor: opencode (big-pickle)  
> Fuente de verdad: código actual en `C:\xampp\htdocs\StreetWear CR`  
> Commits: `d85c65b` (HEAD, main, origin/main)  
> Tests: 41 passed, 129 assertions, 0 failures  
> Build: `npm run build` OK, `public/build/manifest.json` generado

---

## 1. Resumen Ejecutivo

| Dimensión | Porcentaje | Calificación |
|---|---|---|
| Funcionalidad general | ~72% | FUNCIONA CON DEFICIENCIAS |
| Seguridad | ~65% | FUNCIONA CON DEFICIENCIAS |
| UX/UI | ~70% | FUNCIONA CON DEFICIENCIAS |
| Pruebas | ~55% | FUNCIONA CON DEFICIENCIAS |
| Documentación | ~80% | Casi completo |
| Hosting/Producción | ~85% | Casi completo |
| **Preparación para entrega** | **~65%** | **FUNCIONA CON DEFICIENCIAS** |

**Porcentaje general razonado: ~68%**

El sistema tiene una base sólida: catálogo, carrito, checkout con transacción, idempotencia, cookies de recientes, Filament admin, reportes PDF, roles/permisos, y despliegue en alwaysdata. Los gaps principales son: **PayPal no integrado** (solo selector visual + registro local pending), **reportes protegidos solo por `auth` middleware sin verificación de rol en ruta**, **no hay tests de PayPal, reportes de ventas/cliente, permisos admin, Filament, 403/404, HTTPS, ni seeders**, y **el Payment nunca cambia a paid automáticamente**.

---

## 2. Git — FASE 1

### 2.1 Estado actual

```
On branch main
origin: https://github.com/nestorGPC/StreetWeaaar.git
Branches: main, backup/pre-integracion-2026-08-10
```

### 2.2 Historial visible

**main (actual):**
```
d85c65b Corrige redirect HTTPS: usa X-Forwarded-Proto
b33755e Fuerza HTTPS en public/.htaccess
e54994f Actualiza documentación y script de despliegue alwaysdata
33ed2b0 Código inicial del proyecto          ← commit masivo (209 archivos, 28,369 inserciones)
```

**backup/pre-integracion-2026-08-10:**
```
2991367 Agrega productos vistos recientemente con cookies
354b4cc Agrega datos iniciales para entorno de desarrollo
e134dd5 Implementa autenticacion checkout pedidos pagos y administracion
3ce2980 Agrega busqueda y filtros al catalogo
bfe1f80 Actualiza identidad y documentacion de StreetWear CR
6b68270 Inicio del proyecto TiendaVirtual
```

### 2.3 Diagnóstico de Git

**¿Qué pasó?** El historial fue **consolidado intencionalmente**:

1. Existía un historial de desarrollo normal (6 commits de Néstor: `6b68270` → `2991367`)
2. Hubo un commit de dafc779-code (Darío) `ad00b54` ("Agregar sistema de reportes PDF") que fue integrado vía `git pull --ff-only` y luego absorbido
3. Néstor creó una rama `deploy-clean` con **un solo commit masivo** (`33ed2b0`) que contenía TODO el código consolidado
4. La rama `deploy-clean` fue **renombrada a main** (reflog: `HEAD@{5}: Branch: renamed refs/heads/deploy-clean to refs/heads/main`)
5. El historial original quedó en la rama `backup/pre-integracion-2026-08-10`
6. No hubo `git reset --hard` visible en reflog; fue una **consolidación deliberada**

**¿Por qué?** Probablemente para limpiar el historial antes del despliegue en alwaysdata (que usa `git pull --ff-only`). Al hacer squash, se evitan conflictos de merge.

**¿Está bien?** La información no se perdió (está en backup). Pero el historial en GitHub ahora muestra solo 4 commits cuando el equipo hizo mucho más trabajo.

### 2.4 Contribuciones

| Integrante | Commits en historial | Trabajo identificable |
|---|---|---|
| Néstor | 10 commits (todos los visibles) | TODO: MVC, auth, catálogo, carrito, checkout, Filament, deploy, HTTPS |
| Darío (dafc779-code) | 1 commit absorbido (`ad00b54`) | Sistema de reportes PDF (ReportController, vistas, rutas, composer require dompdf) |
| Andriy | 0 commits visibles | No se identifica código específico atribuible a Andriy |

**Nota:** El commit de Darío fue integrado al commit masivo de Néstor (`33ed2b0`). Su contribución real existe en el código pero no como commit separado en la rama main.

### 2.5 Riesgo Git

- El repo de GitHub (`nestorGPC/StreetWeaaar`) tiene un historial que no refleja el trabajo real del equipo
- Si la universidad pide historial de contribuciones, será difícil demostrarlo
- La rama `backup` no está push (solo local)

---

## 3. Archivos Untracked — FASE 2

### `docs/DEPLOY_ALWAYSDATA_PASO_A_PASO.md`
- **Contenido:** Bitácora detallada del despliegue + paso a paso replicable
- **Recomendación:** Agregar a Git. Es documentación técnica valiente y no contiene secretos

### `reportes/reporte-productos.pdf`
- **Contenido:** PDF generado (probablemente de una ejecución manual del reporte)
- **Recomendación:** NO agregar a Git. Es un artefacto generado. Agregar `reportes/` a `.gitignore`

### `requisitos.docx`
- **Contenido:** Documento Word — **no se puede leer directamente** desde la herramienta de análisis
- **Recomendación:** Convertir a Markdown y agregarlo a `docs/`, o leerlo manualmente para extraer la rúbrica

---

## 4. Stack Tecnológico — FASE 4

| Componente | Versión | Estado |
|---|---|---|
| Laravel | 12.64.0 | OK |
| PHP | ^8.2 | OK |
| SQLite | (la del sistema) | OK |
| Filament | ~5.0 | OK |
| Spatie Permission | 6.25.0 | OK (via Filament Shield) |
| Filament Shield | ^4.3 | OK |
| Bootstrap | ^5.3.8 | OK |
| Vite | ^7.0.7 | OK |
| Tailwind CSS | ^4.0.0 | OK (para Filament, no para frontend) |
| DomPDF | * (barryvdh/laravel-dompdf) | OK |
| PHPUnit | ^11.5.50 | OK |

**PayPal SDK:** NO instalado. No hay ningún paquete de PayPal en `composer.json` ni en `composer.lock`.

**Dependencias instaladas pero no utilizadas directamente:**
- `laravel/sail` (dev) — no se usa (Docker local)
- `laravel/pail` (dev) — no se usa activamente
- `concurrently` — usado en script `composer dev`
- `tailwindcss` — solo para Filament (el frontend usa Bootstrap)

---

## 5. Autenticación y Usuarios — FASE 5

| Funcionalidad | Estado | Evidencia |
|---|---|---|
| Registro | CUMPLE | `AuthController::register()` + test |
| Login | CUMPLE | `AuthController::login()` + test |
| Logout | CUMPLE | `AuthController::logout()` + test |
| Rate limiting (5/min) | CUMPLE | `throttle:5,1` en ruta + test |
| Perfil (ver/editar) | CUMPLE | `AccountController` + tests |
| Rol super_admin | CUMPLE | `RoleSeeder` + `UserSeeder` |
| Rol customer | CUMPLE | Asignado en registro y seeder |
| Protección /admin | CUMPLE | `AdminPanelProvider` + `canAccessPanel()` |
| Historial de pedidos | CUMPLE | `AccountController::orders()` + test |
| Detalle de pedido | CUMPLE | `AccountController::showOrder()` + test |
| Acceso a pedidos ajenos | CUMPLE | `abort_unless` + test |

**Deficiencia detectada:**
- Las rutas de `/admin` usan el middleware `Authenticate` de Filament, pero no hay un middleware `role:super_admin` explícito en `bootstrap/app.php`. La protección depende de `canAccessPanel()` en el modelo User. Esto es correcto pero frágil: si alguien agrega una ruta admin fuera de Filament, no estaría protegida.

---

## 6. Catálogo — FASE 6

| Funcionalidad | Estado | Evidencia |
|---|---|---|
| Categorías | CUMPLE | 4 categorías en seeder |
| Productos | CUMPLE | 5 productos demo con SVG |
| Imágenes | CUMPLE | SVGs en `storage/app/public/products/seed/` |
| Descripción | CUMPLE | Campo en BD y vistas |
| Precio | CUMPLE | Campo en BD, formato ₡ |
| Stock | CUMPLE | Campo en BD, validado en carrito/checkout |
| Activo/inactivo | CUMPLE | Toggle en Filament, filtrado en controlador |
| Búsqueda por nombre | CUMPLE | `LIKE` en `ProductController` + test |
| Filtro por categoría | CUMPLE | Filtro en controlador + test |
| Filtro por precio | CUMPLE | Min/max en controlador + test |
| Vista individual | CUMPLE | `ProductController::show()` + test |
| Productos recientes | CUMPLE | Cookie 30 días, máx 5, sin duplicados + test |
| Imágenes de demo | CUMPLE | 5 SVGs en seeder |

---

## 7. Carrito — FASE 7

| Funcionalidad | Estado | Evidencia |
|---|---|---|
| Agregar | CUMPLE | `CartController::add()` + test |
| Actualizar cantidad | CUMPLE | `CartController::update()` + test |
| Eliminar | CUMPLE | `CartController::remove()` + test |
| Cantidad mínima (1) | CUMPLE | Validación en `update()` |
| Stock máximo | CUMPLE | Validación en `add()` y `update()` |
| Producto agotado | CUMPLE | Check `stock <= 0` en `add()` + test |
| Producto inactivo | CUMPLE | Check en `update()` + test |
| Subtotal/IVA/envío/total | CUMPLE | `CartCalculator` consistente |
| Sesión | CUMPLE | `session()->get('cart')` |

**Inconsistencia menor:** `CartController::index()` calcula subtotal/total inline (sin usar `CartCalculator`), mientras que `CheckoutController` sí usa `CartCalculator`. Ambos usan la misma lógica (13% IVA, ₡3000 envío), pero es código duplicado.

---

## 8. Checkout — FASE 8

| Requisito | Estado | Evidencia |
|---|---|---|
| Precios desde BD | CUMPLE | `Product::lockForUpdate()->find()` en transacción |
| Stock validado | CUMPLE | `lockForUpdate` + check stock |
| Transacción DB | CUMPLE | `DB::transaction()` |
| Doble POST (idempotencia) | CUMPLE | Token de idempotencia + test |
| Tracking único | CUMPLE | Generador con verificación de unicidad |
| Creación de pedido | CUMPLE | `Order::create()` dentro de transacción |
| Detalles del pedido | CUMPLE | `OrderItem::create()` para cada producto |
| Pago registrado | CUMPLE | `Payment::create()` |
| Carrito vacío después | CUMPLE | `session()->forget('cart')` + test |
| Stock disminuido | CUMPLE | `$product->decrement()` + test |
| `order.subtotal == SUM(items.subtotal)` | CUMPLE | Calculado en loop, ambos desde BD |
| `payment.amount == order.total` | CUMPLE | `$total` usado para ambos |

**Problema crítico:** El `Payment` se crea con `status: 'pending'` y **nunca cambia a 'paid'**. No hay código que actualice el estado del pago después de la creación. El pago siempre queda pendiente.

---

## 9. Pagos — FASE 9

### Estado REAL del sistema de pagos

| Nivel | Estado |
|---|---|
| A. Selector visual Tarjeta/PayPal | EXISTE — Radio buttons en checkout |
| B. Payment local pending | EXISTE — Se crea con status `pending` |
| C. PayPal Sandbox integrado | **NO EXISTE** — No hay SDK, no hay API calls, no hay config |
| D. Pago verificado por proveedor | **NO EXISTE** |
| E. transaction_id real | **NO EXISTE** — Siempre `null` |
| F. Payment pasa a paid | **NO EXISTE** — Siempre queda pending |
| G. Order cambia tras pago | **NO EXISTE** |

### Evidencia

- `config/services.php`: NO tiene configuración de PayPal (solo default Laravel)
- `composer.json`: NO tiene paquete de PayPal
- `CheckoutController::store()` línea 171-178: Crea payment con `status: 'pending'`, `transaction_id: null`, `paid_at: null`
- Comentario en código (línea 169): *"Pago local de demostración. Más adelante esta parte se sustituye por una respuesta real de Stripe/PayPal sandbox."*
- Vista checkout: Selector visual de método de pago pero no hay JavaScript de PayPal SDK
- No hay webhook, no hay callback, no hay PayPal Orders API

### ¿Qué pasó con los commits de GitHub?

Los commits mencionados en el historial original ("Implementa pago con PayPal Sandbox", "Agregar pruebas de PayPal y correcciones de documentación") **NO existen en el código actual**. El commit consolidado `33ed2b0` no incluye integración PayPal real. Las "pruebas de PayPal" del commit anterior probablemente solo verificaban que el campo `method: 'paypal'` se guardara correctamente, no una integración real.

### Tests de PayPal

Los tests en `PaymentTest.php` usan `payment_method: 'paypal'` pero solo verifican que se guarde el string `'paypal'` como método y que el status quede `'pending'`. **No hay tests que:**
- Llamen a la API de PayPal
- Verifiquen un webhook
- Capturen un pago
- Actualicen el estado a paid
- Validen un transaction_id real

**Veredicto: NO CUMPLE — PayPal es puramente cosmético**

---

## 10. Reportes — FASE 10

| Funcionalidad | Estado | Evidencia |
|---|---|---|
| Ventas por mes | CUMPLE | `ReportController::sales()` + vista `reports/sales.blade.php` |
| Ventas por cliente | CUMPLE | `ReportController::sales()` incluye agrupación por cliente |
| Pedidos | CUMPLE | `ReportController::orders()` |
| Productos | CUMPLE | `ReportController::products()` |
| Filtros (fecha, estado, cliente) | CUMPLE | `aplicarFiltros()` en controlador |
| Totales | CUMPLE | En vista de ventas |
| PDFs descargables | CUMPLE | DomPDF + test de content-type |

**Problemas detectados:**

1. **Seguridad de rutas:** Las rutas `/reportes/*` están bajo middleware `auth` pero **NO** verifican rol `super_admin` a nivel de ruta. La verificación está en `ReportController::ensureIsAdmin()` usando `abort_unless()`. Funciona pero es frágil — si alguien crea otro controlador de reportes sin ese método, quedaría abierto.

2. **Test insuficiente:** Solo hay un test que descarga reporte de pedidos (`test_un_admin_puede_descargar_el_reporte_de_pedidos`). No hay tests para:
   - Descarga de reporte de ventas
   - Descarga de reporte de productos
   - Filtros por fecha/estado/cliente
   - Verificación de contenido del PDF (ventas por mes, ventas por cliente)

3. **Ruta de reportes index:** La ruta `/reportes` es GET y muestra una página con botones de descarga. No hay protección por CSRF adicional más allá del middleware global.

---

## 11. Cookies de Productos Recientes — FASE 11

| Funcionalidad | Estado | Evidencia |
|---|---|---|
| Guardar ID en cookie | CUMPLE | `ProductController::show()` + test |
| Duración 30 días | CUMPLE | `Cookie::queue(..., 60*24*30)` |
| Máximo 5 IDs | CUMPLE | `array_slice($recentIds, 0, 5)` + test |
| Sin duplicados | CUMPLE | Filtro antes de unshift + test |
| Orden (más reciente primero) | CUMPLE | `array_unshift` |
| Productos inactivos excluidos | CUMPLE | `->where('active', true)` en query |
| Sin cookie | CUMPLE | Default `'[]'` |
| Renderizado en vista | CUMPLE | Sección en `products/show.blade.php` |

---

## 12. Filament — FASE 12

| Recurso | CRUD | Form | Infolist | Seguridad |
|---|---|---|---|---|
| Categories | CUMPLE | CUMPLE | — | Shield |
| Products | CUMPLE | CUMPLE (con FileUpload) | — | Shield |
| Users | CUMPLE | CUMPLE (password handled) | CUMPLE | Shield |
| Orders | CUMPLE | CUMPLE (status editable) | CUMPLE | Shield |
| Payments | CUMPLE | CUMPLE (status editable) | CUMPLE | Shield |
| Roles (Shield) | CUMPLE | — | — | Shield |

**Detalles:**
- `canAccessPanel()` verifica `hasRole('super_admin')` — correcto
- Products permite subir imágenes vía `FileUpload` a disco `public`
- Orders: solo el campo `status` es editable; el resto es disabled
- Payments: solo `status` es editable
- Users: password es opcional en edición, requerido en creación
- La página de Reportes en Filament (`App\Filament\Pages\Reports`) solo muestra botones de descarga — no tiene lógica compleja

**Deficiencia:** No se genera el permisorio Shield para la página de Reportes. Solo se verifica `hasRole('super_admin')` en el método `shouldRegisterNavigation()`.

---

## 13. Base de Datos — FASE 13

### Migraciones (9)

| Migración | Tabla |
|---|---|
| `0001_01_01_000000` | users |
| `0001_01_01_000001` | cache |
| `0001_01_01_000002` | jobs |
| `2026_07_25_222903` | permission_tables (Spatie) |
| `2026_07_25_223112` | categories |
| `2026_07_25_223120` | products |
| `2026_07_29_034406` | orders |
| `2026_07_29_034408` | order_items |
| `2026_07_29_034409` | payments |

### Seeders

| Seeder | Contenido |
|---|---|
| RoleSeeder | super_admin, customer |
| UserSeeder | admin@streetwearcr.test, cliente@streetwearcr.test |
| CategorySeeder | Ropa, Tenis, Gorras, Accesorios |
| ProductSeeder | 5 productos con SVGs demo |
| OrderSeeder | 3 pedidos de prueba (pending/processing/shipped) |

### ¿`migrate:fresh --seed` produce sistema completo?

**SÍ** — Con una BD nueva, las migraciones + seeders crearían:
- Roles y permisos de Spatie
- Usuarios demo (admin + cliente)
- 4 categorías
- 5 productos con imágenes
- 3 pedidos con items y pagos
- Panel admin funcional

**Pero:** El seeder de pedidos usa `Order::factory()`, que depende de `fakerphp/faker` (require-dev). Con `composer install --no-dev`, el seeder fallaría.

---

## 14. Pruebas — FASE 14

### Cobertura actual

| Test | Tests | Assertions | Qué verifica |
|---|---|---|---|
| AccountTest | 5 | ~15 | Ver pedido propio, no ver ajeno, perfil, email único |
| AuthTest | 5 | ~12 | Registro, login, logout, password incorrecta, rate limit |
| CartTest | 7 | ~15 | Agregar, agotado, stock, actualizar, inactivo, eliminar |
| CheckoutTest | 3 | ~20 | Checkout completo, stock insuficiente, carrito vacío |
| CheckoutIdempotencyTest | 2 | ~6 | Doble POST, token inválido |
| ExampleTest | 2 | 2 | Placeholder |
| OrderTest | 2 | ~5 | Ver pedidos propios, no ver ajenos |
| PaymentTest | 3 | ~10 | Pago pending, actualizar estado, relación Order |
| ProductCatalogTest | 5 | ~12 | Catálogo, búsqueda, categoría, precio, detalle |
| RecentProductsTest | 3 | ~10 | Cookie, acumulación, máximo 5 |
| ReportTest | 4 | ~8 | Cliente no ve reportes, admin descarga pedidos |
| **TOTAL** | **41** | **129** | |

### Tests FALTANTES (críticos)

| Funcionalidad | Test faltante | Prioridad |
|---|---|---|
| PayPal integration | Llamada a API, capture, webhook | ALTA |
| Reporte de ventas | Descarga PDF de ventas | ALTA |
| Reporte de productos | Descarga PDF de productos | ALTA |
| Reporte ventas por mes | Verificar contenido del PDF | ALTA |
| Reporte ventas por cliente | Verificar contenido del PDF | ALTA |
| Filtros de reportes | Filtro por fecha, estado, cliente | MEDIA |
| Admin-only routes | 403 para no-admin en /reportes | MEDIA |
| 403 page | Vista de error 403 | MEDIA |
| 404 page | Vista de error 404 | MEDIA |
| HTTPS redirect | X-Forwarded-Proto | MEDIA |
| Seeders | `migrate:fresh --seed` completo | MEDIA |
| Stock rollback | Stock restaurado si pago falla | ALTA |
| Pago duplicado | No crear 2 pagos por pedido | MEDIA |
| Imágenes upload | Subir imagen en Filament | BAJA |
| Filament CRUD | CRUD en panel admin | BAJA |
| Roles admin | Solo admin accede a /admin | BAJA |

---

## 15. Errores Detectados — FASE 15 (parcial)

### Error: `CartController::index()` no usa `CartCalculator`

`CartController.php:14-24` calcula subtotal/total inline. `CheckoutController` usa `CartCalculator`. Si alguien cambia la tasa de IVA o el envío en `CartCalculator`, el carrito mostraría montos diferentes al checkout.

### Error: El Payment nunca pasa a paid

`CheckoutController::store()` crea el payment con `status: 'pending'` y no hay ningún mecanismo para actualizarlo. Incluso si el usuario elige "PayPal", el pago queda pendiente indefinidamente.

### Error: No hay restauración de stock si falla el pago

Si el pago falla después de la transacción (en un futuro con PayPal real), no hay código para restaurar el stock. Actualmente no es un problema porque el pago nunca falla (es demo), pero será crítico cuando se integre PayPal.

---

## 16. Seguridad — FASE 15 completa

| Vulnerabilidad | Estado | Detalle |
|---|---|---|
| CSRF | CUMPLE | `@csrf` en formularios, middleware VerifyCsrfToken |
| XSS | CUMPLE | Blade escapa output por defecto `{{ }}` |
| SQL Injection | CUMPLE | Eloquent queries, no raw SQL |
| Login throttle | CUMPLE | `throttle:5,1` en ruta |
| Sesiones | CUMPLE | Database driver, regeneración en login |
| Hashing | CUMPLE | bcrypt (12 rounds) |
| Roles | CUMPLE | Spatie Permission + canAccessPanel |
| Pedidos ajenos | CUMPLE | `abort_unless` en controladores |
| Uploads | FUNCIONA CON DEFICIENCIAS | FileUpload de Filament valida imagen, pero sin validación de tamaño/tipo en código custom |
| Stock | CUMPLE | lockForUpdate en checkout |
| Doble checkout | CUMPLE | Token de idempotencia |
| Secrets | CUMPLE | .env en .gitignore, APP_KEY no hardcodeada |
| PayPal secrets | NO APLICA | No hay integración PayPal |
| HTTPS | CUMPLE | .htaccess con X-Forwarded-Proto |
| APP_DEBUG | CUMPLE | .env.alwaysdata.example tiene `APP_DEBUG=false` |
| Proxy | CUMPLE | X-Forwarded-Proto manejado |
| Almacenar datos tarjeta | CUMPLE | No se almacenan CVV ni números de tarjeta |

### Clasificación de seguridad

| Nivel | Problema |
|---|---|
| CRÍTICO | Ninguno actual (porque PayPal no existe) |
| ALTO | Cuando se integre PayPal: falta validación de webhook, falta verificación de firma |
| MEDIO | Reports sin middleware de rol en ruta (solo en controlador) |
| MEDIO | Upload sin validación de tamaño máximo de archivo |
| BAJO | Credenciales demo en seeder (cambiar antes de producción real) |

---

## 17. Hosting — FASE 16

| Check | Estado |
|---|---|
| APP_ENV=production | CUMPLE |
| APP_DEBUG=false | CUMPLE |
| HTTPS | CUMPLE |
| X-Forwarded-Proto | CUMPLE |
| Document root /public | CUMPLE |
| SQLite persistente | CUMPLE |
| storage:link | Necesario verificar en servidor |
| Build Vite | CUMPLE (local) |
| composer --no-dev | NO (deploy script usa composer install normal) |
| Cachés | CUMPLE (config, view, route) |
| Script deploy | CUMPLE (`scripts/deploy-alwaysdata.sh`) |
| Documentación deploy | CUMPLE (`DEPLOY_ALWAYSDATA_PASO_A_PASO.md`) |

---

## 18. UX/UI — FASE 17

| Pantalla | Estado |
|---|---|
| Navbar | LISTA PARA DEMO — responsive, links correctos |
| Catálogo | LISTA PARA DEMO — cards con hover, búsqueda, filtros |
| Detalle producto | LISTA PARA DEMO — imagen, descripción, recientes |
| Carrito | LISTA PARA DEMO — cantidades, montos, eliminar |
| Checkout | FUNCIONA CON DEFICIENCIAS — formulario funcional, PayPal es cosmético |
| Pago PayPal | DEFICIENTE — Solo radio button, sin funcionalidad real |
| Confirmación | LISTA PARA DEMO — tracking, resumen, datos |
| Historial pedidos | LISTA PARA DEMO — lista y detalle |
| Admin (Filament) | LISTA PARA DEMO — CRUD funcional |
| Errores 403/404/500 | LISTA PARA DEMO — páginas personalizadas |
| Responsive | LISTA PARA DEMO — Bootstrap grid, navbar toggle |
| Móvil/Tablet | LISTA PARA DEMO — breakpoints correctos |

---

## 19. Documentación — FASE 18

| Documento | Estado | Contenido |
|---|---|---|
| README.md | CUMPLE | Instalación, stack, flujo, estructura |
| docs/TECNICA.md | CUMPLE | Arquitectura, modelos, rutas, seguridad |
| docs/MANUAL.md | CUMPLE | Manual de usuario cliente y admin |
| docs/DEFENSA.md | CUMPLE | Guion de defensa, preguntas frecuentes |
| docs/DEPLOYMENT.md | CUMPLE | Guía genérica de despliegue |
| docs/diagrama-uso-compra.md | CUMPLE | Diagrama del proceso de compra |
| docs/DEPLOY_ALWAYSDATA_PASO_A_PASO.md | CUMPLE (untracked) | Bitácora de deploy alwaysdata |
| requisitos.docx | NO VERIFICADO | No se puede leer — necesita conversión |

---

## 20. Matriz Contra Requisitos — FASE 19

> **NOTA:** No se pudo leer `requisitos.docx`. Esta matriz se basa en los requisitos inferidos de la documentación existente (README, TECNICA, DEFENSA) y los estándares típicos de un proyecto universitario de tienda virtual.

| Nº | Requisito | Estado | Evidencia | Archivos | Pruebas | Qué falta | Prioridad |
|---|---|---|---|---|---|---|---|
| 1 | Catálogo de productos | CUMPLE | ProductController, vistas, seeder | ProductController, products/* | ProductCatalogTest | Nada | — |
| 2 | Búsqueda por nombre | CUMPLE | LIKE en controlador | ProductController:19-23 | ProductCatalogTest | Nada | — |
| 3 | Filtro por categoría | CUMPLE | Filtro en controlador | ProductController:27-33 | ProductCatalogTest | Nada | — |
| 4 | Filtro por precio | CUMPLE | Min/max en controlador | ProductController:36-58 | ProductCatalogTest | Nada | — |
| 5 | Detalle de producto | CUMPLE | ProductController::show() | products/show.blade.php | ProductCatalogTest | Nada | — |
| 6 | Registro de usuarios | CUMPLE | AuthController::register() | AuthTest | AuthTest | Nada | — |
| 7 | Login/Logout | CUMPLE | AuthController | AuthTest | AuthTest | Nada | — |
| 8 | Carrito de compras | CUMPLE | CartController | CartController, cart/* | CartTest | Nada | — |
| 9 | Checkout con transacción | CUMPLE | DB::transaction en CheckoutController | CheckoutController | CheckoutTest | Nada | — |
| 10 | Idempotencia checkout | CUMPLE | Token de idempotencia | CheckoutController:85-94 | CheckoutIdempotencyTest | Nada | — |
| 11 | Número de seguimiento | CUMPLE | Generador único | CheckoutController:215-231 | CheckoutTest | Nada | — |
| 12 | Descuento de stock | CUMPLE | decrement() en transacción | CheckoutController:160-163 | CheckoutTest | Nada | — |
| 13 | Historial de pedidos | CUMPLE | AccountController::orders() | AccountTest | AccountTest | Nada | — |
| 14 | Protección pedidos ajenos | CUMPLE | abort_unless + test | AccountController:69-72 | AccountTest | Nada | — |
| 15 | Panel administrativo | CUMPLE | Filament en /admin | Filament/* | Ninguno | Tests Filament | MEDIA |
| 16 | Roles y permisos | CUMPLE | Spatie + Shield | RoleSeeder, UserSeeder | AuthTest (parcial) | Tests de permisos | MEDIA |
| 17 | Reportes PDF | FUNCIONA CON DEFICIENCIAS | ReportController + DomPDF | ReportController, reports/* | ReportTest (parcial) | Tests de ventas/productos | ALTA |
| 18 | Pago con PayPal Sandbox | NO CUMPLE | Selector visual sin funcionalidad | CheckoutController:171-178 | PaymentTest (superficial) | SDK, integración, tests | ALTA |
| 19 | Productos recientes (cookies) | CUMPLE | Cookie 30 días, máx 5 | ProductController:80-147 | RecentProductsTest | Nada | — |
| 20 | Perfil de usuario | CUMPLE | AccountController | account/profile.blade.php | AccountTest | Nada | — |
| 21 | Responsive/mobile | CUMPLE | Bootstrap 5 grid | layouts/app.blade.php | Ninguno | Tests visuales | BAJA |
| 22 | HTTPS | CUMPLE | .htaccess X-Forwarded-Proto | public/.htaccess | Ninguno | Test HTTPS | MEDIA |
| 23 | Despliegue en hosting | CUMPLE | alwaysdata deploy script | scripts/deploy-alwaysdata.sh | Ninguno | Verificación | BAJA |
| 24 | Pruebas automatizadas | FUNCIONA CON DEFICIENCIAS | 41 tests, 129 assertions | tests/Feature/* | 41 existentes | 15+ tests faltantes | ALTA |
| 25 | Documentación técnica | CUMPLE | docs/TECNICA.md | docs/* | Ninguno | Nada | — |
| 26 | Documentación de usuario | CUMPLE | docs/MANUAL.md | docs/MANUAL.md | Ninguno | Nada | — |
| 27 | Base de datos SQLite | CUMPLE | .env y config | database/* | phpunit.xml | Nada | — |
| 28 | Seeders demo | CUMPLE | 5 seeders | database/seeders/* | Ninguno | Test de seeder | BAJA |

---

## 21. Qué está completamente terminado

1. Catálogo con búsqueda, filtros y detalle
2. Registro, login, logout con rate limiting
3. Carrito con sesión (agregar, actualizar, eliminar, validaciones)
4. Checkout con transacción, idempotencia, tracking, stock
5. Productos recientes con cookies
6. Filament admin (Categorías, Productos, Usuarios, Pedidos, Pagos, Roles)
7. Reportes PDF (pedidos, ventas con por mes/cliente, productos)
8. Errores personalizados (403, 404, 500)
9. Despliegue en alwaysdata con HTTPS
10. Documentación técnica y de usuario
11. 41 tests funcionando

## 22. Qué funciona con deficiencias

1. **PayPal:** Solo selector visual, sin integración real
2. **Payment status:** Siempre queda `pending`, nunca `paid`
3. **CartController::index():** No usa `CartCalculator` (código duplicado)
4. **Reportes:** Protección de rol solo en controlador, no en middleware de ruta
5. **Tests:** Cobertura incompleta (faltan tests de PayPal, reportes, permisos, etc.)
6. **Git:** Historial consolidado, no refleja contribuciones reales del equipo
7. **Uploads:** Sin validación de tamaño/tipo en código custom

## 23. Qué falta

1. **Integración PayPal Sandbox** (SDK, create order, capture, webhook, tests)
2. **Payment transition** a `paid` después de pago exitoso
3. **Order status update** automático tras pago
4. **Stock rollback** si pago falla
5. **15+ tests faltantes** (PayPal, reportes, permisos, Filament, HTTPS, etc.)
6. **Middleware de rol** en rutas de reportes
7. **Convertir requisitos.docx** a Markdown para auditoría completa
8. **Agregar historial Git** o documentar contribuciones de cada integrante
9. **Tests de instalación limpia** (`migrate:fresh --seed`)

---

## 24. Diez tareas más importantes para terminar

| # | Tarea | Prioridad |
|---|---|---|
| 1 | Integrar PayPal Sandbox (SDK + flujo completo + tests) | CRÍTICA |
| 2 | Implementar transición Payment pending → paid | CRÍTICA |
| 3 | Actualizar Order status tras pago exitoso | ALTA |
| 4 | Agregar tests de reportes (ventas, productos, filtros) | ALTA |
| 5 | Agregar middleware `role:super_admin` en rutas de reportes | ALTA |
| 6 | Test de PayPal (aunque sea mock) | ALTA |
| 7 | Unificar cálculos usando `CartController` con `CartCalculator` | MEDIA |
| 8 | Agregar tests de 403/404 y permisos admin | MEDIA |
| 9 | Convertir `requisitos.docx` y verificar contra rúbrica | MEDIA |
| 10 | Documentar contribuciones de cada integrante en Git | BAJA |
