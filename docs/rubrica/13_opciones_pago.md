# Punto 13 - Opciones de pago (tarjeta, PayPal) y pasarela segura

## 1. ¿Qué pide la profesora?
Opciones de pago reales durante el proceso de compra, idealmente con pasarela integrada que procese TRANSACCIONES SEGURAS (sandbox/API/capture/transaction_id/webhook).

## 2. Estado actual
FUNCIONA CON DEFICIENCIAS

## 3. ¿Qué encontraste? (auditoría estricta, separada por método)
COMÚN A AMBOS:
- Checkout valida `payment_method` con `in:card,paypal` y crea SIEMPRE un registro Payment con `status='pending'`, `transaction_id=null`, `paid_at=null`. Comentario en el código: "Pago local de demostración. Más adelante esta parte se sustituye por una respuesta real de Stripe/PayPal sandbox."
- La orden SÍ se crea completa (transacción, stock, tracking) y queda visible con estado de pago pendiente.

TARJETA:
- Radio button funcional que guarda method='card'. **NO procesa cobros**: no hay Stripe SDK, ni formulario PCI, ni autorización. Es registro local demo.

PAYPAL:
- Radio button que guarda method='paypal'. **NO hay integración**: sin SDK (`composer.json` no tiene paquete paypal), sin `config/paypal.php` (verificado: no existe), sin `app/Services/PayPalService.php` (no existe), sin JS SDK en la vista, sin redirect/approve/capture, sin webhook/callback.
- README.md menciona variables PAYPAL_SANDBOX_* y flujo de capture, pero ese texto describe una implementación PLANIFICADA/no versionada — el código actual no la contiene. RIESGO: contradicción README vs código si la profesora lo prueba.

## 4. ¿Dónde se encuentra?
- Validación método: `CheckoutController@store` línea ~70–73 (`'in:card,paypal'`)
- Creación pago demo: `CheckoutController@store` líneas ~166–178
- Migración: `2026_07_29_034409_create_payments_table.php` (order_id, method, status, transaction_id, amount, paid_at)
- Modelo: `app/Models/Payment.php`
- Vista selector: `resources/views/checkout/index.blade.php`
- Tests: `tests/Feature/PaymentTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `'in:card,paypal'`
- `'status' => 'pending'`
- `'transaction_id' => null`
- `Pago local de demostración`
- `Payment::create`

## 6. Fragmento importante
```php
// Pago local de demostración...
Payment::create([
    'order_id'     => $order->id,
    'method'       => $data['payment_method'],
    'status'       => 'pending',
    'transaction_id' => null,
    'amount'       => $total,
    'paid_at'      => null,
]);
```

## 7. Explicación sencilla
El sistema deja elegir tarjeta o PayPal y registra esa elección en una tabla payments ligada al pedido, en estado pendiente. Es honesto decirlo así: la estructura de pagos EXISTE y está bien modelada (method/status/transaction_id/amount/paid_at listos para una pasarela), pero ninguna pasarela externa está conectada todavía — ningún dinero se mueve ni hay transaction_id de terceros. La compra termina igual y el seguimiento del pedido funciona.

## 8. Recorrido del sistema
checkout/index.blade.php (radio card/paypal) → POST /checkout → validación in:card,paypal → DB::transaction → Payment::create pending → success muestra "Pago: pendiente".

## 9. ¿Cómo lo pruebo?
1. Checkout → elegir Tarjeta → confirmar → detalle muestra método card, pago pendiente.
2. Repetir eligiendo PayPal → method='paypal'.
3. BD: tabla payments con status=pending y transaction_id vacío.
4. Mostrar composer.json sin SDKs de pago (transparencia).

## 10. ¿Qué evidencia puedo enseñarle?
Selector funcionando, tabla payments poblada, PaymentTest verde, y explicar el diseño preparado para conectar una pasarela (columnas ya previstas).

## 11. Test relacionado
Archivo: `tests/Feature/PaymentTest.php`
Nombres: `test_el_checkout_crea_un_pago_en_estado_pendiente`, `test_se_puede_actualizar_el_estado_de_un_pago`, `test_el_pago_pertenece_al_pedido_correcto`.
TEST FALTANTE: test de integración PayPal sandbox (requeriría el SDK/integración).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿PayPal realmente cobra en este proyecto?
2. ¿Y la tarjeta qué procesa?
3. ¿Qué te falta para conectar PayPal Sandbox?
4. ¿Por qué guardas el pago como pending?

## 13. Respuesta corta para defenderlo
1. "No todavía: hoy registra la intención de pago en estado pendiente; la integración con PayPal Sandbox está planificada y documentada en el roadmap."
2. "Tampoco procesa: es modo demostración local; evitamos simular cobros falsos."
3. "Instalar el SDK oficial, crear servicio con OAuth→createOrder→capture, rutas de retorno/cancelación y webhook; la estructura de la tabla payments ya lo soporta."
4. "Porque refleja la verdad del flujo actual: el pedido existe pero ningún proveedor ha capturado dinero; cuando haya pasarela, el capture actualizará status, transaction_id y paid_at."

## 14. Problemas encontrados
- Ninguna pasarela real conectada (tarjeta y PayPal son selección + registro local).
- README.md (modificado, sin commitear) describe PayPal Sandbox como si ya estuviera activo → contradicción con el código versionado.

## 15. ¿Qué falta para obtener los 3 puntos?
Integrar una pasarela real en sandbox (PayPal Orders API: token→createOrder→redirect approve→capture→status paid + transaction_id + paid_at, con rutas return/cancel y test). Alternativa mínima defendible: documentar explícitamente en README/defensa que el cobro es demo y mostrar la estructura lista para producción.
