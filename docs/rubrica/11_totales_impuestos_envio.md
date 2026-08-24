# Punto 11 - Total automático con impuestos y envío

## 1. ¿Qué pide la profesora?
Cálculo AUTOMÁTICO del total incluyendo subtotal, IVA (impuesto con porcentaje definido) y costo de envío; y que el cálculo sea CONSISTENTE entre carrito, checkout, order y payment.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
- Servicio centralizado `App\Services\CartCalculator`: `subtotal()` = Σ precio×cantidad; `tax()` = subtotal × **0.13** (IVA CR); `shipping()` = **₡3 000 fijo** si hay productos, gratis si el carrito está vacío; `total()` = subtotal + tax + shipping.
- CheckoutController usa ESTE servicio vía inyección por constructor y recalcula TODO desde precios de la BD dentro de la transacción (no confía en la sesión).
- Order guarda subtotal/tax/shipping/total; Payment guarda amount = total. Consistente.
- Único matiz: `CartController@index` recalcula inline con los mismos valores (13%, 3000) en lugar de llamar al servicio — mismos números, pero lógica duplicada (nota de calidad, no de consistencia).

## 4. ¿Dónde se encuentra?
- Servicio: `app/Services/CartCalculator.php`
- Uso principal: `CheckoutController@store` (inyectado en constructor)
- Duplicación benigna: `CartController@index` líneas 14–24
- Persistencia: migración `create_orders_table` (columnas subtotal, tax, shipping, total) y `create_payments_table` (amount)
- Tests: `tests/Feature/CheckoutTest.php`, `PaymentTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `class CartCalculator`
- `$subtotal * 0.13`
- `3000`
- `private CartCalculator $cartCalculator`
- `$this->cartCalculator->total($subtotal)`

## 6. Fragmento importante
```php
public function tax(float $subtotal): float
{
    return $subtotal * 0.13;
}

public function shipping(float $subtotal): float
{
    return $subtotal > 0 ? 3000 : 0;
}
```

## 7. Explicación sencilla
Tengo UNA clase responsable de la matemática del dinero. El subtotal es la suma de precio por cantidad de cada línea. El IVA costarricense es 13% del subtotal. El envío cuesta ₡3 000 fijos siempre que haya algo que enviar. El total suma los tres. En checkout recalculo todo desde la BD dentro de la transacción para que nadie manipule precios desde el navegador, y esos números exactos quedan guardados en la orden y en el pago.

## 8. Recorrido del sistema
/cart → CartController@index calcula y muestra. POST /checkout → CheckoutController@store → DB::transaction → lee productos con lockForUpdate → CartCalculator (tax/shipping/total) → SQLite orders + payments → vista success mostrando el desglose guardado.

## 9. ¿Cómo lo pruebo?
1. Carrito con ₡10 000 → IVA 1 300 + envío 3 000 = total 14 300.
2. Confirmar pedido → la confirmación muestra EXACTAMENTE los mismos números.
3. Abrir SQLite → fila en orders con subtotal=10000, tax=1300, shipping=3000, total=14300 y payments.amount igual.
4. Comparar carrito vs confirmación vs BD: idénticos.

## 10. ¿Qué evidencia puedo enseñarle?
CartCalculator completo en pantalla, desglose en vivo del checkout, fila de orders/payments abierta en DB browser mostrando los mismos valores.

## 11. Test relacionado
Archivo: `tests/Feature/CheckoutTest.php`
Nombre: `test_un_cliente_puede_completar_el_checkout` (valida que la orden se crea con los totales correctos). Complementario: `tests/Feature/PaymentTest.php::test_el_checkout_crea_un_pago_en_estado_pendiente` (amount = total).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿De dónde sale el 13%?
2. ¿Si mañana el envío cambia, cuántos archivos toco?
3. ¿Por qué recalculas en el servidor si el total ya venía del formulario?

## 13. Respuesta corta para defenderlo
1. "El IVA de Costa Rica: 13% sobre el subtotal."
2. "Solo CartCalculator; el resto del sistema lo consume."
3. "Nunca confío en montos del cliente: recalculo desde precios de la BD dentro de la transacción para evitar manipulación."

## 14. Problemas encontrados
- Duplicación menor: CartController@index repite la fórmula inline en vez de usar CartCalculator (valores idénticos hoy; riesgo solo si cambian reglas y se edita un lado).

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente. (Mejor opcional: que cart.index use CartCalculator.)
