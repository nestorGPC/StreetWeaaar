# Punto 16 - Backend PHP + SQLite (con Laravel)

## 1. ¿Qué pide la profesora?
Backend en PHP usando Laravel y SQLite como base de datos, con configuración correcta y migraciones funcionando.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
- `composer.json`: `php ^8.2`, `laravel/framework ^12.0` (Laravel 12 moderno).
- Base de datos SQLite activa: `php artisan about` muestra Environment local / Database sqlite; `.env` con `DB_CONNECTION=sqlite`; archivo `database/database.sqlite`.
- Cache y sesiones también sobre la BD (SESSION_DRIVER=database) — verificado hoy.
- **9 migraciones ejecutadas** (`migrate:status`): users/cache/jobs base + permission_tables (Spatie) + categories + products + orders + order_items + payments.
- Seeders completos: UserSeeder, RoleSeeder, CategorySeeder, ProductSeeder, OrderSeeder.
- Desplegado EN PRODUCCIÓN con este mismo stack en alwaysdata (https://nestor-alwaysdata-net.alwaysdata.net responde 200).

## 4. ¿Dónde se encuentra?
- Config BD: `config/database.php` (conexión sqlite)
- Archivo BD: `database/database.sqlite`
- Migraciones: `database/migrations/*.php` (9 archivos)
- Modelos: `app/Models/{User,Category,Product,Order,OrderItem,Payment}.php`
- Composer: `composer.json` / `composer.lock`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `'sqlite' => [` (config/database.php)
- `Schema::create('orders'`
- `class Product extends Model`
- `DB_CONNECTION` (.env / .env.example)

## 6. Fragmento importante
```php
// config/database.php
'sqlite' => [
    'driver' => 'sqlite',
    'database' => env('DB_DATABASE', database_path('database.sqlite')),
    'prefix' => '',
    'foreign_key_constraints' => env('DB_FOREIGN_KEYS', true),
],
```

## 7. Explicación sencilla
Laravel es el framework MVC en PHP: las rutas llaman controladores, estos usan modelos Eloquent que hablan con SQLite mediante Query Builder parametrizado. SQLite guarda TODO en un único archivo database.sqlite sin servidor de BD separado — perfecto para este proyecto porque es rápido, portátil (se entrega dentro del ZIP si aplica) y soporta transacciones y llaves foráneas, que uso en checkout.

## 8. Recorrido del sistema
Request Apache/Nginx → public/index.php (PHP-Laravel) → Router → Controller → Model (Eloquent) → PDO sqlite → database.sqlite → respuesta Blade.

## 9. ¿Cómo lo pruebo?
1. `php artisan about` → muestra Database sqlite.
2. `php artisan migrate:status` → 9 Ran.
3. Abrir database.sqlite con DB Browser → tablas reales con datos.
4. Visitar el hosting → misma app corriendo.

## 10. ¿Qué evidencia puedo enseñarle?
composer.json, about/migrate:status en terminal, DB Browser con las tablas abiertas, URL del hosting funcionando.

## 11. Test relacionado
Toda la suite corre contra SQLite en memoria/refrescada (`RefreshDatabase`): 41 passed / 129 assertions (ejecutado HOY).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué SQLite y no MySQL?
2. ¿Qué es Eloquent?
3. ¿Dónde está físicamente tu base de datos?

## 13. Respuesta corta para defenderlo
1. "El proyecto lo exige así y además simplifica despliegue: es un archivo, transaccional y suficiente para el tráfico de una tienda demo."
2. "El ORM de Laravel: cada tabla es una clase modelo; consulto con métodos PHP, no SQL crudo."
3. "En database/database.sqlite; un solo archivo con todas las tablas."

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
