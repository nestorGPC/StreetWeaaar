# Punto 20 - Mostrar los productos vistos recientemente al usuario

## 1. ¿Qué pide la profesora?
MOSTRAR al usuario los últimos productos visitados mientras navega la tienda (la lectura/mostrado — distinto del punto 19 que es guardar la cookie).

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
En `ProductController@show`, después de actualizar la cookie, se consultan los productos recientes EXCLUYENDO el actual:
- `$viewedIds` = IDs de la cookie sin el producto actual.
- Consulta: `Product::with('category')->where('active', true)->whereIn('id', $viewedIds)` → solo productos ACTIVOS existentes.
- Se reordena en PHP con `sortBy(array_search(...))` para conservar el orden de recencia de la cookie (whereIn no garantiza orden).
- Se pasan a la vista como `$recentProducts`; `products/show.blade.php` los renderiza en una sección "Vistos recientemente" con las mismas cards del catálogo.
- Si la cookie está vacía o los productos fueron desactivados, la sección simplemente no muestra nada (sin errores).

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/ProductController.php` → `show()` líneas ~125–155
- Vista: `resources/views/products/show.blade.php` (sección recientes)
- Test: `tests/Feature/RecentProductsTest.php` (complementa)

## 5. ¿Qué buscar en VS Code?
Buscar:
- `$recentProducts = Product::with('category')`
- `whereIn('id', $viewedIds)`
- `array_search(` (dentro de ProductController)
- `recentProducts` (en la vista show)

## 6. Fragmento importante
```php
$recentProducts = Product::with('category')
    ->where('active', true)
    ->whereIn('id', $viewedIds)
    ->get()
    ->sortBy(fn ($p) => array_search($p->id, $viewedIds))
    ->values();
```

## 7. Explicación sencillo
De la cookie ya tengo hasta 5 IDs. Le quito el producto que estoy viendo para no recomendar lo mismo, pregunto a la BD cuáles existen Y están activos (si uno se desactivó, desaparece solo), y luego reordeno los resultados según la posición de cada ID en la cookie —porque SQL no respeta el orden del whereIn—. La vista pinta esa colección igual que las cards del catálogo.

## 8. Recorrido del sistema
Cookie recent_products → ProductController@show → filtro/orden → SQLite products → $recentProducts → products/show.blade.php sección "Vistos recientemente".

## 9. ¿Cómo lo pruebo?
1. Ver producto A, luego B, luego C.
2. Abrir C → la sección muestra B y A (NO repite C).
3. Desactivar A en admin → al recargar, A desaparece de recientes.
4. Navegador limpio (sin cookie) → sección vacía sin errores.

## 10. ¿Qué evidencia puedo enseñarle?
Navegación real mostrando la sección actualizándose, el bloque de código del controlador, la vista Blade de la sección.

## 11. Test relacionado
Archivo: `tests/Feature/RecentProductsTest.php` (validan la parte de datos/cookie que alimenta el mostrado). Test visual específico del render: cubierto indirectamente por feature tests; demostración en vivo.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué excluyes el producto actual?
2. ¿Por qué el sortBy después del get()?
3. ¿Qué pasa si un ID de la cookie ya no existe?

## 13. Respuesta corta para defenderlo
1. "Para mostrar descubrimiento, no repetición: ya estás viendo ese producto."
2. "whereIn no devuelve filas en el orden de la lista; reordeno según la posición del ID en la cookie."
3. "whereIn simplemente no lo trae; nunca rompe."

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
