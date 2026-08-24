# Punto 28 - Calidad del código y buenas prácticas

## 1. ¿Qué pide la profesora?
MVC bien aplicado, responsabilidades claras, nombres coherentes, transacciones, relaciones correctas, seguridad y consistencia — juzgado a escala de proyecto universitario.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
- MVC limpio: controladores delgados orquestan; lógica de negocio en Services (`CartCalculator`); persistencia en Modelos Eloquent con relaciones declaradas (User hasMany Order, Order hasMany OrderItem/hasOne Payment, Product belongsTo Category).
- Robustez real de ingeniería: checkout envuelto en `DB::transaction` + `lockForUpdate` (sin sobreventa) + token de idempotencia con `hash_equals` (anti doble-POST) + recálculo server-side de montos.
- Nombres consistentes en español descriptivo (métodos Y tests: test_no_se_puede_superar_el_stock_disponible_al_agregar).
- Comentarios donde aportan (intención de idempotencia, cookie de recientes), ausencia de código muerto detectado.
- Validación sistemática en cada controlador; autorización explícita; errores de dominio como RuntimeException capturados con feedback al usuario.
- Duplicación menor identificada y documentada (Punto 11): CartController@index repite inline el cálculo que CartCalculator centraliza (mismos valores hoy).
- Suite de tests como red de calidad: 41/129 verdes ejecutados hoy.

## 4. ¿Dónde se encuentra?
- Service: `app/Services/CartCalculator.php`
- Transacción: `CheckoutController@store`
- Relaciones: `app/Models/*.php`
- Estructura: `app/Http/Controllers` (6 controllers), `app/Filament/Resources` (admin)

## 5. ¿Qué buscar en VS Code?
Buscar:
- `DB::transaction(`
- `lockForUpdate`
- `hash_equals(`
- `class CartCalculator`
- `hasMany(` (en Models)

## 6. Fragmento importante
```php
$order = DB::transaction(function () use ($request, $data, $cart) {
    $product = Product::query()->lockForUpdate()->find($item['id']);
    if (! $product || ! $product->active) {
        throw new RuntimeException('Uno de los productos ya no está disponible.');
    }
    ...
});
```

## 7. Explicación sencillo
Cada pieza hace UNA cosa: la ruta decide, el controlador valida y coordina, el servicio calcula, el modelo persiste. Lo más fino está en checkout: abro transacción, BLOQUEO la fila del producto mientras verifico stock (otra petición simultánea espera), lanzo excepciones si algo cambió, creo orden+ítems+pago juntos o nada, y uso un token de un solo uso para que un doble clic no genere dos pedidos. Eso es calidad medible, no cosmética.

## 8. Recorrido del sistema
Request → Controller (valida/autoriza) → Service (dominio) → Model (datos) → SQLite dentro de transacción → respuesta consistente.

## 9. ¿Cómo lo pruebo?
1. Mostrar estructura de carpetas app/.
2. Abrir CheckoutController@store y explicar las 4 defensas.
3. Ejecutar CheckoutIdempotencyTest en verde.
4. Grep de DB::raw → cero (consistencia).

## 10. ¿Qué evidencia puedo enseñarle?
Arquitectura en pantalla, test de idempotencia verde, comparación de totales BD vs vista (consistencia), nombres legibles del código.

## 11. Test relacionado
`tests/Feature/CheckoutIdempotencyTest.php`: `test_un_doble_post_no_crea_dos_pedidos`, `test_el_checkout_rechaza_un_token_invalido`.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué lockForUpdate?
2. ¿Qué es inyección de dependencias y dónde la usas?
3. ¿Encontraste duplicación en tu código?

## 13. Respuesta corta para defenderlo
1. "Para que dos compras concurrentes del último inventario no vendan la misma unidad: la fila queda bloqueada hasta el commit."
2. "CheckoutController recibe CartCalculator por constructor; facilita pruebas y desacopla."
3. "Una menor y reconocida: la vista del carrito recalcula totales inline en vez de usar CartCalculator; mismos valores, candidata a refactor."

## 14. Problemas encontrados
- Duplicación benigna del cálculo en CartController@index (documentada en Punto 11).
- Ningún código muerto relevante encontrado.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente. (Refactor opcional de 3 líneas: usar CartCalculator también en cart.index.)
