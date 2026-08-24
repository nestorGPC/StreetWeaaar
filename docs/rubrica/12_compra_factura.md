# Punto 12 - Tabla compra/factura (usuario, fecha, monto)

## 1. ¿Qué pide la profesora?
Una tabla que registre CADA COMPRA identificando quién compró (usuario), cuándo (fecha) y por cuánto (monto). "Compra o factura": basta el registro persistente; PDF de factura es opcional.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
La tabla `orders` cumple todos los campos exigidos:
- `user_id` (FK a users) = identificación del comprador
- `created_at` (timestamp automático) = fecha de compra
- `subtotal`, `tax`, `shipping`, `total` = montos completos
- `tracking_number` único, `status`, `shipping_address`
Relaciones: Order belongsTo User; hasMany OrderItem; hasOne Payment. Los ítems congelan product_name/price/subtotal (histórico aunque cambie el producto).
**Factura PDF individual: NO existe** (no se exige: la rúbrica dice "tabla compra O factura"). Lo que sí hay son reportes PDF admin por pedidos/ventas/productos.

## 4. ¿Dónde se encuentra?
- Migración: `database/migrations/2026_07_29_034406_create_orders_table.php`
- Modelo: `app/Models/Order.php` (relaciones user/items/payment)
- Creación: `CheckoutController@store` → `Order::create([...])`
- Vistas de consumo: `account/orders.blade.php`, `account/order-detail.blade.php`, `checkout/success.blade.php`
- Tests: `tests/Feature/CheckoutTest.php`, `OrderTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `create_orders_table`
- `$table->foreignId('user_id')`
- `'tracking_number'`
- `Order::create([`
- `class Order extends Model`

## 6. Fragmento importante
```php
$order = Order::create([
    'user_id' => $request->user()->id,
    'tracking_number' => $trackingNumber,
    'status' => 'pending',
    'subtotal' => $subtotal,
    'tax' => $tax,
    'shipping' => $shipping,
    'total' => $total,
    'shipping_address' => $data['shipping_address'],
]);
```

## 7. Explicación sencilla
Cuando el cliente confirma la compra, dentro de una transacción creo UNA fila en orders con quién (user_id), cuándo (created_at automático), cuánto (los cuatro montos), hacia dónde (dirección) y un código de seguimiento único. Las líneas de cada producto van a order_items y el intento de pago a payments. Esa fila es LA factura electrónica interna del sistema: es lo que el cliente ve en su historial y lo que alimentan los reportes.

## 8. Recorrido del sistema
POST /checkout → transacción → orders (cabecera) + order_items (líneas) + payments (pago) + decremento de stock → SQLite → consultado por account.orders, checkout.success y ReportController (PDFs).

## 9. ¿Cómo lo pruebo?
1. Hacer una compra → verla en /mi-cuenta/pedidos con fecha y total.
2. Abrir la BD (DB Browser for SQLite) → tabla orders con user_id, created_at, subtotal/tax/shipping/total, tracking_number.
3. Verificar order_items ligados por order_id y payments por order_id.

## 10. ¿Qué evidencia puedo enseñarle?
Tabla orders abierta en DB browser mostrando usuario, fecha y monto de compras reales; el modelo Order con sus relaciones; historial del cliente en vivo.

## 11. Test relacionado
Archivo: `tests/Feature/CheckoutTest.php`
Nombre: `test_un_cliente_puede_completar_el_checkout` (valida creación completa de la orden). Complementos en `tests/Feature/OrderTest.php`: `test_un_cliente_puede_ver_sus_propios_pedidos`.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué order_items guarda name y price si ya están en products?
2. ¿Qué pasa con las órdenes si se borra un usuario?
3. ¿Existe factura PDF para el cliente?

## 13. Respuesta corta para defenderlo
1. "Para congelar el histórico: si mañana cambia el nombre o precio del producto, la compra vieja conserva sus datos originales."
2. "user_id es FK; según configuración de integridad quedaría huérfana o se impediría el borrado; los reportes muestran 'Cliente eliminado'."
3. "No individual: el requisito pide tabla o factura; cumplimos con la tabla orders. Tenemos PDFs administrativos de reportes."

## 14. Problemas encontrados
Ninguno funcional.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
