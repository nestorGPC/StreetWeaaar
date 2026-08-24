# Punto 7 - Catálogo de productos por categorización

## 1. ¿Qué pide la profesora?
Que los productos estén organizados por categorías y que la tienda refleje esa organización (relaciones + filtro + vista).

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
Relación uno-a-muchos Category↔Product (`category_id` FK). El catálogo carga productos activos con eager loading `with('category')` (evita N+1), muestra la categoría en cada card y filtra por ella. CRUD completo de categorías en Filament `/admin/categories` (hoy operativo tras asignar permisos Shield). 4 categorías sembradas: Ropa, Tenis, Gorras, Accesorios.

## 4. ¿Dónde se encuentra?
- Modelos: `app/Models/Category.php`, `app/Models/Product.php`
- Controlador: `ProductController@index`
- Vista: `products/index.blade.php`
- Ruta: GET `/productos`
- Migraciones: `2026_07_25_223112_create_categories_table.php`, `...223120_create_products_table.php`
- Seeder: `CategorySeeder.php`
- Admin: `app/Filament/Resources/Categories/`
- Test: `tests/Feature/ProductCatalogTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `class Category extends Model`
- `public function category()`  (en Product)
- `with('category')`
- `where('category_id', $category->id)`
- `CategorySeeder`

## 6. Fragmento importante
```php
$query = Product::with('category')->where('active', true);
...
if ($request->filled('category')) {
    $category = Category::find($request->category);
    if ($category) {
        $query->where('category_id', $category->id);
    }
}
```

## 7. Explicación sencilla
Cada producto apunta a su categoría con category_id (llave foránea). Al listar, pido productos Y sus categorías en dos consultas (eager loading), no una consulta por producto. Si llega ?category=3 en la URL, agrego un where más al query builder antes de traer resultados.

## 8. Recorrido del sistema
/products?category=2 → ProductController@index → Product with(Category) → SQLite products JOIN categories → products/index.blade.php con cards agrupadas/filtradas.

## 9. ¿Cómo lo pruebo?
1. /productos → ver badge de categoría en cada card.
2. Seleccionar categoría "Tenis" → solo tenis.
3. Combinar con búsqueda "gorra" y precio → resultados combinados.
4. En /admin/categories crear una categoría nueva y verificarla en tienda.

## 10. ¿Qué evidencia puedo enseñarle?
Catálogo filtrado en vivo, diagrama de relación en phpMyAdmin/DB browser, CRUD admin creando categoría.

## 11. Test relacionado
Archivo: `tests/Feature/ProductCatalogTest.php`
Nombre: `test_el_catalogo_permite_filtrar_por_categoria`

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Qué tipo de relación es?
2. ¿Qué es eager loading y qué evita?
3. ¿Dónde defino la FK?

## 13. Respuesta corta para defenderlo
1. "Uno a muchos: una categoría tiene muchos productos."
2. "Traer las relaciones en pocas consultas; evita el problema N+1 (una query extra por producto)."
3. "En la migración de products: foreignId('category_id') con constrained()."

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
