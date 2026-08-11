# DEPLOY CHECKLIST — StreetWear CR → alwaysdata Free

> Verificado: 2026-08-10 · URL: `https://nestor-alwaysdata-net.alwaysdata.net`

## Seguridad y configuración

- [x] sitio abre por HTTPS (candado válido en el navegador)
- [x] certificado válido (Let's Encrypt activo; sin avisos)
- [x] APP_DEBUG=false
- [x] APP_ENV=production
- [x] APP_URL=https://nestor-alwaysdata-net.alwaysdata.net
- [x] SESSION_SECURE_COOKIE=true
- [x] .env NO subido a Git
- [x] database.sqlite NO subida a Git
- [x] no se exponen secretos en el sitio ni en repositorio
- [x] redirección HTTP → HTTPS activa (código 301/308)

## Funcionalidad pública (cliente)

- [x] catálogo funciona (`/productos` → 200)
- [x] imágenes funcionan (`/storage/products/seed/...` → 200)
- [x] filtros funcionan (categoría, precio, búsqueda)
- [x] cookies funcionan (productos recientes; sesión)
- [x] login funciona (`cliente@streetwearcr.test` / `Cliente12345` → 302 a `/mi-cuenta`)
- [x] registro funciona
- [x] carrito funciona (agregar, cantidad, eliminar)
- [x] checkout funciona (`/checkout`)
- [x] pedido se guarda (aparece en `/mi-cuenta/pedidos`)
- [x] stock disminuye tras el pedido
- [x] mis pedidos funciona (historial y detalle)

## Panel administrativo

- [x] admin funciona (`/admin` con `admin@streetwearcr.test` / `Admin12345`)
- [x] cliente NO accede a `/admin` (403 verificado)
- [x] reportes funcionan (PDF de pedidos, ventas y productos)
- [x] gestión de productos/categorías/pedidos/pagos/usuarios operativa

## Datos y entorno

- [x] SQLite conserva datos (2 usuarios, 4 categorías, 5 productos, 3 pedidos, 3 pagos)
- [x] storage funciona (`php artisan storage:link`; imágenes visibles)
- [x] `php artisan test` pasan en local (41 passed, 129 assertions)
- [x] `php artisan test` pasan en el servidor (41 passed, 129 assertions)
- [x] assets compilados presentes (`public/build/manifest.json`)
- [x] logs sin errores (`storage/logs/laravel.log`)

## Comandos de verificación rápida (SSH)

```bash
php -v                              # PHP 8.4.24 (siempredata)
php -m | grep -i sqlite             # pdo_sqlite y sqlite3
composer --version                  # 2.9.8
php artisan about                   # Environment: production, Debug: OFF
php artisan migrate:status          # 9 migraciones Ran
```

> Nota: si vuelves a correr `php artisan test` en el servidor, ejecuta primero
> `php artisan optimize:clear` (la `config:cache` de producción interfiere con
> los tests: errores 419/CSRF). Luego re-aplica `config:cache`, `view:cache` y
> `route:cache`.
