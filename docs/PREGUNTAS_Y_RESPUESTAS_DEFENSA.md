# BANCO MAESTRO — PREGUNTAS Y RESPUESTAS PARA LA DEFENSA
Todas basadas EXCLUSIVAMENTE en tu código real. Respuestas cortas, defendibles, sin humo.

## A. LARAVEL GENERAL
1. ¿Qué es una ruta en Laravel y dónde están las tuyas? → La URL→acción; en routes/web.php (135 líneas: productos, carrito, guest, auth+checkout, reportes).
2. ¿Qué es un middleware y cuáles usas? → Filtro entre request y controller: guest (login/registro), auth (cuenta/checkout/reportes), throttle:5,1 (anti fuerza bruta en POST /login), VerifyCsrfToken global.
3. ¿Qué es Eloquent? → El ORM: cada tabla = clase Model (Product, Order...); consultas PHP parametrizadas, relaciones hasMany/belongsTo.
4. ¿Qué es una migración? → Versionado del esquema en PHP; tengo 9 (users base, permisos Spatie, categories, products, orders, order_items, payments).
5. ¿Qué es Blade? → Motor de vistas: {{ }} escapa (anti-XSS), @if/@foreach, layouts heredables.
6. ¿Qué hace Composer vs npm? → Composer gestiona paquetes PHP (laravel, dompdf, filament); npm los assets (bootstrap) compilados con Vite.
7. ¿Cómo fluye un request? → Apache→public/index.php→router→middleware→controller→model(Eloquent)→SQLite→Blade→response.
8. ¿Qué es route model binding? → {product} de la URL se convierte en el modelo o 404 automático; lo uso en carrito/checkout/detalle.

## B. AUTENTICACIÓN Y USUARIOS
9. ¿Cómo sabe Laravel quién está logueado? → Cookie de sesión → tabla sessions (SESSION_DRIVER=database) → usuario asociado.
10. ¿Dónde defines roles? → Spatie Permission: roles super_admin/customer; UserSeeder crea ambos; assignRole('customer') al registrarse.
11. ¿Quién es el super_admin? → ÚNICAMENTE id=1 Administrador StreetWear CR — admin@streetwearcr.test (Admin12345). Verificado en BD producción.
12. ¿Cómo proteges /admin? → Filament llama User::canAccessPanel(): false sin rol super_admin ni antes de autenticar.
13. ¿Rate limiting? → throttle:5,1 en POST /login: 5 intentos/minuto, luego HTTP 429. Test dedicado.
14. ¿Por qué regenerate() tras login? → Renueva el ID de sesión: previene fijación de sesión.

## C. CATÁLOGO Y PRODUCTOS
15. ¿Relación categoría-producto? → Uno a muchos: categories.id ← products.category_id (foreignId constrained).
16. ¿Qué es eager loading y dónde? → with('category') trae relaciones en pocas queries; evita N+1 (una query extra por producto).
17. ¿Cómo filtras por precio sin romper nada? → Guardas filled()+is_numeric()+>=0 antes del where; texto basura se ignora.
18. ¿Combinar búsqueda+categoría+rango? → Todos agregan WHERE al MISMO query builder → intersección.
19. ¿Producto inactivo? → active=false: desaparece de catálogo/recientes y checkout lo rechaza.

## D. CARRITO Y TOTALES
20. ¿Dónde vive el carrito? → session('cart'): arreglo por product_id con name/price/quantity/image. BD solo al comprar.
21. ¿Límites al agregar? → stock<=0 rechazado; acumular no pasa stock disponible. (Brecha conocida: active falta en add(); update/checkout sí validan.)
22. ¿Cómo actualizas cantidad? → validate quantity integer min:1 max:{stock dinámico}; inactivo rechazado.
23. ¿De dónde salen IVA y envío? → CartCalculator: tax=subtotal*13%, shipping=₡3000 fijo con productos, total=suma.
24. ¿Consistencia carrito vs cobro? → El cobro SE RECALCULA server-side dentro de la transacción desde precios BD; jamás confío en montos del cliente.
25. Si cambia el IVA mañana? → Una línea en CartCalculator (por eso existe el Service).

## E. CHECKOUT Y ÓRDENES
26. Recorrido completo de una compra → validar dirección/método/token → DB::transaction → lockForUpdate por producto → verificar active+stock → recalcular totales → Order(user_id, tracking único, status, montos, dirección) → OrderItems congelan name/price/subtotal → decrement stock → Payment(method,status=pending,amount=total) → forget cart → redirect confirmación.
27. ¿Qué es idempotencia aquí? → Token Str::random(32) en sesión; hash_equals + session()->pull (un solo uso): doble clic NO crea dos pedidos. 2 tests.
28. ¿Evitas sobreventa? → lockForUpdate bloquea la fila durante la transacción; concurrencia serializada; test de inventario insuficiente.
29. Formato tracking? → SWCR-Ymd-XXXXXX (Str::upper random 6), do-while verificando existencia + columna unique.
30. ¿Qué columnas tiene orders? → user_id, tracking_number(unique), status, subtotal, tax, shipping, total, shipping_address, timestamps(created_at=fecha compra exigida).
31. ¿Por qué order_items guarda name/price copiados? → Histórico inmutable aunque editen el producto después.
32. ¿Factura PDF individual para cliente? → No; requisito dice tabla O factura → cumplimos con orders. PDFs existen para ADMIN (reportes).
33. Confirmación muestra qué? → items, desglose subtotal/tax/shipping/total, dirección, estado pedido, estado pago (pending), tracking. 403 si no es tuyo.

## F. PAGOS (la pregunta peligrosa)
34. ¿PayPal procesa pagos HOY? → NO. Selector guarda method='paypal'; Payment queda pending local. Integración real = roadmap documentado (SDK Orders API: token→createOrder→approve→capture→paid).
35. ¿Tarjeta? → Igual: registro demo, sin Stripe/PCI.
36. ¿Entonces qué SÍ funciona de pagos? → Modelo de datos completo (method/status/transaction_id/amount/paid_at), validación in:card,paypal, amount correcto ligado al pedido, tests del ciclo pending→actualizable.
37. ¿Por qué no simulaste 'paid'? → Honestidad: simular cobro falso es peor; pending refleja la verdad del flujo actual.
38. ¿Cuánto tardaría integrar PayPal Sandbox? → Servicio OAuth+createOrder+capture (~1 día) sobre la estructura ya testeada; rutas return/cancel y webhook.

## G. COOKIES RECIENTES
39. Nombre/duración/límite? → recent_products, JSON IDs, 30 días, máx 5.
40. Dónde se crea? → ProductController@show con Cookie::queue (adjunta a la respuesta).
41. Cómo muestras y ordenas? → whereIn ids activos existentes + sortBy(array_search) porque whereIn no preserva orden; excluyo el producto actual.
42. Por qué cookie y no BD/sesión? → Comportamiento personal no sensible que debe sobrevivir login/logout; la rúbrica lo exige así. 3 tests.

## H. REPORTES
43. Qué contienen? → sales: ventasPorMes (groupBy Y-m: conteo+suma) + ventasPorCliente (por usuario, desc) + totales; además pedidos y productos. TODO PDF DomPDF.
44. Librería? → barryvdh/laravel-dompdf (composer.json): vista Blade→PDF download.
45. Seguridad? → ensureIsAdmin() abort_unless(hasRole('super_admin'),403) en TODOS los métodos; 4 tests de acceso.
46. Filtros? → desde/hasta/estado/cliente aplicados con whereDate/where condicionales.

## I. SEGURIDAD
47. SQL Injection? → 100% Eloquent/Builder parametrizado; cero DB::raw/selectRaw/whereRaw en app/. Demo: buscar ' OR 1=1-- devuelve vacío sin romper.
48. XSS? → Todas las salidas {{ }} escapadas; cero {!! !!} en views.
49. Contraseñas? → Hash::make (bcrypt+salt); nunca planas/logs; Auth::attempt compara hash.
50. CSRF? → @csrf en formularios + VerifyCsrfToken; token inválido → 419.
51. Sesiones seguras? → Driver database (servidor), HttpOnly+SameSite=Lax default, regeneradas al autenticar, invalidadas al salir.
52. Pedidos/reportes ajenos? → 403 por comparación de dueño / rol. Tests AccountTest+ReportTest.
53. Secretos en Git? → .env ignorado siempre; solo .env.example; sin credenciales de pago en repo. HTTPS forzado vía X-Forwarded-Proto en .htaccess (301 verificado).

## J. BASE DE DATOS
54. SQLite ventajas aquí? → Un archivo, cero servidor BD, transaccional, FK activas; ideal entrega/hosting pequeño.
55. Dónde está físicamente? → database/database.sqlite.
56. Seeders? → UserSeeder(admin+cliente), RoleSeeder, CategorySeeder(4), ProductSeeder(imágenes incluidas), OrderSeeder(demo pedidos).

## K. TESTING
57. Cuántos y resultado? → 41 passed / 129 assertions (ejecutado hoy); 45 definidos en repo. Documentados en docs/PRUEBAS_UNITARIAS.md.
58. RefreshDatabase? → Migraciones frescas por test contra SQLite testing: aislamiento total.
59. Qué cubren? → auth×5, carrito×7, catálogo×5, checkout×3, idempotencia×2, cuenta×5, órdenes×2, pagos×3, cookies×3, reportes×4.
60. Qué NO cubren? → UI visual/responsive y pasarela externa real.

## L. DESPLIEGUE Y GITHUB
61. Hosting? → alwaysdata: https://nestor-alwaysdata-net.alwaysdata.net (200 verificado), HTTPS gratis, deploy por SSH/rsync según docs/DEPLOYMENT.md.
62. Repo? → github.com/nestorGPC/StreetWeaaar, main sincronizada, branch backup/pre-integracion-2026-08-10, commits descriptivos, 215 archivos, .gitignore sano (vendor/node_modules/.env fuera).

## M. MEJORA CONTINUA (si pregunta "¿qué mejorarías?")
63. → 1) PayPal sandbox real; 2) fix active en add(); 3) usar CartCalculator en vista carrito; 4) paginación catálogo; 5) notificaciones email de pedido.
