# Punto 9 - Búsqueda y filtrado de productos (nombre, categoría, precio)

## 1. ¿Qué pide la profesora?
Que la tienda permita buscar por nombre y filtrar por categoría y por rango de precio, incluyendo COMBINACIONES de filtros a la vez.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
En `ProductController@index` hay CUATRO filtros independientes que se acumulan sobre el mismo query builder:
1. `search` → `WHERE name LIKE %...%`
2. `category` → busca la Category y agrega `WHERE category_id = ?`
3. `min_price` → `WHERE price >= ?` (solo si es numérico y >= 0)
4. `max_price` → `WHERE price <= ?`
Como todos aplican sobre `$query`, cualquier combinación funciona (ej: categoría + precio). Siempre parte de `where('active', true)` y eager loading `with('category')`.

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/ProductController.php` → `index()` (líneas 12–69)
- Vista: `products/index.blade.php` (formulario GET de filtros)
- Ruta: GET `/productos`
- Modelo: `app/Models/Product.php`, `app/Models/Category.php`
- Test: `tests/Feature/ProductCatalogTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `$request->filled('search')`
- `'like', '%' . $request->search . '%'`
- `$request->filled('min_price')`
- `is_numeric($request->min_price)`
- `where('price', '>=',`

## 6. Fragmento importante
```php
if ($request->filled('min_price')
    && is_numeric($request->min_price)
    && $request->min_price >= 0) {
    $query->where('price', '>=', $request->min_price);
}
```

## 7. Explicación sencilla
No ejecuto una consulta por filtro: voy CONSTRUYENDO una sola consulta. Empiezo con "solo activos" y cada filtro que llega lleno en la URL añade una condición WHERE más. Al final Laravel arma el SQL combinado. Eso hace que buscar "camisa" + categoría Ropa + máximo 25000 funcione como intersección de las tres condiciones. El `is_numeric` evita que alguien escriba texto en el precio y rompa la consulta.

## 8. Recorrido del sistema
Formulario GET en products/index → URL `/productos?search=camisa&category=1&max_price=25000` → ProductController@index → Query Builder → SQLite products+categories → products/index.blade.php con resultados.

## 9. ¿Cómo lo pruebo?
1. /productos y escribir "tenis" en búsqueda → solo tenis.
2. Seleccionar categoría "Gorras" → solo gorras.
3. Precio mínimo 5000 y máximo 15000 → solo ese rango.
4. Combinar búsqueda + categoría + rango → resultados que cumplen TODO.
5. Escribir "abc" en el campo precio → se ignora sin error.

## 10. ¿Qué evidencia puedo enseñarle?
Filtros combinados en vivo con la URL visible mostrando los parámetros, y el método index completo en pantalla.

## 11. Test relacionado
Archivo: `tests/Feature/ProductCatalogTest.php`
Nombres y qué validan:
- `test_el_catalogo_permite_buscar_productos_por_nombre`
- `test_el_catalogo_permite_filtrar_por_categoria`
- `test_el_catalogo_permite_filtrar_por_rango_de_precio`

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Cómo haces que varios filtros funcionen juntos?
2. ¿Qué tipo de consulta genera el LIKE?
3. ¿Es vulnerable a SQL Injection esta búsqueda?

## 13. Respuesta corta para defenderlo
1. "Todos los filtros agregan condiciones al mismo query builder antes de traer resultados."
2. "Un WHERE name LIKE '%texto%' en SQLite."
3. "No: los valores van parametrizados (bindings), nunca concatenados al SQL."

## 14. Problemas encontrados
Ninguno funcional. (Mejora opcional: paginación si crece el catálogo.)

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
