# Punto 6 - Perfil de usuario con modificación de datos e historial de pedidos

## 1. ¿Qué pide la profesora?
DOS cosas por separado: A) que el usuario pueda modificar sus datos personales; B) que pueda ver el historial de sus pedidos.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
A) PERFIL: `AccountController@updateProfile` valida name y email (con `Rule::unique` ignorando su propio id para no chocar con él mismo), actualiza el usuario y redirige con mensaje de éxito.
B) HISTORIAL: `AccountController@orders` lista los pedidos del usuario autenticado (`$request->user()->orders()->latest()->get()`) y `showOrder` muestra el detalle con ítems y pago. **Además protege pedidos ajenos con `abort_unless($order->user_id === $request->user()->id, 403)`** — un cliente no puede abrir el pedido de otro ni cambiando la URL.

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/AccountController.php`
- Métodos: `editProfile`, `updateProfile`, `orders`, `showOrder`
- Vistas: `account/profile.blade.php`, `account/orders.blade.php`, `account/order-detail.blade.php`, `account/dashboard.blade.php`
- Rutas: GET/PUT `/mi-cuenta/perfil`, GET `/mi-cuenta/pedidos`, GET `/mi-cuenta/pedidos/{order}` (todas dentro del grupo `auth`)
- Relación: `app/Models/User.php` → `orders()`; `app/Models/Order.php` → `items()`, `payment()`
- Tests: `tests/Feature/AccountTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `public function updateProfile`
- `Rule::unique('users', 'email')->ignore(`
- `public function orders`
- `abort_unless(` (en AccountController)
- `account.orders.show`

## 6. Fragmento importante
```php
public function showOrder(Request $request, Order $order)
{
    // Un cliente solo puede ver sus propios pedidos.
    abort_unless(
        $order->user_id === $request->user()->id,
        403
    );

    $order->load('items.product', 'payment');
    return view('account.order-detail', compact('order'));
}
```

## 7. Explicación sencilla
Para el perfil: recibo el formulario PUT, valido que el nombre no venga vacío y que el email sea único PERO ignorando el del usuario actual (si deja su mismo email no debe dar error). Luego `$user->update($data)` guarda en SQLite. Para el historial: Laravel ya sabe quién está logueado por la sesión, así que pido solo SUS pedidos ordenados del más nuevo al más viejo. En el detalle, antes de mostrar nada comparo el dueño del pedido con el usuario de la sesión; si no coinciden, error 403 prohibido.

## 8. Recorrido del sistema
Navbar "Mi cuenta" → GET /mi-cuenta/pedidos → AccountController@orders → User->orders() → SQLite tabla orders → account/orders.blade.php. Clic en un pedido → showOrder → valida dueño → orders + order_items + payments → order-detail.blade.php.

## 9. ¿Cómo lo pruebo?
1. Entrar como cliente → Mi cuenta → editar nombre → guardar → mensaje éxito y dato cambiado.
2. Intentar poner el email de otro usuario → error de validación.
3. /mi-cuenta/pedidos → lista de pedidos propios con total y estado.
4. Abrir un pedido → detalle con productos, montos, tracking y estado de pago.
5. Cambiar el ID en la URL por el de un pedido ajeno → pantalla 403.

## 10. ¿Qué evidencia puedo enseñarle?
Perfil editándose en vivo, historial con pedidos reales, el código del abort_unless, tests verdes de AccountTest, tablas users/orders en SQLite.

## 11. Test relacionado
Archivo: `tests/Feature/AccountTest.php`
Nombres y qué validan:
- `test_un_cliente_puede_actualizar_su_perfil` → A funciona
- `test_no_se_puede_usar_un_email_de_otro_usuario` → unicidad de email
- `test_un_cliente_puede_ver_el_detalle_de_su_pedido` → B detalle propio
- `test_un_cliente_no_puede_ver_el_pedido_de_otro_cliente` → seguridad 403

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué usas ignore($user->id) en el unique?
2. ¿Cómo evitas que un cliente vea pedidos ajenos?
3. ¿El perfil permite cambiar la contraseña también?
4. ¿Qué trae load('items.product', 'payment')?

## 13. Respuesta corta para defenderlo
1. "Para que al dejar su propio email no choque consigo mismo en la regla unique."
2. "Comparo el user_id del pedido contra el usuario de la sesión; si difiere lanzo 403."
3. "No, esa versión solo modifica nombre y email; la contraseña se gestiona en registro/login."
4. "Carga las líneas del pedido y cada producto, más el pago, evitando consultas N+1."

## 14. Problemas encontrados
Ninguno funcional. (Mejora opcional: permitir cambio de contraseña desde perfil.)

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
