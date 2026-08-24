# Punto 5 - Inicio de sesión y cierre de sesión

## 1. ¿Qué pide la profesora?
Login y logout funcionales, con validación, mensajes de error claros, manejo seguro de la sesión y protección contra fuerza bruta.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
- Login: valida email+password, usa `Auth::attempt` con opción "remember", error genérico único ("correo o contraseña incorrectos" — no revela cuál falló), `redirect()->intended()` para volver a donde ibas.
- **Rate limiting real**: la ruta POST /login lleva `->middleware('throttle:5,1')` = máximo 5 intentos por minuto.
- Logout: `Auth::logout()` + `session()->invalidate()` + `regenerateToken()` → redirige al login con mensaje.
- Solo invitados pueden ver los formularios (middleware guest).

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/AuthController.php` → `login()` (~línea 53) y `logout()` (~línea 78)
- Vistas: `resources/views/auth/login.blade.php`
- Rutas: POST `/login` (con throttle), POST `/logout`
- Test: `tests/Feature/AuthTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `throttle:5,1`
- `public function login`
- `public function logout`
- `onlyInput('email')`
- `session()->invalidate`

## 6. Fragmento importante
```php
if (Auth::attempt($credentials, $request->boolean('remember'))) {
    $request->session()->regenerate();
    return redirect()->intended(route('account.dashboard'))...
}
return back()->withErrors(['email' => 'El correo o la contraseña son incorrectos.'])
             ->onlyInput('email');
```

## 7. Explicación sencilla
Al enviar el formulario, Laravel busca el usuario por email y compara la contraseña contra su hash bcrypt. Si coincide, renueva el ID de sesión (anti secuestro). Si no, muestro UN solo mensaje genérico para no decirle a un atacante si el correo existe. El logout borra la sesión del servidor y cambia el token CSRF.

## 8. Recorrido del sistema
login.blade.php → POST /login (throttle) → AuthController@login → users(SQLite) → sessions → redirect dashboard. Logout: POST /logout → invalidate + regenerateToken → login.

## 9. ¿Cómo lo pruebo?
1. /login con credenciales malas → mensaje de error y el email se conserva.
2. Entrar bien → dashboard.
3. Cerrar sesión → vuelve a login con flash "Sesión cerrada".
4. Fallar 6 veces seguidas → bloqueo 429 un minuto.

## 10. ¿Qué evidencia puedo enseñarle?
Código del throttle en routes/web.php, test de rate limiting verde, pantalla del error 429 o del mensaje genérico.

## 11. Test relacionado
Archivo: `tests/Feature/AuthTest.php`
Nombres: `test_no_puede_iniciar_sesion_con_la_contrasena_incorrecta`, `test_un_usuario_autenticado_puede_cerrar_sesion`, `test_se_limitan_los_intentos_de_inicio_de_sesion`

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué el mensaje de error es genérico?
2. ¿Qué significa throttle:5,1?
3. ¿Qué hace regenerate()?
4. ¿Cómo funciona "remember me"?

## 13. Respuesta corta para defenderlo
1. "Si dijera 'ese email no existe' ayudaría a enumerar cuentas válidas."
2. "Máximo 5 intentos por minuto; el sexto recibe HTTP 429 durante ese minuto."
3. "Renueva el ID de sesión para evitar fijación/robo de sesión."
4. "Laravel guarda un token persistente cifrado en cookie remember_me que re-autentica sin pasar por login."

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
