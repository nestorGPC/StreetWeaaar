# GUÍA PARA LA DEFENSA — StreetWear CR (rúbrica punto por punto)
Demo en vivo: https://nestor-alwaysdata-net.alwaysdata.net · Admin: admin@streetwearcr.test / Admin12345 · Cliente: cliente@streetwearcr.test / Cliente12345

## PESTAÑAS PREPARADAS ANTES DE EMPEZAR
1. Tienda /productos  2. Detalle de producto (F12→Cookies abierto)  3. /carrito  4. /admin (Filament)  5. /reportes  6. GitHub repo  7. Terminal con `php artisan test` listo

---

Punto 3 AUTENTICACIÓN
Qué mostrar: login admin → dashboard Filament; cliente intenta /admin → denegado.
Archivo: app/Models/User.php + routes/web.php
Buscar: `canAccessPanel`
Cómo explicarlo: sesiones en BD + roles Spatie; panel pregunta el rol antes de autenticar.
Pregunta probable: ¿dónde viven las sesiones? Respuesta: tabla sessions, driver database.

Punto 4 REGISTRO
Mostrar: crear cuenta nueva → cae logueado en /mi-cuenta.
Archivo: AuthController@register
Buscar: `assignRole('customer')`
Explicar: valida→hashea bcrypt→crea→rol customer→regenera sesión.
Probable: ¿por qué Hash::make? R: bcrypt lento+salt vs md5 roto.

Punto 5 LOGIN/LOGOUT
Mostrar: credencial mala (email se conserva) → bien → logout → 6º intento seguido = bloqueo.
Archivo: AuthController login/logout
Buscar: `throttle:5,1`
Explicar: mensaje genérico anti-enumeración; invalidate+regenerateToken al salir.
Probable: ¿qué significa throttle:5,1? R: 5 intentos por minuto → 429.

Punto 6 PERFIL/HISTORIAL
Mostrar: editar nombre → historial → abrir pedido ajeno cambiando ID → 403.
Archivo: AccountController
Buscar: `Rule::unique('users'`
Explicar: unique ignora propio id; abort_unless dueño≠usuario → 403.
Probable: ¿cómo proteges pedidos ajenos? R: comparo user_id con sesión.

Puntos 7-9 CATÁLOGO/FILTROS
Mostrar: filtros combinados con URL visible (?search=&category=&max_price=).
Archivo: ProductController@index
Buscar: `$request->filled('search')`
Explicar: condiciones acumuladas sobre un query builder; siempre active=true.
Probable: ¿SQLi en búsqueda? R: bindings parametrizados.

Punto 10 CARRITO
Mostrar: agregar/actualizar/eliminar; cantidad >stock rechazada.
Archivo: CartController
Buscar: `'max:' . $product->stock`
Explicar: carrito en sesión; checkout revalida todo contra BD.
Probable: ¿y producto inactivo? R: update y compra lo bloquean; add() es la mejora puntual documentada (fix listo en QUE_FALTA).

Punto 11 TOTALES
Mostrar: carrito ₡10.000 → IVA 1.300 + envío 3.000 = 14.300 idéntico en confirmación y BD.
Archivo: app/Services/CartCalculator.php
Buscar: `$subtotal * 0.13`
Explicar: UN servicio de dinero; server-side recálculo transaccional.
Probable: ¿cambia IVA mañana? R: una línea.

Punto 12 ORDERS
Mostrar: tabla orders en DB Browser (user_id, fecha, montos).
Migración: create_orders_table
Buscar: `Order::create([`
Explicar: cabecera+ítems+pago; ítems congelan precio histórico.
Probable: ¿borras producto vendido? R: uso active=false; órdenes intactas.

Punto 13 PAGOS (RESPUESTA-HONESTIDAD memorizada)
Mostrar: selector card/paypal → payments.pending en BD.
Buscar: `'status' => 'pending'`
Explicar: estructura completa lista (method/status/transaction_id/amount/paid_at); sin pasarela conectada todavía — roadmap PayPal Orders API.
Probable: ¿cobra de verdad? R: "No aún: registro honesto pending; la orden sí es 100% real".

Punto 14 TRACKING
Mostrar: confirmación SWCR-20260824-XXXXXX + URL ajena → 403.
Buscar: `SWCR-`
Explicar: do-while anti colisión + unique.
Probable: ¿garantía unicidad? R: verificación BD + restricción unique.

Punto 15 REPORTES
Mostrar: /reportes como admin → descargar PDF ventas → abrir (mes+cliente). Cliente → 403.
Archivo: ReportController@sales
Buscar: `ventasPorMes`
Explicar: colecciones groupBy Y-m y por usuario → DomPDF descarga.
Probable: ¿librería? R: barryvdh/laravel-dompdf.

Puntos 19-20 COOKIES
Mostrar: F12→Cookies→recent_products JSON tras visitar productos; sección recientes excluye actual.
Archivo: ProductController@show
Buscar: `Cookie::queue(`
Explicar: máx 5, 30 días, solo activos al pintar.
Probable: ¿orden? R: sortBy array_search porque whereIn no ordena.

Punto 16 BACKEND
Mostrar: php artisan about + migrate:status (9) + DB abierta.
Buscar: `'sqlite' => [`
Explicar: Laravel12/PHP8.2/SQLite archivo único transaccional.

Punto 23 TESTS (cierre fuerte)
Mostrar: `php artisan test` EN VIVO → 41 passed / 129 assertions + docs/PRUEBAS_UNITARIAS.md.
Explicar: RefreshDatabase aislado; mapean rúbrica↔prueba.

Punto 27 SEGURIDAD (grep-show)
Mostrar: buscar `{!!` → 0; `DB::raw` → 0; http→https 301; .gitignore sin .env.
Explicar: bcrypt, CSRF, escape Blade, 403s por dueño/rol, sesiones BD.

Punto 32 GITHUB
Mostrar: repo público, commits descriptivos, branch backup, README renderizado.

## GUION CRONOMETRADO (8–10 min)
0:00 Intro stack → 1:00 demo compra completa cliente → 4:00 F12 cookies → 4:30 carrito stock → 5:00 checkout totales → confirmación tracking → 6:30 admin: panel+CRUD+reporte PDF → 8:00 tests en vivo → 9:00 GitHub+HTTPS → 9:30 cierre honesto pagos-demo + roadmap.
