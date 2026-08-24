# Punto 4 - Registro de usuarios nuevos

## 1. ¿Qué pide la profesora?
El recorrido COMPLETO: formulario → validación → controller → modelo User → SQLite → rol customer automático → redirección con sesión iniciada.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
Implementación exacta de ese recorrido en `AuthController@register`: valida `name/email/password confirmed min:8`, hashea con bcrypt, crea el usuario, asegura el rol `customer` con `firstOrCreate` y lo asigna, inicia sesión y regenera la sesión. Mensaje flash de bienvenida. Solo accesible para invitados (middleware `guest`).

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/AuthController.php` → `register()` (líneas ~18–46)
- Vista: `resources/views/auth/register.blade.php`
- Ruta: GET/POST `/registro` → `register.store`
- Modelo/Migración: `app/Models/User.php`; `0001_01_01_000000_create_users_table.php`
- Test: `tests/Feature/AuthTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `public function register`
- `'confirmed', 'min:8'`
- `unique:users,email`
- `Hash::make($data['password'])`
- `assignRole('customer')`

## 6. Fragmento importante
```php
$data = $request->validate([
    'name'     => ['required', 'string', 'max:255'],
    'email'    => ['required', 'email', 'max:255', 'unique:users,email'],
    'password' => ['required', 'confirmed', 'min:8'],
]);

$user = User::create([...  'password' => Hash::make($data['password'])]);
$user->assignRole('customer');
Auth::login($user);
$request->session()->regenerate();
```

## 7. Explicación sencilla
El formulario envía POST /registro con token CSRF. Laravel valida cada campo; si algo falla vuelve atrás mostrando errores. Si pasa, guardo la contraseña HASHEADA (nunca texto plano), creo el usuario en SQLite, le pongo el rol cliente automáticamente, lo dejo logueado y lo mando a su cuenta con mensaje de bienvenida.

## 8. Recorrido del sistema
register.blade.php → POST /registro (guest+CSRF) → AuthController@register → User::create → SQLite `users` + `model_has_roles` → sesión nueva → redirect account.dashboard con flash success.

## 9. ¿Cómo lo pruebo?
1. Ir a /registro.
2. Enviar vacío → errores por campo.
3. Contraseñas distintas → error "confirmación".
4. Email repetido → error unique.
5. Datos válidos → cae en /mi-cuenta logueado con mensaje.

## 10. ¿Qué evidencia puedo enseñarle?
La vista registro, el método register(), un usuario recién creado en BD con su hash, y el test verde.

## 11. Test relacionado
Archivo: `tests/Feature/AuthTest.php`
Nombre: `test_el_registro_crea_un_usuario_y_le_asigna_el_rol_customer`
Valida: creación + rol customer automáticamente.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué Hash::make y no md5?
2. ¿Qué hace `confirmed`?
3. ¿Por qué regenerate de sesión tras registrar?
4. ¿Y si dos personas registran el mismo email a la vez?

## 13. Respuesta corta para defenderlo
1. "bcrypt es el estándar de Laravel: lento a propósito y con salt; md5 se rompe por fuerza bruta."
2. "Exige el campo password_confirmation igual a password."
3. "Previene fijación de sesión: el atacante no puede predecir el ID de sesión."
4. "La columna email es única en SQLite; la segunda inserción fallaría y Laravel devolvería error de validación."

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
