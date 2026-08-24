# Punto 29 - Pregunta docente 1 (banco de preparación)

## 1. ¿Qué pide la profesora?
Responder correctamente UNA pregunta sorpresa durante la defensa. No verificable por código: se prepara con anticipación.

## 2. Estado actual
NO VERIFICABLE SOLO CON EL CÓDIGO

## 3-4. Banco GRUPO 1 — ARQUITECTURA Y FLUJO GENERAL (basado SOLO en tu código real)
Ver también el banco maestro completo: `docs/PREGUNTAS_Y_RESPUESTAS_DEFENSA.md`

1. **"Explícame el recorrido completo cuando un usuario compra."**
   R: "Checkout valida dirección+método+token anti-doble-envío → abre DB::transaction → releo productos con lockForUpdate verificando active y stock → CartCalculator recalcula subtotal/IVA13%/envío3000 → creo Order con tracking SWCR único → inserto OrderItems congelando nombre/precio → decremento stock → creo Payment pending → vacío carrito → redirect a confirmación con 403 si no eres dueño."

2. **"¿Por qué tu total del carrito podría diferir del cobrado?"**
   R: "Nunca difiere: el carrito solo MUESTRA; el cobro se RECALCULA server-side dentro de la transacción desde precios reales de la BD."

3. **"¿Qué pasa si dos usuarios compran la última unidad al mismo tiempo?"**
   R: "lockForUpdate bloquea la fila del producto dentro de la transacción: el segundo espera, encuentra stock insuficiente y recibe error limpio. Test CheckoutTest::test_no_se_puede_comprar_si_no_hay_suficiente_inventario."

4. **"¿Cómo evitas pedidos duplicados por doble clic?"**
   R: "Token aleatorio de 32 chars generado al abrir checkout, guardado en sesión y comparado con hash_equals; session()->pull lo consume una vez. CheckoutIdempotencyTest lo prueba."

5. **"MVC en TU proyecto, con archivos."**
   R: "Vistas Blade en resources/views; Controladores en app/Http/Controllers (CheckoutController etc.); Modelos app/Models (Order con relaciones); extra: Service CartCalculator para reglas de dinero."

## 5. Qué buscar en VS Code
`DB::transaction`, `lockForUpdate`, `hash_equals`

## 6. Fragmento importante
```php
$sessionToken = session()->pull('checkout_token');
if ($sessionToken === null || ! hash_equals($sessionToken, $data['checkout_token'])) { ... }
```

## 7. Explicación sencillo
Este grupo pregunta CÓMO PIENSAS: flujo end-to-end y defensas de concurrencia. Memoriza la cadena checkout→transacción→tracking y sus tests asociados.

## 8-9. Recorrido/prueba
Ensayar respondiendo EN VOZ ALTA mientras muestras cada archivo citado.

## 10. Evidencia
Mostrar CheckoutController@store mientras respondes: la respuesta gana credibilidad al señalar el código.

## 11. Test relacionado
CheckoutIdempotencyTest, CheckoutTest.

## 12. ¿Qué podría preguntarme la profesora?
Las 5 de arriba son el grupo 1 exacto.

## 13. Respuesta corta para defenderlo
Incluidas arriba.

## 14. Problemas encontrados
Ninguno; riesgo = improvisar sin repasar.

## 15. ¿Qué falta?
Estudiar este banco + banco maestro (30 min).
