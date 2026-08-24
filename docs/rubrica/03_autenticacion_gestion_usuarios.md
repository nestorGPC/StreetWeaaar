# Punto 3 - Autenticación y gestión de Usuarios

## 1. ¿Qué pide la profesora?
Que existan usuarios reales con autenticación (saber quién eres entre requests), sesiones, roles distintos (admin vs cliente), autorización (quién puede hacer qué) y rutas protegidas.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
Sistema completo verificado HOY en producción:
- Auth nativo Laravel (login/logout/registro) con sesiones en base de datos.
- Roles Spatie Permission: `super_admin` y `customer`.
- **Único usuario con rol `super_admin`: `id=1 | Administrador StreetWear CR | admin@streetwearcr.test`** (contraseña demo `Admin12345`). Un solo cliente: `cliente@streetwearcr.test`.
- Panel Filament `/admin` protegido por `User::canAccessPanel()` → solo `super_admin`.
- Gestión de usuarios vía Filament UserResource (`/admin/users`).
- Rutas públicas vs privadas separadas con middleware `guest` y `auth` en `routes/web.php`.
- HOY se asignaron los 73 permisos de Filament Shield al rol super_admin en producción → el admin puede gestionar categorías/productos/pedidos/pagos/usuarios.

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/AuthController.php`
- Modelo: `app/Models/User.php` (trait HasRoles, método `canAccessPanel`)
- Rutas: `routes/web.php` líneas 61–110 (grupos guest/auth)
- Migración: `2026_07_25_222903_create_permission_tables.php`
- Seeder: `database/seeders/UserSeeder.php` y `RoleSeeder.php`
- Panel: `app/Providers/Filament/AdminPanelProvider.php`
- Test: `tests/Feature/AuthTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `class AuthController`
- `Auth::attempt`
- `canAccessPanel`
- `$table->foreignId('user_id')` (en migraciones de permisos... mejor:) `create_permission_tables`
- `assignRole('customer')`

## 6. Fragmento importante
```php
// app/Models/User.php
public function canAccessPanel(Panel $panel): bool
{
    return $this->hasRole('super_admin');
}
```

## 7. Explicación sencilla
Cada request llega con una cookie de sesión; Laravel busca esa sesión en la tabla `sessions` de SQLite y sabe qué usuario está logueado. Los roles viven en tablas de Spatie (`roles`, `model_has_roles`). El panel admin pregunta primero `canAccessPanel()`: si no eres super_admin ni te muestra el login del panel.

## 8. Recorrido del sistema
Vista login → POST `/login` → `AuthController@login` → `Auth::attempt()` → SQLite `users` → sesión creada en `sessions` → redirect `/mi-cuenta`. Para admin: `/admin` → middleware Filament → `canAccessPanel()` → dashboard.

## 9. ¿Cómo lo pruebo?
1. Abrir https://nestor-alwaysdata-net.alwaysdata.net/admin sin sesión → login del panel.
2. Entrar como `cliente@streetwearcr.test` → intentar `/admin` → acceso denegado.
3. Entrar como `admin@streetwearcr.test` / `Admin12345` → dashboard Filament.
4. Ver usuarios en `/admin/users`.

## 10. ¿Qué evidencia puedo enseñarle?
Pantalla del panel admin, código de `canAccessPanel`, tablas `roles`/`model_has_roles` abiertas en un DB browser, test AuthTest verde.

## 11. Test relacionado
Archivo: `tests/Feature/AuthTest.php`
Tests: `test_un_usuario_registrado_puede_iniciar_sesion`, `test_no_puede_iniciar_sesion_con_la_contrasena_incorrecta`, `test_se_limitan_los_intentos_de_inicio_de_sesion`
Validan: login feliz, rechazo de credenciales malas y rate limit.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Dónde guarda Laravel las sesiones aquí?
2. ¿Cómo distingue tu app un admin de un cliente?
3. ¿Qué pasa si un cliente escribe /admin manualmente?
4. ¿Qué librería maneja los roles?

## 13. Respuesta corta para defenderlo
1. "En la base de datos SQLite, tabla sessions (SESSION_DRIVER=database)."
2. "Con Spatie Permission: roles super_admin y customer en model_has_roles."
3. "Filament llama canAccessPanel(); sin el rol no puede ni autenticarse en el panel."
4. "Spatie Laravel Permission, integrada con Filament Shield."

## 14. Problemas encontrados
- Ninguno activo. (Los permisos Shield faltantes en BD fueron corregidos hoy: 73 permisos asignados.)

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
