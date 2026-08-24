# Punto 14 - Confirmación de pedido con detalles y número de seguimiento

## 1. ¿Qué pide la profesora?
Tras comprar, una pantalla de confirmación con los DETALLES de la compra y un NÚMERO DE SEGUIMIENTO.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
- Tras el store exitoso redirige a `checkout.success` con la orden.
- `success(Order $order)` protege con 403 si el pedido no es tuyo y carga `items` + `payment`.
- Tracking generado con formato **`SWCR-YYYYMMDD-XXXXXX`** (fecha + 6 caracteres aleatorios únicos verificados contra la BD en un do-while).
- Vista `checkout/success.blade.php` muestra: número de seguimiento, productos, cantidades, dirección, desglose subtotal/IVA/envío/total, estado del pedido y estado del pago.

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/CheckoutController.php` → `success()` y `generateTrackingNumber()`
- Vista: `resources/views/checkout/success.blade.php`
- Ruta: GET `/checkout/confirmacion/{order}` → `checkout.success`
- Columna: migración create_orders_table → `tracking_number` unique
- Tests: `tests/Feature/CheckoutTest.php`, `CheckoutIdempotencyTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `SWCR-`
- `public function success(`
- `generateTrackingNumber`
- `checkout.success`
- `Str::upper(Str::random(6))`

## 6. Fragmento importante
```php
do {
    $trackingNumber = 'SWCR-' . now()->format('Ymd')
        . '-' . Str::upper(Str::random(6));
} while (
    Order::where('tracking_number', $trackingNumber)->exists()
);
```

## 7. Explicación sencilla
Al confirmar la compra genero un código tipo SWCR-20260824-A1B2C3: prefijo de la marca, fecha del día y seis caracteres aleatorios. Antes de usarlo pregunto a la BD si ya existe; si existiera, genero otro (casi imposible, pero la columna es única y me protege). En la pantalla de confirmación cargo el pedido con sus ítems y su pago y muestro TODO: qué compró, cuánto, a dónde y su código para dar seguimiento.

## 8. Recorrido del sistema
POST /checkout OK → redirect /checkout/confirmacion/{order} → CheckoutController@success → verifica dueño (403 si no) → load items+payment → SQLite orders/order_items/payments → checkout.success.blade.php.

## 9. ¿Cómo lo pruebo?
1. Comprar algo → caes automáticamente en la confirmación.
2. Verificar: tracking SWCR-..., lista de productos, totales iguales al carrito, estado pago pendiente.
3. Copiar la URL y abrirla en incógnito/otro usuario → 403.
4. Buscar el mismo tracking en /mi-cuenta/pedidos → mismo pedido.

## 10. ¿Qué evidencia puedo enseñarle?
Pantalla de confirmación completa con el tracking resaltado, el método generateTrackingNumber, y la fila en orders.

## 11. Test relacionado
Archivo: `tests/Feature/CheckoutTest.php`
Nombre: `test_un_cliente_puede_completar_el_checkout` (incluye verificación de la orden creada con tracking).
Complementario: `tests/Feature/AccountTest.php::test_un_cliente_puede_ver_el_detalle_de_su_pedido`.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Cómo garantizas que el número de seguimiento no se repita?
2. ¿Qué pasa si alguien cambia el ID en la URL de confirmación?
3. ¿El cliente puede seguir su pedido después?

## 13. Respuesta corta para defenderlo
1. "Aleatorio de 6 caracteres más fecha, verificado contra la BD antes de guardar y con restricción UNIQUE en la tabla."
2. "Recibo 403: comparo el dueño del pedido con el usuario autenticado."
3. "Sí: desde Mi cuenta → Pedidos ve el detalle con su tracking y estado."

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
