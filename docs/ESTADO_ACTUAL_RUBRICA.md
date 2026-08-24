# STREETWEAR CR — ESTADO ACTUAL CONTRA LA RÚBRICA

> Auditoría de estado real al **24/08/2026**.
> Versión principal auditada: repositorio `StreetWear-CR.git` (HEAD `9ce00c4`, desplegado en alwaysdata).
> Diferencias con la carpeta local (`C:\xampp\htdocs\StreetWear CR`, HEAD `e758a65`) se indican como **[LOCAL]** donde aplican.
>
> Estados: ✅ TERMINADO/CUMPLE · ⚠️ FUNCIONA CON DEFICIENCIAS · 🟡 EN PROCESO · ❌ FALTA · 🔵 SOLO FALTA DOCUMENTAR · 🟣 SOLO FALTA PROBAR · ⚪ ACCIÓN MANUAL

---

# Punto 1 - Entrega en tiempo establecido

**Estado:** ⚪ ACCIÓN MANUAL

**Qué pide:** Subir los archivos dentro del plazo de la universidad.

**Qué tenemos:** Todo el proyecto está terminado o casi; solo faltan los pendientes de este informe.

**Qué falta:** Tú debes subir a la plataforma antes de la fecha límite.

**Defensa:** No aplica en código. Acción: entregar ZIP (ver Punto 2) y confirmar recibo en la plataforma.

---

# Punto 2 - Carpeta comprimida "ProyectoFinal-NombreEstudiantes"

**Estado:** ⚪ ACCIÓN MANUAL (hoy no existe ningún ZIP)

**Qué pide:** Adjuntar en la plataforma un ZIP llamado con el formato oficial.

**Qué tenemos:** No hay ningún `.zip` creado todavía (verificado en la raíz del proyecto).

**Qué falta:** Crear tú el ZIP cuando todo esté cerrado. Nombre correcto (ajusta tu apellido):

```
ProyectoFinal-NestorPalacios.zip
```

Contenido sugerido: código fuente SIN `vendor/`, SIN `node_modules/`, CON `docs/`. Excluir `\.git`, `storage\logs`, `database\database.sqlite`.

---

# Punto 3 - Autenticación y gestión de usuarios

**Estado:** ✅ TERMINADO / CUMPLE

**Qué pide:** Usuarios, autenticación, sesiones, roles, autorización, rutas protegidas.

**Qué tenemos:** Sistema completo con Laravel Auth nativo + roles Spatie Permission (`super_admin`, `customer`). Sesiones en base de datos. Rutas protegidas con middleware `auth`/`guest`. Panel Filament solo para `super_admin` (`canAccessPanel`). Gestión de usuarios desde `/admin/users` (Filament UserResource).

**Qué falta:** Nada obligatorio. (Nota aparte: los permisos granulares de Shield para CRUD de categorías/productos están pendientes — ver PENDIENTES_REALES.md.)

**Dónde está:**
- Controlador: `app/Http/Controllers/AuthController.php`
- Modelo: `app/Models/User.php` (`canAccessPanel()` línea ~58)
- Rutas: `routes/web.php` (grupos `guest` y `auth`)
- Panel admin: `app/Providers/Filament/AdminPanelProvider.php`
- Roles: `app/Providers/AppServiceProvider.php` no interviene; roles en `database/seeders/RoleSeeder.php`

**BUSCAR EN VS CODE:**
- `class AuthController`
- `Auth::attempt`
- `session()->regenerate`
- `canAccessPanel`
- `Route::middleware('auth')`
- `$table->foreignId('user_id')` (en migración permission_tables)

**Cómo funciona:**
Vista login → POST `/login` (middleware `throttle:5,1`) → `AuthController@login` → `Auth::attempt()` contra tabla `users` (SQLite) → regenera sesión → redirect a `account.dashboard`. Logout invalida sesión y regenera token CSRF.

**Test:** `tests/Feature/AuthTest.php` (registro, login, logout).

**Pregunta probable:** ¿Cómo proteges que un cliente entre a /admin?
**Respuesta sencilla:** El modelo User implementa `canAccessPanel()`: devuelve true solo si el usuario tiene el rol `super_admin`; además cada recurso de Filament verifica con policies/permisos.

---

# Punto 4 - Registro de usuarios nuevos

**Estado:** ✅ TERMINADO / CUMPLE

**Qué pide:** Formulario → validación → controller → modelo → BD → rol customer → redirección.

**Qué tenemos:** Flujo EXACTO pedido: `showRegister` → `register()` valida `name/email/password:confirmed|min:8` → `Hash::make` → `User::create` → `assignRole('customer')` → `Auth::login` + `session()->regenerate()` → redirect con mensaje flash.

**Dónde está:**
- Controlador: `app/Http/Controllers/AuthController.php` → `register()` (líneas 18–46)
- Vista: `resources/views/auth/register.blade.php`
- Ruta: POST `/registro` → `register.store`
- Migración: `0001_01_01_000000_create_users_table.php`

**BUSCAR EN VS CODE:**
- `public function register`
- `assignRole('customer')`
- `'confirmed', 'min:8'`
- `unique:users,email`

**Recorrido:** `register.blade.php` → POST `/registro` → `AuthController@register` → `User` → SQLite `users` + `model_has_roles` → redirect `/mi-cuenta`.

**Test:** `AuthTest.php` → `test_registro_crea_usuario_con_rol_customer` (verificar nombre exacto abriendo el archivo).

**Pregunta probable:** ¿Por qué `firstOrCreate` del rol customer?
**Respuesta sencilla:** Para que si el rol ya existe no falle por duplicado; garantiza idempotencia del registro.

---

# Punto 5 - Inicio y cierre de sesión

**Estado:** ✅ TERMINADO / CUMPLE

**Qué pide:** Login, logout, validación, errores, rate limiting.

**Qué tenemos:** Login con validación, error genérico "correo o contraseña incorrectos", `throttle:5,1` (5 intentos/minuto anti fuerza bruta), checkbox remember, `redirect()->intended()`. Logout con `invalidate()` + `regenerateToken()`.

**Dónde está:** `AuthController@login` / `logout()`; vistas `auth/login.blade.php`; ruta POST `/login` con `->middleware('throttle:5,1')`.

**BUSCAR EN VS CODE:** `throttle:5,1` · `Auth::logout` · `onlyInput('email')` · `intended(`

**Test:** `AuthTest.php`.

**Pregunta probable:** ¿Qué hace throttle:5,1?
**Respuesta sencilla:** Limita a 5 intentos de login por minuto por IP+usuario; si te pasas, Laravel bloquea un minuto. Evita ataques de fuerza bruta.

---

# Punto 6 - Perfil modificable + historial de pedidos

**Estado:** ✅ TERMINADO / CUMPLE (ambas partes A y B)

**A. Modificar perfil:** PUT `/mi-cuenta/perfil` → `AccountController@updateProfile` valida name/email (email único ignorando el propio) → `User::update`. Vista `account/profile.blade.php`.
**B. Historial:** GET `/mi-cuenta/pedidos` → `orders()` lista pedidos del usuario (`$request->user()->orders()->latest()`); detalle GET `/mi-cuenta/pedidos/{order}` con protección de propiedad: `abort_unless($order->user_id === $request->user()->id, 403)`.

**Dónde está:** `app/Http/Controllers/AccountController.php` (4 métodos); vistas `account/dashboard|profile|orders|order-detail.blade.php`; relación `User::orders()`.

**BUSCAR EN VS CODE:** `updateProfile` · `Rule::unique('users'` · `abort_unless` · `account.orders.show` · `public function orders()`

**Recorrido:** navbar "Mi cuenta" → `account.orders` → `AccountController@orders` → relación `Order belongsTo User` → SQLite `orders WHERE user_id=?` → vista historial → clic → detalle con items + payment.

**Test:** `AccountTest.php` (perfil e historial).

**Pregunta probable:** ¿Qué evita el `abort_unless(...403)`?
**Respuesta sencilla:** Que un cliente escriba la URL del pedido de otro y lo vea. Si el pedido no es suyo, recibe 403 Prohibido.

---

# Punto 7 - Catálogo con categorización

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Modelos `Category` y `Product` con relación `Product belongsTo Category` / `Category hasMany Product`. Filtro público por categoría, sidebar de categorías en catálogo, CRUD completo en Filament, 4 categorías sembradas (Ropa, Tenis, Gorras, Accesorios).

**Dónde está:** `app/Models/Category.php` y `Product.php`; `ProductController@index`; migraciones `create_categories/products_table`; seeder `CategorySeeder`; Filament `app/Filament/Resources/Categories/`.

**BUSCAR EN VS CODE:** `class Category extends Model` · `category()` · `where('category_id'` · `CategorySeeder`

**Vista:** `products/index.blade.php` (cards agrupadas/filtrables por categoría).

**Test:** `ProductCatalogTest` → `catalogo permite filtrar por categoria`.

---

# Punto 8 - Lista y detalle de productos (descripción, precio, imágenes)

**Estado:** ✅ TERMINADO / CUMPLE (código). Imágenes en hosting pendientes de `storage:link` — ver bloque HOSTING.

**Qué tenemos:** Lista `/productos` con imagen, nombre, precio, categoría, badge stock/agotado; detalle `/productos/{id}` con descripción completa, precio formateado, imagen grande, stock, categoría y botón agregar al carrito. Imágenes seed `.jpg` incluidas en repo (`storage/app/public/products/seed/`). Solo productos `active=true` se muestran.

**Dónde está:** `ProductController@index/show`; vistas `products/index.blade.php`, `products/show.blade.php`; helper `asset('storage/'.$product->image)`.

**BUSCAR EN VS CODE:** `asset('storage/' . $product->image)` · `where('active', true)` · `products.show` · `number_format` (formato moneda)

**Pregunta probable:** ¿Por qué guardas `image` como texto de ruta y no la imagen en BD?
**Respuesta sencilla:** Guardar rutas es más liviano y estándar; el archivo vive en `storage/app/public` y se sirve por el symlink `public/storage`.

---

# Punto 9 - Búsqueda y filtrado (nombre, categoría, precio)

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** En `ProductController@index`: búsqueda `LIKE %...%` por nombre, filtro por categoría, precio mínimo, precio máximo — todos combinables entre sí. Validación numérica inline para precios.

**BUSCAR EN VS CODE:** `'like', '%' . $request->search . '%'` · `min_price` · `max_price` · `is_numeric($request->min_price)`

**Recorrido:** formulario filtros (GET `/productos?search=..&category=..&min_price=..`) → `index()` encadena `where()` sobre Eloquent Query Builder → SQLite → vista resultados.

**Test:** `ProductCatalogTest` (búsqueda por nombre, categoría, rango precio).

**Pregunta probable:** ¿Tu búsqueda puede sufrir SQL Injection?
**Respuesta sencilla:** No. Uso Query Builder de Eloquent: los valores van como parámetros vinculados (bindings), nunca concatenados al SQL.

---

# Punto 10 - Carrito (agregar, eliminar, actualizar)

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Carrito en sesión (`session('cart')`): add valida stock, update valida cantidad 1..stock con producto activo, remove elimina. Botones +/- en vista. Al agotarse/re-validar en checkout se protege.

**Dónde está:** `app/Http/Controllers/CartController.php` (add/update/remove/index); vista `cart/index.blade.php`; rutas POST/PUT/DELETE `/carrito/...`.

**BUSCAR EN VS CODE:** `session()->get('cart'` · `public function add(Product $product)` · `max:' . $product->stock` · `unset($cart[$product->id])`

**Nota menor:** `add()` no verifica el flag `active` (solo `update()` y checkout lo hacen); un producto inactivo no llegaría a comprarse porque el checkout re-valida.

**Test:** `CartTest.php`.

**Pregunta probable:** ¿Por qué el carrito va en sesión y no en BD?
**Respuesta sencilla:** Es temporal y anónimo; la sesión basta y evita escrituras constantes a BD. El pedido sí se persiste al confirmar compra.

---

# Punto 11 - Totales automáticos con IVA y envío

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Cálculos centralizados en el servicio `CartCalculator`: IVA **13%**, envío fijo **₡3.000** (0 si carrito vacío), total = subtotal+IVA+envío. Checkout usa el servicio; la vista carrito calcula lo mismo inline (mismos valores); Order guarda subtotal/tax/shipping/total; Payment guarda amount=total. Sin discrepancias.

**Dónde está:** `app/Services/CartCalculator.php` (34 líneas); uso en `CheckoutController@index/store`.

**BUSCAR EN VS CODE:** `class CartCalculator` · `* 0.13` · `3000` · `cartCalculator->total`

**Test:** `CheckoutTest` / `CartTest` validan totales.

**Pregunta probable:** ¿Y si cambia el IVA?
**Respuesta sencilla:** Solo edito una constante en `CartCalculator::tax()` y todo el sistema (carrito, checkout, pedidos) usa el mismo servicio.

**Nota menor [calidad]:** `CartController@index` duplica la aritmética inline en vez de llamar al servicio. Funciona igual, pero sería más limpio usar el servicio.

---

# Punto 12 - Tabla compra/factura (usuario, fecha, monto)

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Tabla `orders` = la factura/compra: `user_id` (FK restrict), `tracking_number` único, `status`, `subtotal`, `tax`, `shipping`, `total` (decimal 12,2), `shipping_address`, `created_at` (fecha de compra), relaciones `user`, `items`, `payment`. La vista de confirmación/detalle actúa como factura en pantalla; PDFs adicionales existen en reportes admin.

**Dónde está:** Migración `2026_07_29_034406_create_orders_table.php`; modelo `app/Models/Order.php`; vistas `checkout/success` y `account/order-detail`.

**BUSCAR EN VS CODE:** `create_orders_table` · `'tracking_number'` · `decimal('subtotal', 12, 2)` · `restrictOnDelete`

**Pregunta probable:** ¿Por qué `restrictOnDelete` en user_id?
**Respuesta sencilla:** Impide borrar un usuario que tiene pedidos, preservando el histórico de ventas (integridad referencial).

---

# Punto 13 - Opciones de pago: tarjeta y PayPal (+ pasarela segura)

**Estado:** 🟡 EN PROCESO (código PayPal TERMINADO; configuración sandbox y pruebas E2E pendientes)

**Desglose honesto:**

| Parte | Estado |
|---|---|
| Código `PayPalService` (OAuth token → createOrder → capture) | ✅ TERMINADO |
| Flujo PayPal completo (approve_url, return, cancel, errores) | ✅ TERMINADO |
| `transaction_id` real (capture ID) + `paid_at` + order→processing | ✅ TERMINADO |
| Idempotencia checkout (anti doble-pedido) | ✅ TERMINADO |
| Tarjeta | ⚠️ modo DEMO local: crea Payment `pending`, sin cobro real |
| Credenciales sandbox en servidor (.env) | ❌ VACÍAS → PayPal no operativo aún |
| Prueba end-to-end en Sandbox | 🟣 pendiente |
| Webhook | ❌ no existe (no requerido explícitamente por rúbrica) |

**Dónde está (REPO):**
- Servicio: `app/Services/PayPalService.php` (getAccessToken, createOrder, captureOrder)
- Config: `config/paypal.php` (base_url sandbox, client_id, secret, exchange_rate 520)
- Controller: `CheckoutController@store/paypalReturn/paypalCancel`
- Rutas: `/checkout/paypal/return/{order}` y `/checkout/paypal/cancel/{order}`
- Vista selector: `checkout/index.blade.php` radios `card` / `paypal`
- Test: `tests/Feature/PayPalCheckoutTest.php`

**[LOCAL]** Esta carpeta NO tiene `PayPalService` ni `config/paypal.php` — ahí tarjeta Y paypal son demo local. Para defender el punto usa el código del repo/servidor.

**BUSCAR EN VS CODE (repo):** `class PayPalService` · `api-m.sandbox.paypal.com` · `captureOrder` · `'COMPLETED'` · `transaction_id` · `hash_equals`

**Recorrido PayPal:** checkout (radio PayPal) → `store()` crea Order+Payment pending → `PayPalService@createOrder` (POST OAuth + POST /v2/checkout/orders en sandbox) → redirect `approve_url` de PayPal → cliente aprueba → PayPal regresa a `/checkout/paypal/return/{order}?token=..` → `captureOrder(token)` → si `COMPLETED`: Payment `paid` + transaction_id + paid_at, Order `processing` → vista success.

**Pregunta probable:** ¿El dinero pasa por tu servidor?
**Respuesta sencilla:** No. Mi backend solo crea la orden y captura contra la API de PayPal Sandbox con OAuth2; el cliente paga en PayPal, y yo verifico el resultado consultando la API, actualizando Payment con el capture ID real.

**Para terminar:** ver PENDIENTES_REALES.md (configurar credenciales + probar flujo).

---

# Punto 14 - Confirmación con detalles y número de seguimiento

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Tras comprar, `checkout.success` muestra: tracking `SWCR-YYYYMMDD-XXXXXX` (único, generado con verificación de colisión), items con nombre/cantidad/subtotal, subtotal/IVA/envío/total, dirección, estado del pedido y del pago. También visible en `mi-cuenta/pedidos/{order}`.

**Dónde está:** `CheckoutController@generateTrackingNumber()` + `success()`; vistas `checkout/success.blade.php`, `account/order-detail.blade.php`.

**BUSCAR EN VS CODE:** `SWCR-` · `generateTrackingNumber` · `Str::random(6)` · `checkout.success`

**Test:** `CheckoutTest` (creación pedido + tracking).

**Pregunta probable:** ¿Cómo evitas números de seguimiento duplicados?
**Respuesta sencilla:** Genero uno aleatorio y hago `while(Order::where('tracking_number',$n)->exists())` hasta obtener uno nuevo; además la columna es UNIQUE en BD.

---

# Punto 15 - Reportes de ventas por MES y por CLIENTE en PDF

**Estado:** ✅ TERMINADO / CUMPLE (versión REPO y también presente en LOCAL)

**Verificación individual exigida:**

| Sub-requisito | Estado | Evidencia |
|---|---|---|
| A. Reporte por mes | ✅ TERMINADO | `sales()`: `$ventasPorMes` groupBy `format('Y-m')` |
| B. Reporte por cliente | ✅ TERMINADO | `$ventasPorCliente` groupBy nombre usuario + totales |
| C. Generación PDF | ✅ TERMINADO | DomPDF: `Pdf::loadView('reports.sales')->download('reporte-ventas.pdf')` |

Extras: reportes de pedidos y de productos vendidos, filtros por rango fechas/estado/cliente/número de pedido, totales generales, protección `ensureIsAdmin()` (403 si no es super_admin), página `/reportes` con botones de descarga.

**Dónde está:** `app/Http/Controllers/ReportController.php` (método `sales()` líneas 61–110; `ensureIsAdmin()` final); vistas Blade `reports/sales.blade.php`, `reports/orders`, `reports/products`, `reports/index`; fachada `Barryvdh\DomPDF\Facade\Pdf`; rutas `/reportes/ventas`, `/reportes/pedidos`, `/reportes/productos`.

**BUSCAR EN VS CODE:** `ventasPorMes` · `ventasPorCliente` · `Pdf::loadView` · `barryvdh` (composer.json) · `ensureIsAdmin` · `groupBy(fn ($order) => $order->created_at->format('Y-m'))`

**Recorrido:** admin abre `/reportes` → elige reporte+filtros → GET `/reportes/ventas?desde=..&hasta=..` → `ReportController@sales` consulta Orders (Eloquent) agrupa en colecciones → renderiza Blade → DomPDF genera binario → descarga `reporte-ventas.pdf`.

**Test:** `ReportTest` (cliente bloqueado 403, invitado redirigido, admin descarga PDF).

**Pregunta probable:** ¿Cómo agrupas ventas por mes si SQLite guarda timestamps?
**Respuesta sencilla:** Traigo las órdenes con Eloquent (created_at es Carbon) y agrupo en PHP con `groupBy(format('Y-m'))` sobre colecciones; así no dependo de funciones SQL específicas del motor.

---

# Punto 16 - Backend: PHP + SQLite (con Laravel)

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Laravel 12 sobre PHP ^8.2 (local XAMPP; producción alwaysdata PHP 8.4). Base de datos SQLite (`database/database.sqlite`), configurada en `config/database.php` vía `.env` (`DB_CONNECTION=sqlite`). 9 migraciones aplicadas. Producción ya corriendo con esta combinación.

**Dónde está:** `.env.example` (DB_CONNECTION=sqlite); `config/database.php`; migraciones en `database/migrations/`.

**BUSCAR EN VS CODE:** `DB_CONNECTION=sqlite` · `'sqlite' => [` (database.php) · `Schema::create` · `php.ini` extension pdo_sqlite (README)

**Evidencia viva:** `php artisan migrate:status` → todas Ran; `php artisan about` muestra driver sqlite.

**Pregunta probable:** ¿Por qué SQLite y no MySQL?
**Respuesta sencilla:** El proyecto es académico y de un solo archivo: SQLite es cero-configuración, transaccional (ACID), suficiente para el volumen esperado, y Laravel la soporta de forma nativa con el mismo Eloquent.

---

# Punto 17 - Diseño Frontend adecuado (HTML/CSS/Bootstrap/JS)

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Bootstrap 5.3.8 + Popper vía npm/Vite; layout maestro `layouts/app.blade.php` con navbar dark, footer, mensajes flash; cards de productos, formularios consistentes, badges de estado, tablas de historial; páginas de error personalizadas (403/404/500); JS: Bootstrap bundle importado en `resources/js/app.js` (dropdowns, collapse, toasts).

**Dónde está:** `resources/views/layouts/app.blade.php`; `resources/js/app.js`; `vite.config.js`; vistas en `resources/views/**`.

**BUSCAR EN VS CODE:** `import 'bootstrap'` · `@vite` · `class="card` · `alert alert-success` · `badge`

**Pregunta probable:** ¿Compilas CSS propio o usas framework?
**Respuesta sencilla:** Uso Bootstrap 5 como base compilado con Vite; el build genera `public/build` con CSS/JS versionados que Blade incluye vía directiva @vite.

---

# Punto 18 - Validación de entradas

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** `$request->validate()` en TODOS los controladores: registro (required/email/unique/confirmed/min:8), login (required/email), perfil (unique ignore self), carrito (integer min:1 max:stock), checkout (address min:10 max:500, method in:card,paypal, token), filtros (is_numeric para precios). Filament valida con sus schemas automáticamente. Errores mostrados en Blade con `@error`.

**BUSCAR EN VS CODE:** `$request->validate([` (aparece en Auth/Account/Cart/Checkout) · `Rule::unique` · `in:card,paypal` · `@error`

**Test:** múltiples tests cubren rechazo de entradas inválidas (Auth/Cart/Checkout tests).

**Pregunta probable:** ¿Validar en el navegador no basta?
**Respuesta sencilla:** No: JS se puede saltar. Valido SIEMPRE en servidor con `validate()`; el HTML5 required es solo ayuda visual.

---

# Punto 19 - Cookies en productos vistos recientemente

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Cookie `recent_products` con JSON de IDs, máximo **5**, duración **30 días** (60*24*30 minutos), escritura con `Cookie::queue()` en `ProductController@show`, deduplicación (el actual se mueve al inicio).

**Dónde está:** `ProductController::show()` líneas 72–123.

**BUSCAR EN VS CODE:** `recent_products` · `Cookie::queue` · `array_slice(` · `60 * 24 * 30`

**Test:** `RecentProductsTest` (guarda id, acumula 2, máximo 5).

**Pregunta probable:** ¿Por qué queue y no setcookie?
**Respuesta sencilla:** `Cookie::queue()` encola la cookie para que se envíe con la respuesta Laravel correctamente firmada; setcookie crudo rompería el cifrado/firma de cookies del framework.

---

# Punto 20 - Mostrar productos recientes al usuario

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** En la página de detalle (`products/show.blade.php`) sección "Vistos recientemente": lee IDs de la cookie, consulta `Product::whereIn('id')` solo activos, ordenados según orden de visita (excluyendo el producto actual).

**Dónde está:** `ProductController::show()` (bloque `$recentProducts`); vista `products/show.blade.php` (~línea 141 `@if ($recentProducts->isNotEmpty())`).

**BUSCAR EN VS CODE:** `recentProducts` · `whereIn('id', $viewedIds)` · `Vistos recientemente` (texto en la vista)

**Test:** mismos tests del punto 19 validan contenido de cookie; la vista la consume.

**Nota:** 19 = guardar; 20 = mostrar. Ambos implementados por separado pero en el mismo método show().

---

# Punto 21 - Código fuente completo entregado

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Repo con **215 archivos versionados**: app/, routes/, resources/, database/ (migraciones+seeders+factories), config/, public/ (htaccess, index.php), tests/, composer.json+lock, package.json+lock, vite.config.js, phpunit.xml, README, docs/. Untracked local: SOLO `reportes/reporte-productos.pdf` (artefacto runtime — no debe versionarse). `.env` y `database.sqlite` correctamente IGNORADOS (`.gitignore` + `database/.gitignore *.sqlite*`).

**BUSCAR EN VS CODE:** revisa `.gitignore` contiene `/vendor`, `/node_modules`, `.env`, `/public/build`; ejecuta `git status` → limpio salvo reportes/.

**Acción menor sugerida:** añadir `reportes/` a `.gitignore` para dejar el árbol limpio.

---

# Punto 22 - Documentación detallada con instrucciones de uso

**Estado:** 🔵 SOLO FALTA DOCUMENTAR (actualizar)

**Qué tenemos YA:**
- `README.md`: descripción del proyecto, tecnologías, instalación desde cero, credenciales demo (L123-124)
- `docs/MANUAL.md`: manual de uso cliente/administrador
- `docs/TECNICA.md`: arquitectura y esquema de datos (incluye tabla payments card/paypal)
- `docs/DEFENSA.md`: guion de defensa por integrante
- `docs/DEPLOYMENT.md`: guía HTTPS/producción
- `docs/diagrama-uso-compra.md`: **diagrama caso de uso del proceso de compra** ✓

**Qué falta documentar:** actualizar con: integración PayPal real (repo), URL pública de hosting, resultados de pruebas unitarias actuales, capturas finales.

---

# Punto 23 - Documento con pruebas unitarias

**Estado:** 🔵 SOLO FALTA DOCUMENTAR (los TESTS ya existen y pasan)

**Resultados REALES de hoy:**

| Versión | Resultado |
|---|---|
| REPO StreetWear-CR (45 tests) | **PASS — 45 passed, 148 assertions** |
| LOCAL (41 tests) | PASS — 41 passed, 129 assertions |

Suites: Auth, Account, Cart, Checkout, CheckoutIdempotency, Order, Payment, PayPalCheckout (solo repo), ProductCatalog, RecentProducts, Report.

**Qué falta:** crear `docs/PRUEBAS_UNITARIAS.md` listando cada suite, qué valida, y pegando el output de `php artisan test` (ya ejecutado hoy; comando: `php artisan test > pruebas.txt`).

---

# Punto 24 - Participó en la exposición

**Estado:** ⚪ ACCIÓN MANUAL

Guía de estudio completa en `docs/DONDE_ESTA_CADA_REQUISITO.md` y guion previo en `docs/DEFENSA.md`. Sugerencia de recorrido en vivo: catálogo → filtros → cookie recientes → carrito → checkout PayPal sandbox → tracking → admin → reportes PDF → GitHub.

---

# Punto 25 - Cumplió todas las funcionalidades especificadas

**Estado:** 🟡 EN PROCESO (≈95% — depende de cerrar Puntos 13, 22, 23 y hosting)

Conclusión por áreas: catálogo/carrito/checkout/pedidos/tracking/cookies/reportes/seguridad → completos. Pendientes para el 100%: activar PayPal con credenciales sandbox (13), actualizar documentación (22), documento de pruebas (23), hosting operativo sin 500 (ver HOSTING abajo).

---

# Punto 26 - Diseño responsivo e intuitivo

**Estado:** 🟣 SOLO FALTA PROBAR (visualmente)

**Qué tenemos:** Bootstrap responsive de fábrica: `navbar-expand-lg` + `navbar-toggler` (menú hamburguesa móvil), `container`, grid/cards fluidos, imágenes responsivas. Código correcto verificado.

**Prueba manual sugerida (15 min):** abrir en Chrome DevTools modo móvil (iPhone/ iPad) estas páginas: `/productos`, `/productos/{id}`, `/carrito`, `/checkout`, `/login`, `/mi-cuenta/pedidos`. Verificar menú hamburguesa, cards apiladas, formularios usables, sin scroll horizontal.

**BUSCAR EN VS CODE:** `navbar-expand-lg` · `navbar-toggler` · `col-md-` · `container`

---

# Punto 27 - Seguridad y manejo de datos sensibles

**Estado:** ✅ TERMINADO / CUMPLE

**Auditoría verificada HOY (greps sobre el código):**

| Aspecto | Resultado |
|---|---|
| SQL Injection | ✅ 0 usos de raw SQL (`whereRaw/DB::raw/selectRaw` = 0); todo Eloquent/Query Builder con bindings |
| XSS | ✅ 0 usos de `{!! !!}` en vistas (todo escapado con `{{ }}`) |
| CSRF | ✅ `@csrf` en los 8 formularios; middleware VerifyCsrfToken activo |
| Passwords | ✅ `Hash::make()` (bcrypt rounds 12); nunca se muestran |
| Sesiones | ✅ driver database, `SESSION_SECURE_COOKIE=true` en producción, regenerate en login/logout |
| Pedidos ajenos | ✅ `authorizeOrder()` y `abort_unless(user_id)` → 403 |
| Admin | ✅ canAccessPanel solo super_admin; reportes con hasRole check |
| Rate limiting | ✅ throttle:5,1 en login |
| Secretos fuera de Git | ✅ .env ignorado; PayPal keys solo en .env local (NO versionado) |
| HTTPS | ✅ certificado válido activo en alwaysdata (verificado hoy) |

**Notas menores:** webhook PayPal no existe (la captura se hace server-side en return, aceptable); super_admin necesita permisos Shield asignados (gap funcional, no de seguridad).

**Pregunta probable:** ¿Cómo evitas SQL Injection exactamente?
**Respuesta sencilla:** Nunca concateno SQL. Eloquent convierte cada valor en un parámetro vinculado (prepared statements) que SQLite ejecuta aparte del texto de la consulta.

---

# Punto 28 - Calidad del código y buenas prácticas

**Estado:** ✅ TERMINADO / CUMPLE

**Fortalezas verificadas:** arquitectura MVC limpia; Services extraídos (`CartCalculator`, `PayPalService`); transacción DB con `lockForUpdate()` en checkout (evita condiciones de carrera de stock); token idempotencia con `hash_equals()` (timing-safe); route model binding; validación centralizada; nombres consistentes; comentarios útiles; factories/seeders idempotentes; 11 suites de tests.

**Mejoras menores opcionales (NO bloqueantes):** `CartController@index` duplica cálculo del servicio; espaciado irregular en `OrderSeeder`; mezcla español/inglés en algunos nombres.

---

# Puntos 29, 30, 31 - Preguntas de la docente (×3)

**Estado:** ⚪ ACCIÓN MANUAL

Preparación incluida en `docs/DONDE_ESTA_CADA_REQUISITO.md` (pregunta+respuesta por requisito). Temas de mayor probabilidad según TU código real: transacción+lockForUpdate del checkout, token de idempotencia, flujo OAuth de PayPal, cookies recent_products, agrupación mensual de reportes, bindings anti-SQLi, por qué SQLite, throttle de login, symlink storage.

---

# Punto 32 - Utilizan GitHub

**Estado:** ✅ TERMINADO / CUMPLE

**Qué tenemos:** Repositorio público `github.com/nestorGPC/StreetWear-CR`, rama `main`, remoto configurado, commits con mensajes descriptivos en español ("Implementa pago con PayPal Sandbox", "Agrega busqueda y filtros...", "Imagenes"), historia continua de desarrollo (proyecto iniciado como TiendaVirtual → renombrado StreetWear CR). Autor único: Nestor (14+ commits en la línea consolidada; el repo desplegado conserva el historial original completo).

**Qué mostrar a la profesora:** página del repo → gráfico de commits, historial con mensajes claros, carpetas organizadas, README presentable.

---

# HOSTING ALWAYSDATA (requisito especial — estado REAL verificado hoy)

## HOSTING

**Estado: 🟡 EN PROCESO**

### Ya funciona (verificado por SSH y HTTP hoy):
- URL pública activa: https://nestor-alwaysdata-net.alwaysdata.net
- Certificado HTTPS válido (curl SSL verify OK)
- Document root ya apunta a `streetwear/public` (Laravel responde: `/` → 302 /productos; `/admin` → 302 /admin/login; `/reportes` → 302 /login)
- PHP 8.4 + Composer 2.9 + vendor instalado (--no-dev, platform reqs OK)
- SQLite migrada: 9 migraciones Ran; seeders base: 2 usuarios, 2 roles, 4 categorías, 5 productos
- `.env` producción correcto: APP_DEBUG=false, APP_ENV=production, SESSION_SECURE_COOKIE=true, DB sqlite ruta absoluta, APP_KEY generada (600 perms)
- Filament enruta correctamente; protección de rutas operativa

### Falta (causa de los 500 actuales):
1. ❌ `public/build` NO existe en servidor → "Vite manifest not found" → **500 en /productos, /login, /registro, /carrito** (confirmado en storage/logs/laravel.log). Solución: compilar assets (Node v24 disponible en servidor) o subir build local.
2. ❌ Symlink `public/storage` no creado → imágenes de productos 404. Solución: `php artisan storage:link`.
3. ❌ Credenciales PayPal vacías en `.env` del servidor → flujo PayPal no operativo.
4. ⚠️ Permisos Shield sin asignar en BD → super_admin entra a /admin pero no puede editar categorías/productos.
5. 🔵 Caches de producción (config/view/route) pendientes tras resolver 1-2.

### Prueba final necesaria (checklist de cierre):
Abrir en navegador: / (redirige), /productos 200 con CSS+imágenes, /registro crear cuenta, login, agregar al carrito, checkout tarjeta (demo) y PayPal (sandbox real), ver tracking, /admin con CRUD categorías, /reportes descargar PDF de ventas por mes/cliente, logout. Todo en HTTPS sin errores 500.

---

## RESUMEN GENERAL

| Estado | Puntos |
|---|---|
| ✅ TERMINADO/CUMPLE | 21 |
| ⚠️ FUNCIONA CON DEFICIENCIAS | 0 |
| 🟡 EN PROCESO | 2 (13 pagos-config, 25 global) |
| ❌ FALTA | 0 |
| 🔵 SOLO FALTA DOCUMENTAR | 2 (22, 23) |
| 🟣 SOLO FALTA PROBAR | 1 (26) |
| ⚪ ACCIÓN MANUAL | 6 (1, 2, 24, 29, 30, 31) |

*No es una nota oficial; es una estimación técnica de estado.*
