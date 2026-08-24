# Punto 27 - Seguridad y manejo de datos sensibles

## 1. ¿Qué pide la profesora?
Prevenir SQL Injection y XSS, sesiones seguras, hashing de contraseñas, protección de datos sensibles y HTTPS.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste? (checklist completo)
- SQL INJECTION: 100% Eloquent/Query Builder parametrizado; CERO `DB::raw`/SQL concatenado en app/ (verificado por búsqueda). Los LIKE construyen bindings, no strings SQL.
- XSS: TODAS las vistas escapan con `{{ }}`; NO existe ningún `{!! !!}` en resources/views (verificado). Los JSON de cookie nunca se imprimen crudos.
- CSRF: formulario Blade usa @csrf y el grupo de rutas web aplica VerifyCsrfToken global.
- HASHING: contraseñas con `Hash::make()` (bcrypt); NUNCA se guardan ni logean planas; login vía Auth::attempt compara hash.
- AUTORIZACIÓN: panel Filament solo super_admin (`canAccessPanel`); pedidos ajenos → abort(403) en showOrder/success; reportes → ensureIsAdmin 403; rutas privadas tras middleware auth; login rate-limited (throttle:5,1).
- SESIONES: SESSION_DRIVER=database (lado servidor), cookies HttpOnly/SameSite=Lax por defecto Laravel; regeneración de sesión en login/registro (anti fijación); invalidación en logout.
- DATOS SENSIBLES EN GIT: `.env` IGNORADO (nunca versionado); se entrega `.env.example` sin secretos reales; NO hay credenciales de pago en el repo (no existen aún).
- HTTPS: forzado en producción por public/.htaccess usando X-Forwarded-Proto (proxy alwaysdata termina TLS) — verificado en vivo: http→301→https.
- APP_DEBUG: true en .env.example LOCAL; en el servidor debe estar false (verificar .env remoto antes de entregar).
- IDEMPOTENCIA anti doble-compra con comparación timing-safe `hash_equals`.

## 4. ¿Dónde se encuentra?
- Hash: `app/Http/Controllers/AuthController.php` (register)
- 403s: `AccountController@showOrder`, `CheckoutController@success`, `ReportController@ensureIsAdmin`
- Panel: `app/Models/User.php::canAccessPanel`
- HTTPS: `public/.htaccess`
- Sesiones/CSRF: `config/session.php`, framework web middleware
- Tests: AccountTest (pedidos ajenos), ReportTest (403s), AuthTest (throttle)

## 5. ¿Qué buscar en VS Code?
Buscar:
- `Hash::make(`
- `{!!` (debe dar CERO resultados en views)
- `DB::raw|selectRaw|whereRaw` (cero en app/)
- `abort_unless(` / `abort(403)`
- `%{HTTP:X-Forwarded-Proto}` (public/.htaccess)

## 6. Fragmento importante
```php
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

## 7. Explicación sencillo
Laravel me protege gratis en varias capas: Eloquent siempre envía los valores como parámetros aparte del SQL (imposible inyectar), las llaves {{ }} de Blade convierten cualquier HTML malicioso en texto inofensivo, y cada POST exige el token CSRF de la sesión. Encima agregué las mías: bcrypt para contraseñas, 403 en cada recurso privado comparando dueños, límite de intentos de login, sesión regenerada al entrar y borrada al salir, y redirección obligatoria a HTTPS en producción. El archivo con secretos (.env) jamás subió a GitHub.

## 8. Recorrido del sistema
Request → HTTPS (htaccess) → CSRF verify → auth middleware → controller valida entrada → Eloquent parametrizado → SQLite → Blade escapado → response.

## 9. ¿Cómo lo pruebo?
1. Abrir pedido ajeno cambiando ID → 403.
2. Cliente en /reportes → 403; invitado → login.
3. Intentar 6 logins seguidos mal → bloqueo temporal.
4. Ver código fuente renderizado: sin HTML inyectable de datos de usuario.
5. http://... → salta a https://...
6. Buscar `{!!` y `DB::raw` en VS Code → cero coincidencias riesgosas.

## 10. ¿Qué evidencia puedo enseñarle?
Los 403 en vivo, candado SSL del navegador, .gitignore excluyendo .env, búsquedas en VS Code con resultado vacío, tests de autorización verdes.

## 11. Test relacionado
`AccountTest::test_un_cliente_no_puede_ver_el_pedido_de_otro_cliente`, `ReportTest` (3 pruebas de acceso), `AuthTest::test_se_limitan_los_intentos_de_inicio_de_sesion`.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Cómo evitas SQL Injection exactamente?
2. ¿Dónde guardas las contraseñas y cómo?
3. ¿Un cliente puede descargar reportes si adivina la URL?
4. ¿Tu .env está en GitHub?

## 13. Respuesta corta para defenderlo
1. "Nunca concateno SQL: Eloquent usa consultas preparadas con placeholders; los valores viajan separados."
2. "En users.password como hash bcrypt generado con Hash::make; jamás en texto plano ni logeada."
3. "No: ensureIsAdmin responde 403 sin rol super_admin; hay test que lo prueba."
4. "No: .gitignore lo excluye; solo subo .env.example sin valores reales."

## 14. Problemas encontrados
- Recordatorio operativo: confirmar APP_DEBUG=false en el .env del servidor antes de la defensa.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
