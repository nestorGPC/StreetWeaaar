# Punto 10 - Carrito: agregar, eliminar y actualizar

## 1. ¿Qué pide la profesora?
Que el carrito permita agregar productos, eliminarlos y actualizar cantidades, respetando stock y validando cantidades — incluyendo el comportamiento con productos inactivos.

## 2. Estado actual
FUNCIONA CON DEFICIENCIAS

## 3. ¿Qué encontraste?
Implementación por sesión (`session('cart')`) en `CartController`:
- `add`: bloquea stock <= 0, bloquea superar stock al acumular, guarda id/name/price/quantity/image. **DEFICIENCIA: NO verifica `$product->active`** → un POST directo a `/carrito/agregar/{id}` de un producto INACTIVO (oculto del catálogo) sí entra al carrito.
- `update`: SÍ verifica active + valida quantity required|integer|min:1|max:{stock}.
- `remove`: elimina por id si existe.
- El checkout además revalida todo contra la BD (active + stock) dentro de la transacción, así un inactivo agregado trampa NUNCA se puede comprar.

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/CartController.php` (métodos add/update/remove/index)
- Vista: `resources/views/cart/index.blade.php`
- Rutas: POST `/carrito/agregar/{product}`, PUT `/carrito/actualizar/{product}`, DELETE `/carrito/eliminar/{product}` (routes/web.php líneas 45–52)
- Test: `tests/Feature/CartTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `public function add(Product $product)`
- `$product->stock <= 0`
- `'max:' . $product->stock`
- `if (! $product->active)`
- `unset($cart[$product->id])`

## 6. Fragmento importante
```php
public function update(Request $request, Product $product)
{
    if (! $product->active) {
        return back()->with('error', 'Este producto ya no está disponible.');
    }

    $request->validate([
        'quantity' => ['required', 'integer', 'min:1', 'max:' . $product->stock],
    ]);
```

## 7. Explicación sencilla
El carrito vive en la sesión del usuario como un arreglo indexado por id de producto; no toca la BD hasta comprar. Al agregar reviso que haya stock; al actualizar valido que la cantidad sea entera entre 1 y el stock real; al eliminar saco la clave del arreglo. La brecha: en "agregar" olvidé preguntar si el producto está activo — solo lo pregunto al actualizar y al comprar. Como el checkout rechaza inactivos, el impacto es bajo, pero técnicamente es una validación faltante en el punto exacto que pide la rúbrica.

## 8. Recorrido del sistema
Botón "Agregar" → POST /carrito/agregar/{id} → CartController@add → valida stock → session cart → redirect /carrito → vista con totales. Actualizar → PUT → validate max stock → session. Eliminar → DELETE → unset → session.

## 9. ¿Cómo lo pruebo?
1. Agregar producto → aparece con cantidad 1.
2. Agregar de nuevo → cantidad sube sin pasar el stock.
3. Cambiar cantidad a número mayor que stock → error de validación.
4. Eliminar → desaparece.
5. Producto agotado → botón/bloqueo con mensaje "agotado".
6. (Caso fino) Desactivar un producto en admin con carrito lleno → intentar actualizar → error "ya no está disponible"; e intentar pagar → el checkout lo rechaza.

## 10. ¿Qué evidencia puedo enseñarle?
Carrito operando en vivo, CartTest completo en verde (7 pruebas), código de add/update/remove.

## 11. Test relacionado
Archivo: `tests/Feature/CartTest.php`
Nombres: `test_se_puede_agregar_un_producto_al_carrito`, `test_no_se_puede_agregar_un_producto_agotado`, `test_no_se_puede_superar_el_stock_disponible_al_agregar`, `test_se_puede_actualizar_la_cantidad_de_un_producto`, `test_no_se_puede_actualizar_la_cantidad_por_encima_del_stock`, `test_no_se_puede_actualizar_un_producto_inactivo`, `test_se_puede_eliminar_un_producto_del_carrito`.
TEST FALTANTE: agregar producto INACTIVO vía add() (documentaría la deficiencia).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Dónde vive el carrito, en BD o sesión? ¿Por qué?
2. ¿Qué pasa si dos pestañas modifican el mismo carrito?
3. ¿Cómo garantizas no vender más del stock?

## 13. Respuesta corta para defenderlo
1. "En sesión: es temporal y por usuario; la BD se toca solo al confirmar el pedido."
2. "La sesión es por cookie; cada pestaña comparte su sesión del navegador y la última escritura gana."
3. "Tres capas: límite al agregar, max:stock al actualizar, y lockForUpdate+revalidación en la transacción de compra."

## 14. Problemas encontrados
- `add()` permite agregar un producto inactivo mediante petición directa (falta chequeo `$product->active`; update() y checkout sí lo bloquean).

## 15. ¿Qué falta para obtener los 3 puntos?
Añadir en `add()` (después del chequeo de stock):
```php
if (! $product->active) {
    return back()->with('error', 'Este producto ya no está disponible.');
}
```
más un test equivalente al de update. Es un cambio de ~5 líneas (pendiente de aprobación del usuario).
