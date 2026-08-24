# DONDE ESTÁ CADA REQUISITO — Guía de estudio para la defensa

> Formato por requisito: Archivo / Función / Buscar en VS Code (Ctrl+Shift+F) / Cómo funciona / Qué mostrar / Pregunta posible / Respuesta sencilla.
> ⚠️ Los elementos marcados **[SOLO REPO]** existen en `StreetWear-CR` (desplegado) pero NO en tu carpeta local: búscalos en el clon del repo o en el servidor.

---

## 1. AUTENTICACIÓN
- Archivo: `app/Http/Controllers/AuthController.php`; `app/Models/User.php`
- Función: `login()`, `logout()`, `canAccessPanel()`
- Buscar en VS Code: `Auth::attempt` · `canAccessPanel` · `throttle:5,1`
- Cómo funciona: Form login → POST /login (limitado 5/min) → attempt contra users → regenera sesión → dashboard. Panel admin solo super_admin.
- Qué mostrar: login fallando y funcionando; código de canAccessPanel.
- Pregunta posible: ¿Dónde se define quién entra al admin?
- Respuesta: En User::canAccessPanel() — true solo con rol super_admin.

## 2. REGISTRO
- Archivo: `AuthController.php`
- Función: `register()` (líneas ~18-46)
- Buscar: `assignRole('customer')` · `'confirmed', 'min:8'`
- Cómo funciona: valida → Hash::make → User::create → assignRole customer → Auth::login → redirect con flash.
- Qué mostrar: crear cuenta nueva y caer en mi-cuenta logueado.
- Pregunta posible: ¿La contraseña viaja en texto?
- Respuesta: Por HTTPS sí viaja para ser hasheada con bcrypt al instante; en BD jamás hay texto plano.

## 3. LOGIN/LOGOUT
- Archivo: `AuthController.php`
- Función: `login()` / `logout()` (invalidate + regenerateToken)
- Buscar: `session()->invalidate` · `regenerateToken`
- Qué mostrar: logout y volver a login con mensaje flash.
- Pregunta posible: ¿Por qué regenerar la sesión al entrar/salir?
- Respuesta: Para prevenir fijación de sesión: un atacante no puede reutilizar un ID de sesión conocido.

## 4. PERFIL
- Archivo: `AccountController.php`
- Función: `updateProfile()` con `Rule::unique('users')->ignore($user->id)`
- Buscar: `updateProfile` · `account.profile.update`
- Qué mostrar: cambiar nombre/email y ver persistencia tras recargar.
- Pregunta posible: ¿Y si pongo el email de otro usuario?
- Respuesta: La regla unique lo rechaza salvo que sea mi propio email actual (ignore id).

## 5. HISTORIAL PEDIDOS
- Archivo: `AccountController.php`
- Función: `orders()` + `showOrder()` con abort_unless 403
- Buscar: `abort_unless($order->user_id` · `account.orders`
- Cómo funciona: relación inversa user_id → lista latest() → detalle con items+payment.
- Qué mostrar: historial con estados (pendiente/procesando/enviado).
- Pregunta posible: ¿Un cliente ve pedidos de otros?
- Respuesta: No; showOrder compara user_id del pedido con el autenticado y lanza 403.

## 6. CATÁLOGO
- Archivo: `ProductController.php`
- Función: `index()`
- Buscar: `where('active', true)` · `products.index`
- Cómo funciona: query Eloquent con category precargada (eager `with('category')`) → grid cards.
- Qué mostrar: catálogo completo con imágenes y precios.
- Pregunta posible: ¿Qué es with('category')?
- Respuesta: Eager loading: trae las categorías en una consulta extra en vez de una por producto (evita N+1).

## 7. CATEGORÍAS
- Archivos: `app/Models/Category.php`; `database/migrations/2026_07_25_223112...`; `CategorySeeder`
- Buscar: `class Category` · `categories` CRUD Filament en `app/Filament/Resources/Categories`
- Qué mostrar: filtro por categoría en tienda + CRUD en /admin.
- Pregunta posible: ¿Relación entre categoría y producto?
- Respuesta: Uno a muchos: Category hasMany Product; Product belongsTo Category vía category_id.

## 8. PRODUCTOS
- Archivos: modelo, migración products, `ProductController@show`, vista detail
- Buscar: `asset('storage/' . $product->image)` · `stock`
- Qué mostrar: ficha completa del producto.
- Pregunta posible: ¿Dónde viven las imágenes?
- Respuesta: En storage/app/public/products y se exponen por el symlink public/storage.

## 9. FILTROS
- Archivo: `ProductController@index`
- Buscar: `'like', '%' . $request->search . '%'` · `min_price` · `max_price`
- Cómo funciona: condiciones where encadenadas según parámetros GET presentes; combinables.
- Qué mostrar: buscar "camiseta" + categoría Ropa + rango de precio a la vez.
- Pregunta posible: ¿LIKE es vulnerable a inyección?
- Respuesta: No aquí; el patrón va como binding, no se concatena SQL.

## 10. CARRITO
- Archivo: `CartController.php` (add/update/remove/index)
- Buscar: `session()->get('cart'` · `max:' . $product->stock`
- Cómo funciona: array en sesión indexado por product_id {name, price, qty, image}; add incrementa respetando stock.
- Qué mostrar: agregar, subir cantidad, eliminar.
- Pregunta posible: ¿El carrito sobrevive al cierre del navegador?
- Respuesta: Mientras la cookie de sesión exista sí; no es persistente como una cuenta.

## 11. IVA
- Archivo: `app/Services/CartCalculator.php`
- Función: `tax($subtotal)` → subtotal * 0.13
- Buscar: `* 0.13`
- Qué mostrar: desglose en carrito y checkout (13%).
- Pregunta posible: ¿Por qué 0.13?
- Respuesta: IVA costarricense 13%; centralizado en un único método para todo el sistema.

## 12. ENVÍO
- Archivo: `CartCalculator.php`
- Función: `shipping()` → 3000 si subtotal>0, si no 0
- Buscar: `3000`
- Pregunta posible: ¿Envío gratis?
- Respuesta: Hoy costo fijo ₡3.000 por pedido; gratis implícito si no hay productos (no aplica).

## 13. TOTAL
- Archivo: `CartCalculator.php`
- Función: `total()` = subtotal + tax + shipping
- Buscar: `cartCalculator->total`
- Cómo funciona: checkout lo usa dentro de la transacción y lo persiste en orders.total; payment.amount = total.
- Pregunta posible: ¿Pueden carrito y pedido tener totales distintos?
- Respuesta: El pedido recalcula desde precios de BD dentro de lockForUpdate; si algo cambió entre medias, manda error de inventario/disponibilidad.

## 14. ORDER
- Archivos: `app/Models/Order.php`; migración create_orders_table
- Buscar: `tracking_number` · `restrictOnDelete` · `casts`
- Relaciones: belongsTo User; hasMany OrderItems;hasOne Payment (payment)
- Qué mostrar: tabla orders en un DB browser o tinker.
- Pregunta posible: ¿Estados posibles?
- Respuesta: pending, processing, shipped, delivered, cancelled (enum mostrado así en reportes).

## 15. ORDERITEM
- Archivos: `app/Models/OrderItem.php`; migración order_items
- Buscar: `product_name` · `subtotal`
- Detalle clave: guarda COPIA del nombre y precio del producto al momento de la compra (histórico inmutable aunque cambie el catálogo).
- Pregunta posible: ¿Por qué duplicas name/price en order_items?
- Respuesta: Para que la factura histórica nunca cambie si luego edito o borro el producto.

## 16. PAYMENT
- Archivos: `app/Models/Payment.php`; migración payments (order_id UNIQUE → 1 a 1)
- Buscar: `transaction_id` · `paid_at` · `'method'`
- Estados: pending → paid | failed
- Pregunta posible: ¿Por qué transaction_id nullable y unique?
- Respuesta: Null mientras está pending (demo tarjeta); cuando PayPal captura guardo su capture ID, que debe ser único global.

## 17. PAYPAL **[SOLO REPO]**
- Archivos: `app/Services/PayPalService.php`; `config/paypal.php`; CheckoutController paypalReturn/paypalCancel; test PayPalCheckoutTest
- Buscar: `api-m.sandbox.paypal.com` · `getAccessToken` · `captureOrder` · `'COMPLETED'`
- Cómo funciona: OAuth2 client_credentials → crea orden USD (total/520 tipo cambio) → redirect approve_url → return captura → paid + capture_id + processing.
- Qué mostrar: código del servicio + flujo en sandbox con cuenta buyer falsa.
- Pregunta posible: ¿Qué pasa si PayPal está caído?
- Respuesta: RuntimeException capturada: payment pasa a failed y el usuario ve mensaje de error sin romper la app.
- Estado: falta poner credenciales sandbox en .env del servidor y probar E2E.

## 18. CHECKOUT
- Archivo: `CheckoutController.php`
- Función: `store()` — transacción + lockForUpdate + token idempotencia
- Buscar: `DB::transaction` · `lockForUpdate` · `hash_equals` · `checkout_token`
- Cómo funciona: valida → verifica token anti doble-clic → en transacción re-valida stock/activo, crea Order+Items+Payment, descuenta stock → card: success demo; paypal: redirect sandbox.
- Qué mostrar: este método completo es LA joya para explicar robustez.
- Pregunta posible: ¿Dos pestañas compran la última unidad a la vez?
- Respuesta: lockForUpdate bloquea la fila hasta el primer commit; el segundo recibe "No hay suficiente inventario".

## 19. TRACKING
- Archivo: `CheckoutController@generateTrackingNumber()`
- Buscar: `'SWCR-'` · `Str::random(6)`
- Formato: SWCR-20260824-A1B2C3, único en BD (while exists + columna UNIQUE).
- Pregunta posible: ¿Se puede rastrear afuera?
- Respuesta: Es un número interno de demostración con formato realista; no consulta courier externo.

## 20. REPORTES PDF
- Archivo: `ReportController.php`; vistas reports/*.blade.php; paquete barryvdh/laravel-dompdf
- Buscar: `Pdf::loadView` · `->download('reporte-ventas.pdf')`
- Cómo funciona: colecciones Eloquent → Blade específico para PDF → DomPDF renderiza HTML/CSS a PDF → download.
- Qué mostrar: descargar los 3 PDFs desde /reportes siendo admin.
- Pregunta posible: ¿DomPDF ejecuta JS?
- Respuesta: No; por eso las vistas de reportes son HTML/CSS puro pensado para impresión.

## 21. REPORTE POR MES
- Archivo: `ReportController@sales()` (~línea 82)
- Buscar: `format('Y-m')` · `ventasPorMes`
- Qué mostrar: PDF sección mensual con cantidad de pedidos y total vendido por mes.
- Pregunta posible: ¿Y si quiero por semana?
- Respuesta: Cambio el formato de agrupación a 'Y-W'; misma técnica de colecciones.

## 22. REPORTE POR CLIENTE
- Archivo: `ReportController@sales()` (~línea 90)
- Buscar: `ventasPorCliente` · `"Cliente eliminado"`
- Orden: sortByDesc total_vendido (top clientes primero); tolera usuario borrado.
- Pregunta posible: ¿Filtra por fechas también?
- Respuesta: Sí; aplicarFiltros acepta desde/hasta/estado/cliente/pedido y afecta a todos los reportes.

## 23. COOKIES
- Archivo: `ProductController@show()`
- Buscar: `recent_products` · `Cookie::queue(` · `60 * 24 * 30`
- Specs: nombre recent_products, JSON de ids, máx 5, 30 días, dedupe.
- Test: RecentProductsTest (3 tests).
- Pregunta posible: ¿Guardas datos sensibles en la cookie?
- Respuesta: Solo IDs numéricos de productos; nada personal. Laravel además firma las cookies.

## 24. PRODUCTOS RECIENTES (mostrar)
- Archivos: mismo show(); vista products/show.blade.php sección final
- Buscar: `recentProducts` · `whereIn('id', $viewedIds)`
- Cómo funciona: lee cookie → consulta activos por esos ids → ordena según historial → cards "Vistos recientemente".
- Qué mostrar: visitar 3 productos y verlos listados en orden inverso de visita.
- Pregunta posible: ¿Por qué sortBy con array_search?
- Respuesta: SQL devuelve por id; reordeno en PHP según el orden real en que fueron visitados (guardado en el array).

## 25. VALIDACIONES
- Archivos: todos los controllers (`$request->validate`)
- Buscar: `$request->validate([` · `in:card,paypal` · `min:10` (dirección)
- Qué mostrar: enviar formulario vacío → mensajes de error inline.
- Pregunta posible: ¿Dónde quedan los errores?
- Respuesta: Laravel redirige back() con $errors a la vista; Blade los imprime bajo cada campo.

## 26. SEGURIDAD
- Checklist verificada hoy: 0 raw SQL · 0 `{!!` · @csrf x8 · Hash bcrypt · throttle login · 403 propietarios · secure cookies · .env fuera de git · HTTPS activo.
- Buscar: `VerifyCsrfToken` · `Hash::make` · `abort(403)` · `SESSION_SECURE_COOKIE`
- Pregunta posible: ¿Muestra contraseñas o llaves en algún log/vista?
- Respuesta: Nunca; passwords solo hash, secretos solo en .env fuera del repo.

## 27. SQLITE
- Archivos: `.env(.example)` DB_CONNECTION=sqlite; `database/database.sqlite`; database/.gitignore
- Buscar: `DB_CONNECTION=sqlite` · `database.sqlite`
- Verificación en vivo: `php artisan about` / `migrate:status`.
- Pregunta posible: ¿Concurrencia con SQLite?
- Respuesta: SQLite serializa escrituras con locks; el volumen del proyecto lo soporta de sobra y las transacciones cortas minimizan contención.

## 28. LARAVEL
- Archivos: composer.json (laravel/framework ^12), estructura MVC estándar
- Buscar: `laravel/framework`
- Menciona: Artisan, Eloquent ORM, Blade, migraciones, middleware, sesiones, validación, Vite integrado.
- Pregunta posible: ¿Qué ganaste usando Laravel?
- Respuesta: Seguridad y velocidad: auth, CSRF, validación, ORM y plantillas ya resueltos y probados; yo programé la lógica del negocio.

## 29. RESPONSIVE
- Archivo: `resources/views/layouts/app.blade.php`
- Buscar: `navbar-expand-lg` · `navbar-toggler` · `container`
- Pendiente: pasada visual rápida en móvil (DevTools) cuando hosting esté verde.
- Pregunta posible: ¿Escribiste media queries?
- Respuesta: Uso el sistema de breakpoints de Bootstrap 5; el menú colapsa en hamburguesa bajo lg automáticamente.

## 30. GITHUB
- Datos: repo github.com/nestorGPC/StreetWear-CR · main · commits descriptivos · historia desde TiendaVirtual
- Mostrar: página de commits del repo + comparación de versiones.
- Pregunta posible: ¿Flujo de trabajo Git?
- Respuesta: Commits atómicos por funcionalidad sobre main; ramas de respaldo puntuales (existe backup/pre-integracion).

## 31. SSL
- Hecho: alwaysdata emite certificado Let's Encrypt automático del subdominio; hoy curl verifica cadena OK; sitio responde SOLO https (http redirige).
- [LOCAL] existe fix .htaccess X-Forwarded-Proto detrás de proxy.
- Pregunta posible: ¿Compraste el certificado?
- Respuesta: No; alwaysdata integra certificados gratuitos automáticos (Let's Encrypt) renovados solos.

## 32. HOSTING
- Dónde: alwaysdata; app en ~/www/streetwear; root streetwear/public; SSH ssh-nestor-alwaysdata-net.alwaysdata.net
- Ya listo: PHP 8.4, vendor --no-dev, .env producción, SQLite migrada+sembrada, HTTPS, root apuntado.
- Falta HOY: compilar/subir public/build (500 actual), storage:link, credenciales PayPal, permisos Shield, caches.
- Prueba final: checklist completa en ESTADO_ACTUAL_RUBRICA.md §HOSTING.
- Pregunta posible: ¿Cómo despliegas una actualización?
- Respuesta: git pull --ff-only + composer install --no-dev + migrate --force + caches; documentado en DEPLOYMENT.md.
