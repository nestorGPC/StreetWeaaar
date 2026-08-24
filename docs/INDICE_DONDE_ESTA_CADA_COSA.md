# ÍNDICE — DÓNDE ESTÁ CADA COSA (búsqueda <30 segundos durante defensa)
Regla rápida: Ctrl+Shift+F en VS Code con los textos "Buscar".

AUTENTICACIÓN
Archivo: app/Http/Controllers/AuthController.php
Función: login() / logout()
Ruta: POST /login (throttle:5,1), POST /logout
Vista: auth/login.blade.php
Buscar: `public function login`

REGISTRO
Archivo: AuthController.php · Función: register() · Ruta: /registro · Vista: auth/register.blade.php
Buscar: `assignRole('customer')`

ROLES/PANEL ADMIN
Archivo: app/Models/User.php (canAccessPanel) + app/Providers/Filament/AdminPanelProvider.php
Ruta: /admin · Buscar: `canAccessPanel`

PERFIL
Archivo: app/Http/Controllers/AccountController.php · updateProfile()
Ruta: PUT /mi-cuenta/perfil · Vista: account/profile.blade.php
Buscar: `updateProfile`

HISTORIAL PEDIDOS
Archivo: AccountController.php · orders()/showOrder()
Ruta: /mi-cuenta/pedidos · Vista: account/orders.blade.php, order-detail.blade.php
Buscar: `abort_unless($order->user_id`

CATÁLOGO/FILTROS
Archivo: app/Http/Controllers/ProductController.php · index()
Ruta: GET /productos · Vista: products/index.blade.php
Buscar: `$request->filled('min_price')`

DETALLE PRODUCTO
ProductController@show() · GET /productos/{product} · products/show.blade.php
Buscar: `public function show(Product $product)`

CARRITO
Archivo: app/Http/Controllers/CartController.php · add/update/remove/index
Rutas: /carrito/* · Vista: cart/index.blade.php
Buscar: `unset($cart[$product->id])`

TOTALES (IVA 13%, ENVÍO 3000)
Archivo: app/Services/CartCalculator.php
Buscar: `$subtotal * 0.13`

CHECKOUT (TRANSACCIÓN)
Archivo: app/Http/Controllers/CheckoutController.php · store()
Ruta: POST /checkout · Vista: checkout/index.blade.php
Buscar: `lockForUpdate`

IDEMPOTENCIA (anti doble-POST)
CheckoutController@store líneas ~81-94 · Buscar: `hash_equals`

ORDERS (tabla compra)
Migración: database/migrations/2026_07_29_034406_create_orders_table.php
Modelo: app/Models/Order.php · Buscar: `create_orders_table`

PAYMENTS
Migración: ...034409_create_payments_table.php · Modelo: app/Models/Payment.php
Creación: CheckoutController@store · Buscar: `'status' => 'pending'`

TRACKING
CheckoutController::generateTrackingNumber() · Buscar: `SWCR-`

CONFIRMACIÓN
CheckoutController@success() · GET /checkout/confirmacion/{order} · checkout/success.blade.php

REPORTES PDF
Archivo: app/Http/Controllers/ReportController.php · sales()/orders()/products()
Rutas: /reportes/* · Vistas: reports/*.blade.php
Buscar: `ventasPorMes` · Paquete: barryvdh/laravel-dompdf

COOKIES RECIENTES
ProductController@show() · Cookie `recent_products` · máx 5 · 30 días
Buscar: `Cookie::queue(`
Mostrado: products/show.blade.php · Buscar: `recentProducts`

VALIDACIONES
Todos los controllers · Buscar: `$request->validate([`

SEGURIDAD
HTTPS: public/.htaccess (X-Forwarded-Proto) · Hash: `Hash::make(` en AuthController
403s: `abort(403)` / `abort_unless(` en Account/Checkout/Report

BD/MIGRACIONES
config/database.php (sqlite) · database/migrations (9 archivos) · seeders (UserSeeder etc.)
Comandos: php artisan about / migrate:status

TESTS
tests/Feature/*.php (11 suites) · Documento: docs/PRUEBAS_UNITARIAS.md
Comando: php artisan test (41 passed / 129 assertions)

DOCUMENTACIÓN
README.md · docs/MANUAL.md · docs/diagrama-uso-compra.md · docs/TECNICA.md · docs/DEPLOYMENT.md

GITHUB
Repo: github.com/nestorGPC/StreetWeaaar · main sincronizada · rama backup/pre-integracion-2026-08-10

AUDITORÍA
docs/rubrica/01…32 · docs/AUDITORIA_RUBRICA_COMPLETA.md · docs/QUE_FALTA_ANTES_DE_ENTREGAR.md · docs/PREGUNTAS_Y_RESPUESTAS_DEFENSA.md
