# DEPLOY CHECKLIST — StreetWear CR → alwaysdata Free

> Marca cada casilla al verificarla. URL esperada:
> `https://USUARIO_ALWAYSDATA.alwaysdata.net`

## Seguridad y configuración

- [ ] sitio abre por HTTPS (candado válido en el navegador)
- [ ] certificado válido (Let's Encrypt activo; sin avisos)
- [ ] APP_DEBUG=false
- [ ] APP_ENV=production
- [ ] APP_URL=https://USUARIO_ALWAYSDATA.alwaysdata.net
- [ ] SESSION_SECURE_COOKIE=true
- [ ] .env NO subido a Git
- [ ] database.sqlite NO subida a Git
- [ ] no se exponen secretos en el sitio ni en repositorio
- [ ] redirección HTTP → HTTPS activa (código 301/308)

## Funcionalidad pública (cliente)

- [ ] catálogo funciona (`/productos`)
- [ ] imágenes funcionan (`/storage/products/seed/...`)
- [ ] filtros funcionan (categoría, precio, búsqueda)
- [ ] cookies funcionan (productos recientes; sesión)
- [ ] login funciona (`cliente@streetwearcr.test` / `Cliente12345`)
- [ ] registro funciona
- [ ] carrito funciona (agregar, cantidad, eliminar)
- [ ] checkout funciona (`/checkout`)
- [ ] pedido se guarda (aparece en `/mi-cuenta/pedidos`)
- [ ] stock disminuye tras el pedido
- [ ] mis pedidos funciona (historial y detalle)

## Panel administrativo

- [ ] admin funciona (`/admin` con `admin@streetwearcr.test` / `Admin12345`)
- [ ] reportes funcionan (PDF de pedidos, ventas y productos)
- [ ] gestión de productos/categorías/pedidos/pagos/usuarios operativa

## Datos y entorno

- [ ] SQLite conserva datos (persistente entre visitas y reinicios)
- [ ] storage funciona (`php artisan storage:link`; subidas visibles)
- [ ] `php artisan test` pasan en local (41 passed)
- [ ] assets compilados presentes (`public/build/manifest.json`)
- [ ] logs sin errores (`storage/logs/laravel.log`)

## Comandos de verificación rápida (SSH)

```bash
php -v                              # PHP 8.2 o superior
php -m | grep -i sqlite             # pdo_sqlite y sqlite3
composer --version                  # Composer 2.x
php artisan about                   # Environment: production, Debug: OFF
php artisan migrate:status          # todas las migraciones Ran
```
