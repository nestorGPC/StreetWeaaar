# DEPLOY ALWAYSDATA — StreetWear CR

Guía paso a paso para publicar **StreetWear CR** en **alwaysdata Free**
(Laravel 12 · PHP 8.2 · SQLite · Blade · Vite · Filament · DomPDF).

> Lugar de trabajo: **Windows + VS Code**.
> Comandos remotos: se ejecutan en el **SSH** de alwaysdata (terminal de VS Code
> o PowerShell).
>
> Placeholders:
> - `USUARIO_ALWAYSDATA` → el nombre real de tu cuenta alwaysdata (aparece en la
>   URL). **No lo inventes**: tómalo del panel tras crear la cuenta.
> - `URL_ALWAYSDATA` → `https://USUARIO_ALWAYSDATA.alwaysdata.net`
> - `TU_REPO_GITHUB` → ruta de tu repositorio, p. ej. `nestorGPC/StreetWear-CR`.

> **Importante**: este proyecto usa **SQLite** (requisito académico). No se
> migra a MySQL/PostgreSQL y no se borra la base local.

---

## 1. Crear cuenta alwaysdata

- **Dónde**: navegador → https://www.alwaysdata.com/
- **Hacer**: pulsa **Sign up** y registra tu correo + contraseña.
- **Resultado esperado**: correo de confirmación y acceso al panel
  https://admin.alwaysdata.com/
- **Si falla**: revisa spam; reintenta con otro correo.

## 2. Elegir Free

- **Dónde**: panel → **Subscriptions** (Suscripciones).
- **Hacer**: elige **Public Cloud — Free**.
- **Resultado esperado**: suscripción Free activa: 1 GB disco, 256 MB RAM,
  1/4 CPU, backups 3 días. Sin coste.
- **Si falla**: confirma tu correo. Si tu universidad usa *Academic Cloud*,
  puedes solicitarlo después.

## 3. Obtener nombre de cuenta

- **Dónde**: panel → **Accounts** (o esquina superior).
- **Hacer**: anota tu `USUARIO_ALWAYSDATA`.
- **Resultado esperado**: sabes tu usuario para todos los comandos y el `.env`.
- **Si falla**: si no ves la cuenta, confirma el correo de registro.

## 4. Crear/configurar sitio

- **Dónde**: panel → **Web > Sites** → **Add a site**.
- **Hacer**: tipo **PHP**, dirección `USUARIO_ALWAYSDATA.alwaysdata.net`,
  versión PHP **8.2**.
- **Resultado esperado**: sitio activo en la lista.
- **Si falla**: usa el hostname que el panel sugiera por defecto.

## 5. Configurar versión PHP

- **Dónde**: panel → **Environment > PHP** (o **Web > Sites > [sitio] > Modify > PHP version**).
- **Hacer**: selecciona **8.2** (o 8.3/8.4/8.5). El proyecto exige `^8.2`.
- **Resultado esperado**: versión fijada para web y CLI.
- **Si falla**: consulta https://help.alwaysdata.com/en/web-hosting/languages/php/configuration/

### 5b. Comprobación de extensiones (SQLite) — CRÍTICO

- **Dónde**: SSH (paso 8) o Web → Sites → **Open an SSH terminal**.
- **Comando exacto**:
  ```bash
  php -v
  php -m | grep -i sqlite
  ```
- **Resultado esperado**: `php -v` → `PHP 8.2.x`+ ; `php -m | grep -i sqlite`
  muestra `PDO`, `pdo_sqlite` y `sqlite3`.
- **Si falta**: panel → **Environment > PHP** (o sitio → Modify → PHP configuration) añade:
  ```
  extension = pdo_sqlite.so
  extension = sqlite3.so
  ```
  Guarda y repite `php -m | grep -i sqlite`.

## 6. Configurar document root en /public

- **Dónde**: panel → **Web > Sites > [sitio] > Modify** → **Application path**.
- **Hacer**: apunta a la carpeta `public` del proyecto:
  ```
  /www/streetwear/public
  ```
- **Resultado esperado**: el servidor solo sirve `public/`. `.env`, `database/`
  y `storage/` quedan fuera del alcance web.
- **Si falla**: ajusta la ruta al directorio que uses en el paso 9.

## 7. Activar SSH

- **Dónde**: panel → **Remote access > SSH/SFTP**.
- **Hacer**: habilita usuario SSH (contraseña o clave pública).
- **Resultado esperado**: puedes conectar a `ssh-[account].alwaysdata.net`
  puerto 22.
- **Si falla**: Windows 10+ incluye `ssh`; alternativa web en
  `https://ssh-USUARIO_ALWAYSDATA.alwaysdata.net`.

## 8. Conectarse por SSH

- **Dónde**: terminal de VS Code o PowerShell.
- **Comando exacto**:
  ```bash
  ssh USUARIO_ALWAYSDATA@ssh-USUARIO_ALWAYSDATA.alwaysdata.net
  ```
- **Resultado esperado**: prompt `USUARIO_ALWAYSDATA@host:~$`.
- **Si falla**: acepta el fingerprint (`yes`); revisa usuario/contraseña.

## 9. Subir/clonar StreetWear CR

- **Dónde**: SSH.
- **Comando exacto**:
  ```bash
  cd ~/www
  git clone https://github.com/TU_REPO_GITHUB.git streetwear
  cd streetwear
  ```
  > Repo privado: `git clone https://TOKEN@github.com/TU_REPO_GITHUB.git streetwear`
- **Resultado esperado**: carpeta `~/www/streetwear` con el proyecto.
- **Si falla**: instala git (panel **Advanced > Packages**), o valida el token.

## 10. Instalar Composer dependencies

- **Dónde**: SSH, dentro de `~/www/streetwear`.
- **Comando exacto**:
  ```bash
  composer install --no-dev --optimize-autoloader
  ```
- **Resultado esperado**: se crea `vendor/` sin paquetes de desarrollo.
- **Si falla**:
  - `composer` no existe → `composer2 install`.
  - Reclama `pdo_sqlite`/`sqlite3` → completa el paso 5b y repite.
  - PHP < 8.2 → sube la versión (paso 5).

## 11. Crear .env

- **Dónde**: SSH, dentro de `~/www/streetwear`.
- **Comando exacto**:
  ```bash
  cp .env.alwaysdata.example .env
  nano .env
  ```
- **Hacer**: sustituye `USUARIO` por tu cuenta y ajusta:
  ```
  APP_URL=https://USUARIO_ALWAYSDATA.alwaysdata.net
  DB_DATABASE=/home/USUARIO_ALWAYSDATA/www/streetwear/database/database.sqlite
  ```
  Guarda: Ctrl+O, Enter; sal: Ctrl+X.
- **Resultado esperado**: `.env` con `APP_ENV=production`, `APP_DEBUG=false`,
  `SESSION_SECURE_COOKIE=true`, `DB_CONNECTION=sqlite`.
- **Si falla**: sin `nano` usa `vi` (i = editar, `:wq` = guardar) o edita con
  la extensión VS Code **Remote - SSH**.

## 12. Generar APP_KEY

- **Dónde**: SSH, dentro de `~/www/streetwear`.
- **Comando exacto**:
  ```bash
  php artisan key:generate
  ```
- **Resultado esperado**: `Application key set successfully.`
- **Si falla**: revisa permisos de `.env` (`chmod 664 .env`).

## 13. Crear database.sqlite

- **Dónde**: SSH, dentro de `~/www/streetwear`.
- **Comando exacto**:
  ```bash
  touch database/database.sqlite
  chmod 775 database
  chmod 664 database/database.sqlite
  ```
- **Resultado esperado**: archivo SQLite creado y escribible (sin `777`).
- **Si falla**: confirma que `database/` existe en el clone.

## 14. Ejecutar migraciones

- **Dónde**: SSH, dentro de `~/www/streetwear`.
- **Comando exacto**:
  ```bash
  php artisan migrate --force
  ```
- **Resultado esperado**: tablas `users`, `sessions`, `cache`, `jobs`, `roles`,
  `permissions`, `categories`, `products`, `orders`, `order_items`, `payments`.
- **Si falla**:
  - Driver SQLite → paso 5b.
  - Permisos → `chmod 664 database/database.sqlite`.
  - APP_KEY vacía → paso 12.

## 15. Ejecutar seeders

- **Dónde**: SSH, dentro de `~/www/streetwear`.
- **Comando exacto**:
  ```bash
  php artisan db:seed --force
  ```
- **Resultado esperado**: roles, admin + cliente demo, 4 categorías, 5 productos
  y 3 pedidos con pagos. Los seeders son idempotentes.
- **Si falla**: reintenta; los datos no se duplican.

> **Datos DEMO** (generados por los seeders):
> - Admin: `admin@streetwearcr.test` / `Admin12345` (accede a `/admin`)
> - Cliente: `cliente@streetwearcr.test` / `Cliente12345`
> Cambia estas contraseñas después de la presentación si el sitio se mantiene.

## 16. Preparar assets (Vite)

- **Estrategia elegida (A)**: compilar en local y subir el build (menos riesgo
  durante la presentación).
- **En local (VS Code/PowerShell)**:
  ```powershell
  npm install
  npm run build
  ```
- **Subir** (desde local, PowerShell):
  ```powershell
  scp -r "public\build" USUARIO_ALWAYSDATA@ssh-USUARIO_ALWAYSDATA.alwaysdata.net:/home/USUARIO_ALWAYSDATA/www/streetwear/public/
  ```
- **Verificar** (SSH):
  ```bash
  cat ~/www/streetwear/public/build/manifest.json
  ```
- **Si falla**: alternativa (B) compilar en el servidor:
  ```bash
  cd ~/www/streetwear && npm install && npm run build
  ```
  (Consume recursos del plan Free; por eso se prefiere la opción A.)

## 17. storage:link

- **Dónde**: SSH, dentro de `~/www/streetwear`.
- **Comando exacto**:
  ```bash
  php artisan storage:link
  ```
- **Resultado esperado**: `public/storage` → `storage/app/public`; las imágenes
  responden en `/storage/...`.
- **Si falla**: el mensaje "link already exists" no es un error.

## 18. Configurar permisos

- **Dónde**: SSH, dentro de `~/www/streetwear`.
- **Comando exacto** (sin `777`):
  ```bash
  find storage -type d -exec chmod 775 {} +
  find storage -type f -exec chmod 664 {} +
  chmod -R 775 bootstrap/cache
  chmod 775 database
  chmod 664 database/database.sqlite
  ```
- **Resultado esperado**: escritura para el usuario del hosting en `storage/`,
  `bootstrap/cache/` y `database.sqlite`.
- **Si falla**: comprueba propietario/grupo (`ls -la`).

## 19. Configurar HTTPS

- **Dónde**: panel → **Web > Sites > [sitio] > SSL/TLS**.
- **Hacer**:
  1. Activa **Let's Encrypt** para `USUARIO_ALWAYSDATA.alwaysdata.net`.
  2. Activa **Redirect HTTP → HTTPS**.
  3. (Opcional) activa **HSTS** tras verificar todo por HTTPS.
- **Resultado esperado**: `URL_ALWAYSDATA` carga con candado; http redirige a
  https (301/308).
- **Si falla**:
  - `APP_URL` debe empezar por `https://` y re-cachear `config:cache`.
  - Cookies de sesión: confirma `SESSION_SECURE_COOKIE=true`.
  - Assets mixtos: las vistas usan `asset()` (genera https por `APP_URL`).

## 20. Probar página pública

- **Dónde**: navegador → `https://URL_ALWAYSDATA/productos`
- **Resultado esperado**: catálogo con productos, filtros e imágenes.
- **Si falla**:
  - 500 → `tail -n 50 ~/www/streetwear/storage/logs/laravel.log`
  - 404 → revisa document root (paso 6) y `.htaccess`.
  - Imágenes rotas → `php artisan storage:link` (paso 17).

## 21. Probar login

- **Dónde**: navegador → `https://URL_ALWAYSDATA/login`
- **Credencial demo**: `cliente@streetwearcr.test` / `Cliente12345`
- **Resultado esperado**: redirige a `/mi-cuenta` y la sesión persiste.
- **Si falla**:
  - No guarda sesión → estás en `http://`; usa `https://` (paso 19).
  - Error de tablas → migraciones (paso 14).

## 22. Probar carrito

- **Dónde**: navegador (cliente o invitado).
- **Hacer**: en `/productos`, agregar producto, cambiar cantidad, eliminar.
- **Resultado esperado**: subtotal, impuesto 13%, envío y total actualizados.
- **Si falla**: revisa sesión/cookies (paso 21).

## 23. Probar checkout

- **Dónde**: navegador, como **cliente** con artículos en el carrito.
- **Hacer**: `/checkout`, dirección (mín. 10 caracteres), método `card` o
  `paypal`, enviar.
- **Resultado esperado**: pedido creado con número de seguimiento `SWCR-...`,
  stock decrementado y confirmación en `/checkout/confirmacion/{id}`.
- **Si falla**: revisa logs; el token de idempotencia expira si cambias de sesión
  (reintenta el flujo completo).

## 24. Probar panel admin

- **Dónde**: navegador → `https://URL_ALWAYSDATA/admin`
- **Credencial demo**: `admin@streetwearcr.test` / `Admin12345`
- **Resultado esperado**: dashboard con recursos Categorías, Productos, Pedidos,
  Pagos, Usuarios, Reportes y Shield.
- **Si falla**:
  - "No autorizado" → el usuario debe tener rol `super_admin` (paso 15).
  - 419 → cookie CSRF: usa `https://` y cookies habilitadas.

## 25. Probar reportes

- **Dónde**: navegador, como admin → `/reportes` y `admin/reports`.
- **Hacer**: descarga los 3 PDF (`reporte-pedidos.pdf`, `reporte-ventas.pdf`,
  `reporte-productos.pdf`).
- **Resultado esperado**: PDFs generados correctamente.
- **Si falla**: revisa extensiones `mbstring`/`dom`/`xml` en `php -m` (paso 5b).

## 26. Comprobar logs

- **Dónde**: SSH.
- **Comando exacto**:
  ```bash
  tail -f ~/www/streetwear/storage/logs/laravel.log
  ```
- **Resultado esperado**: sin errores al recorrer los flujos; en producción solo
  se registran errores (`LOG_LEVEL=error`).
- **Si falla**: ante un 500, el log muestra la causa; corrige y repite
  `php artisan optimize:clear`.

---

## Optimización de producción (opcional tras verificar)

```bash
cd ~/www/streetwear
php artisan optimize:clear
php artisan config:cache
php artisan view:cache
php artisan route:cache
```

> `route:cache` **sí es compatible** con este proyecto (verificado en local).
> Tras cualquier cambio en config/rutas, repite `optimize:clear`.

## Notas finales

- Tras cada actualización de código, repite: `git pull` → `composer install
  --no-dev --optimize-autoloader` → `php artisan migrate --force` →
  `php artisan optimize:clear` → `config:cache` → `view:cache`.
- No subas `.env`, `database.sqlite` ni `storage/` a Git: ya están en
  `.gitignore`.
- No uses `migrate:fresh` sobre la base del servidor (borra datos de la demo).
