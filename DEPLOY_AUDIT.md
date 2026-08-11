# DEPLOY AUDIT — StreetWear CR → alwaysdata Free

> Fecha: 2026-08-10
> Entorno local: Windows + XAMPP (PHP 8.2.12), Laravel 12.64.0, Composer 2.10.2,
> Node/Vite 7, SQLite.
> Resultado de la auditoría previa al despliegue en **alwaysdata Free**.

## Clasificación usada

| Etiqueta | Significado |
| --- | --- |
| LISTO | No requiere cambios, funciona para producción. |
| REQUIERE CAMBIO | Se corrigió localmente o debe corregirse en el servidor. |
| NO VERIFICADO | Depende del servidor (se documenta el comando de comprobación). |
| BLOQUEADOR | Impide el despliegue si no se resuelve. |

---

## Resumen ejecutivo

- Estado general: **LISTO CON ACCIONES EN SERVIDOR**.
- El proyecto compila, migra, siembra y pasa **41 pruebas** en local.
- **1 bloqueador local ya corregido**: imágenes demo de seeders no estaban
  versionadas en Git (se habilitó su seguimiento en
  `storage/app/public/.gitignore`).
- SQLite se conserva: `DB_CONNECTION=sqlite` en local y producción.
- Comandos de verificación en servidor: `php -v`, `php -m`, `composer --version`
  (resultados esperados documentados en este archivo y en `DEPLOY_ALWAYSDATA.md`).

---

## Puntos auditados

### 1. Versión mínima de PHP
- **Requisito**: `"php": "^8.2"` en `composer.json`.
- **Local**: PHP 8.2.12 ✔
- **alwaysdata**: ofrece PHP 8.2 a 8.5 (ver
  https://help.alwaysdata.com/en/web-hosting/languages/php/configuration/).
- **Clasificación**: LISTO (seleccionar PHP 8.2+ en el panel).

### 2. Extensiones PHP necesarias
- Necesarias para Laravel/Filament/DomPDF: `mbstring`, `xml`, `dom`, `curl`,
  `openssl`, `zip`, `fileinfo`, `intl`, `bcmath`, `ctype`, `tokenizer`, `gd`.
- **Local**: presentes ✔
- **alwaysdata**: la mayoría vienen precargadas. Verificar en SSH con
  `php -m`. Si falta alguna, añadir `extension = *.so` en
  `Environment > PHP` (php.ini del sitio/cuenta).
- **Clasificación**: NO VERIFICADO (depende del servidor; verificado con `php -m`).

### 3. SQLite
- `DB_CONNECTION=sqlite` en `.env` y `.env.example`. No se migra a MySQL.
- **Clasificación**: LISTO.

### 4. PDO SQLite
- **Local**: `pdo_sqlite` presente ✔
- **alwaysdata**: NO está listada explícitamente en el `php.ini` por defecto de
  alwaysdata. Se debe comprobar:
  ```bash
  php -m | grep -i sqlite
  ```
  - **Resultado esperado**: `PDO` (con driver), `pdo_sqlite`, `sqlite3`.
  - **Si falta**: añadir en `Environment > PHP` del panel:
    ```
    extension = pdo_sqlite.so
    extension = sqlite3.so
    ```
- **Clasificación**: NO VERIFICADO (punto crítico; primero en comprobar en SSH).

### 5. Composer
- **Local**: Composer 2.10.2 ✔
- **alwaysdata**: Composer 2 preinstalado (`composer` o `composer2`) — ver
  https://help.alwaysdata.com/en/web-hosting/languages/php/packages/.
- **Comprobación en servidor**: `composer --version` (esperado: `Composer version 2.x.x`).
- **Clasificación**: LISTO.

### 6. Vite
- `vite.config.js` correcto; `npm run build` genera los assets.
- `package.json` con `build` y `dev`.
- **Clasificación**: LISTO (estrategia de despliegue en punto 30).

### 7. `public/build/manifest.json`
- Generado correctamente por `npm run build` (Vite 7.3.6).
- `public/build` está **ignorado por Git** (`/public/build` en `.gitignore`).
- **Clasificación**: LISTO (ver estrategia de assets, punto 30).

### 8. `storage:link`
- Ejecutado en local: `public/storage` es junction → `storage/app/public` ✔
- En el servidor debe ejecutarse `php artisan storage:link`.
- **Clasificación**: REQUIERE CAMBIO (acción en servidor).

### 9. Permisos requeridos
- No usar `777`. En alwaysdata el usuario de la cuenta es dueño de todo; PHP
  corre como ese usuario. Permisos razonables:
  - `storage/`, `storage/framework/`, `storage/logs/`, `storage/app/` → `755` dirs / `644` archivos (grupo con escritura: `775`/`664`).
  - `bootstrap/cache/` → `755` (escritura del dueño).
  - `database/` y `database/database.sqlite` → `755`/`644` (el archivo SQLite debe ser escribible por el dueño: `644` es suficiente si el dueño es el usuario web).
- **Clasificación**: REQUIERE CAMBIO (acción en servidor, documentada).

### 10. Variables de entorno
- `.env.example` completo y coherente con `config/`.
- Se creó `.env.alwaysdata.example` como plantilla de producción sin secretos.
- **Clasificación**: LISTO (plantilla creada).

### 11. `APP_URL`
- Local: `http://localhost`. Producción: `https://USUARIO.alwaysdata.net`.
- **Clasificación**: REQUIERE CAMBIO (en `.env` del servidor).

### 12. `APP_ENV`
- Local: `local`. Producción: `production`.
- **Clasificación**: REQUIERE CAMBIO (en `.env` del servidor).

### 13. `APP_DEBUG`
- Local: `true`. Producción: `false` (obligatorio).
- **Clasificación**: REQUIERE CAMBIO (en `.env` del servidor).

### 14. `SESSION_DRIVER`
- `database` en local y en plantilla de producción. La tabla `sessions` se crea
  en la migración `0001_01_01_000000_create_users_table`. ✔
- **Clasificación**: LISTO.

### 15. `CACHE_STORE`
- `database` en local y en plantilla de producción. La tabla `cache` se crea en
  `0001_01_01_000001_create_cache_table`. ✔
- **Clasificación**: LISTO.

### 16. `QUEUE_CONNECTION`
- `database`. La tabla `jobs` se crea en `0001_01_01_000002_create_jobs_table`. ✔
- No se despachan jobs de cola en la aplicación (checkout es síncrono).
- **Clasificación**: LISTO.

### 17. Imágenes
- **BLOQUEADOR LOCAL CORREGIDO**: los seeders referencian
  `products/seed/*.svg` dentro de `storage/app/public/`, que estaba ignorado por
  `storage/app/public/.gitignore`. Se modificó el `.gitignore` para versionar
  `products/seed/`. **Pendiente manual**: incluir esos SVGs en el próximo commit.
- Las subidas de Filament (`FileUpload`) van a `products/` en el disco `public`
  (no versionadas; son datos de ejecución).
- **Clasificación**: REQUIERE CAMBIO (corregido localmente; commit pendiente del usuario).

### 18. Filament
- `/admin` funciona; login con Filament.
- `User::canAccessPanel()` exige rol `super_admin` ✔
- Shield 4.3.1 configurado; roles `super_admin` y `customer`.
- Assets de Filament versionados en `public/css|js|fonts/filament` ✔
- **Clasificación**: LISTO.

### 19. Reportes PDF
- `barryvdh/laravel-dompdf` instalado en `composer.json` ✔
- Requiere `mbstring`, `dom`, `xml` (presentes en local y disponibles en
  alwaysdata).
- Acceso restringido a `super_admin` (vía `ensureIsAdmin()` y
  `ReportController`).
- **Clasificación**: LISTO.

### 20. Cookies
- `config/session.php`: `secure => env('SESSION_SECURE_COOKIE')`,
  `http_only => true`, `same_site => lax`.
- En producción: `SESSION_SECURE_COOKIE=true`.
- Cookies de productos recientes usan `queue()`/`Cookie::` (test `RecentProductsTest` ✔).
- **Clasificación**: REQUIERE CAMBIO (variable en `.env` del servidor).

### 21. Checkout
- Controlador con validación, transacciones DB, bloqueo de filas
  (`lockForUpdate`), token de idempotencia y decremento de stock. Tests ✔
- **Clasificación**: LISTO.

### 22. Pedidos
- Modelos, migraciones y vistas correctos. Propietario = usuario autenticado.
- **Clasificación**: LISTO.

### 23. Pagos
- Modo demostración (pago local, sin pasarela real). No se almacenan datos de
  tarjeta.
- **Clasificación**: LISTO (demo académica).

### 24. HTTPS
- alwaysdata: certificado Let's Encrypt + redirección HTTP→HTTPS configurables
  en el panel (Web > Sites > SSL).
- Preparación local: `APP_URL=https://...` + `SESSION_SECURE_COOKIE=true` en la
  plantilla de producción.
- **Clasificación**: REQUIERE CAMBIO (activar Let's Encrypt en el panel).

---

## Otros puntos verificados

### 25. Seguridad de Git
- `.env` ignorado ✔ · `database/database.sqlite` ignorado ✔ ·
  `storage/logs/*` ignorado ✔ · `node_modules` ✔ · `vendor` ✔ ·
  `public/build` ✔ · `public/storage` ✔.
- **Solo se trackea** `storage/logs/.gitignore` (contenedor vacío). No hay
  secretos trackeados en Git. ✔
- **Clasificación**: LISTO (comprobado con `git ls-files`).

### 26. Rutas
- `php artisan route:list` muestra las rutas esperadas (62 rutas).
- `php artisan route:cache` funciona sin errores en local ✔ → se puede cachear
  rutas en producción (aunque es opcional).
- **Clasificación**: LISTO.

### 27. Migraciones
- `php artisan migrate:status` → las 9 migraciones están aplicadas en local.
- En el servidor, base nueva: `php artisan migrate --force` (crea tablas
  `users`, `sessions`, `cache`, `jobs`, permisos, categorías, productos,
  pedidos, pagos).
- **Clasificación**: LISTO.

### 28. Seeders
- `DatabaseSeeder` ejecuta: `RoleSeeder`, `UserSeeder`, `CategorySeeder`,
  `ProductSeeder`, `OrderSeeder`.
- Crea: admin + cliente demo, 2 roles, 4 categorías, 5 productos (con imagen),
  3 pedidos con pagos. Datos idempotentes (`updateOrCreate`/guardas) ✔
- **Clasificación**: LISTO (Opción A de base de datos recomendada).

### 29. Pruebas
- `php artisan test` → **41 passed (129 assertions)**. ✔
- **Clasificación**: LISTO.

### 30. Estrategia de assets (build)
- `public/build` está en `.gitignore`. Para el servidor:
  - **ESTRATEGIA PRINCIPAL (recomendada)**: compilar en local
    (`npm run build`) y subir `public/build/` por SFTP al servidor tras el
    `git clone`. Reduce carga y riesgo durante la presentación.
  - **Alternativa**: `npm install && npm run build` en el servidor (requires
    Node; siempredata lo soporta, pero consume recursos del plan Free).
- **Clasificación**: LISTO (estrategia documentada en `DEPLOY_ALWAYSDATA.md`).

### 31. Prueba lógica de flujos (pendiente en servidor)
| Flujo | Ruta | Estado esperado |
| --- | --- | --- |
| Página pública | `/productos` | 200 |
| Detalle | `/productos/{id}` | 200 |
| Login | `/login` | 200 (POST → redirect) |
| Registro | `/registro` | 200 |
| Carrito | `/carrito` | 200 |
| Checkout | `/checkout` | 200 (requiere login) |
| Mi cuenta | `/mi-cuenta` | 200 (login) |
| Mis pedidos | `/mi-cuenta/pedidos` | 200 (login) |
| Admin | `/admin` | 200 (super_admin) |
| Reportes | `/reportes` | 200 (super_admin) |
- **Clasificación**: NO VERIFICADO (prueba manual tras despliegue; checklist en
  `DEPLOY_CHECKLIST.md`).

### 32. Bases de datos: Opción A vs Opción B
- **Opción A (recomendada)**: base nueva en el servidor +
  `migrate --force` + `db:seed --force`. Genera un sistema demostrable
  completo, limpio y con permisos correctos.
- **Opción B**: subir la `database.sqlite` local. Riesgo: copiar sesiones,
  caché o datos de prueba; requiere re-verificar permisos; no se recomienda.
- **Clasificación**: LISTO (Opción A seleccionada).

---

## Acciones pendientes en el servidor (resumen)

1. Seleccionar PHP 8.2+ y comprobar `php -m | grep -i sqlite`.
2. (Si falta) añadir `extension = pdo_sqlite.so` / `extension = sqlite3.so`.
3. Crear `.env` desde `.env.alwaysdata.example` + `key:generate`.
4. `touch database/database.sqlite` + `php artisan migrate --force` +
   `php artisan db:seed --force`.
5. `composer install --no-dev --optimize-autoloader`.
6. Subir `public/build/` (o compilar en servidor).
7. `php artisan storage:link`.
8. Permisos de `storage/`, `bootstrap/cache/` y `database/`.
9. Activar Let's Encrypt y redirección HTTP→HTTPS en el panel.
10. `config:cache` / `view:cache` (opcional `route:cache`, compatible).

## Referencias oficiales alwaysdata

- PHP: https://help.alwaysdata.com/en/web-hosting/languages/php/configuration/
- Extensiones PHP: https://help.alwaysdata.com/en/web-hosting/languages/php/extensions/
- Composer: https://help.alwaysdata.com/en/web-hosting/languages/php/packages/
- SSH: https://help.alwaysdata.com/en/web-hosting/remote-access/ssh/
- SSL/Let's Encrypt: https://help.alwaysdata.com/en/web-hosting/sites/ssl-tls/
- Redirección HTTP→HTTPS: https://help.alwaysdata.com/en/web-hosting/sites/ssl-tls/redirect-http-to-https/
- Plan Free: https://help.alwaysdata.com/en/docs/admin-billing/billing/public-cloud-prices/
