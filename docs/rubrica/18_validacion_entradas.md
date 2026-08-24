# Punto 18 - Validación de entradas del usuario

## 1. ¿Qué pide la profesora?
QUE TODA entrada importante del usuario esté validada en servidor antes de usarse: registro, login, perfil, filtros, carrito, checkout, y formularios de administración.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
Validación `$request->validate([...])` presente en TODOS los puntos de entrada:
- Registro: name required|max:255, email email|unique, password confirmed|min:8.
- Login: email+password required.
- Perfil: name required, email unique ignorándose a sí mismo.
- Carrito update: quantity required|integer|min:1|max:{stock dinámico}.
- Checkout: shipping_address min:10|max:500, payment_method in:card,paypal, checkout_token string (+ hash_equals contra sesión).
- Filtros catálogo: guardas filled() + is_numeric() para precios.
- Admin (Filament): sus Resources usan el sistema de forms/validación de Filament internamente (required, numeric, etc.) — CRUD protegido por permisos Shield.
Además: route model binding (IDs inexistentes → 404 automático) y reglas de negocio en checkout (stock/active revalidadas en transacción).

## 4. ¿Dónde se encuentra?
- `app/Http/Controllers/AuthController.php` (register/login)
- `app/Http/Controllers/AccountController.php` (updateProfile)
- `app/Http/Controllers/CartController.php` (update)
- `app/Http/Controllers/CheckoutController.php` (store)
- `app/Http/Controllers/ProductController.php` (filtros defensivos)
- `app/Filament/Resources/**` (validación de admin)

## 5. ¿Qué buscar en VS Code?
Buscar:
- `$request->validate([`
- `'confirmed', 'min:8'` → mejor: `confirmed`
- `Rule::unique(`
- `'in:card,paypal'`
- `is_numeric($request->min_price)`
- `hash_equals(`

## 6. Fragmento importante
```php
$data = $request->validate([
    'shipping_address' => ['required', 'string', 'min:10', 'max:500'],
    'payment_method'   => ['required', 'in:card,paypal'],
    'checkout_token'   => ['required', 'string'],
]);
```

## 7. Explicación sencilla
Nunca confío en lo que llega del navegador. Cada controlador declara SUS reglas: si algo falla, Laravel corta y regresa automáticamente con los errores a la vista, sin ejecutar nada de mi lógica. En checkout agrego dos capas extra: whitelist del método de pago (solo card/paypal) y comparación segura del token anti doble-envío con hash_equals. Y aunque la sesión diga X, al comprar releo productos y stock desde la BD dentro de la transacción.

## 8. Recorrido del sistema
Formulario → POST con CSRF → validate() falla → redirect back + $errors a la vista; validate() pasa → lógica de negocio → BD.

## 9. ¿Cómo lo pruebo?
1. Registro vacío → errores por campo.
2. Cantidad 0 o 999 en carrito → rechazo.
3. Dirección de 5 caracteres en checkout → error min:10 visible.
4. POST manual a checkout con payment_method=bizum → rechazado (in:card,paypal).

## 10. ¿Qué evidencia puedo enseñarle?
Errores visibles en vivo en cada formulario, los bloques validate() de cada controlador, y los tests negativos verdes.

## 11. Test relacionado
Múltiples: `AuthTest::test_el_registro_crea_un_usuario_y_le_asigna_el_rol_customer`, `CartTest::test_no_se_puede_actualizar_la_cantidad_por_encima_del_stock`, `CheckoutTest::test_no_se_puede_hacer_checkout_con_el_carrito_vacio`, `CheckoutIdempotencyTest::test_un_doble_post_no_crea_dos_pedidos`, entre otros.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Validas también en JavaScript?
2. ¿Por qué validar en servidor si ya hay HTML required?
3. ¿Qué es route model binding y qué valida?

## 13. Respuesta corta para defenderlo
1. "El navegador ayuda en UX, pero la validación REAL y obligatoria siempre es de servidor."
2. "HTML se salta con DevTools o curl; el servidor nunca confía en el cliente."
3. "Laravel convierte {product} de la URL en un modelo o devuelve 404; evita IDs inválidos en toda la app."

## 14. Problemas encontrados
- Caso menor ya documentado en Punto 10: add() del carrito valida stock pero no active (se corrige con la misma técnica de update()).

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente (el caso add()/active queda cubierto al aplicar la mejora del Punto 10).
