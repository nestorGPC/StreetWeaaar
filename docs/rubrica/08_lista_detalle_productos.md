# Punto 8 - Lista y detalle de productos

## 1. ¿Qué pide la profesora?
Una lista de productos con sus datos (nombre, descripción, precio, imagen…) y una página individual por producto con todo el detalle.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
Lista `/productos`: cards con imagen (desde storage), nombre, categoría, precio formateado y estado de stock/agotado; solo activos. Detalle `/productos/{product}` (route model binding): foto grande, descripción completa, precio, stock disponible, categoría y botón "Agregar al carrito". Imágenes seed `.jpg` incluidas en el repo y servidas correctamente en hosting (verificado hoy: `/storage/products/seed/camiseta-oversize.jpg` → 200).

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/ProductController.php` → `index()` y `show()`
- Vistas: `resources/views/products/index.blade.php` y `products/show.blade.php`
- Rutas: GET `/productos` y GET `/productos/{product}`
- Migración: `create_products_table` (name, description, price decimal, stock, image, active)
- Modelo: `app/Models/Product.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `asset('storage/' . $product->image)`
- `where('active', true)`
- `public function show(Product $product)`
- `'description'` (migración products)

## 6. Fragmento importante
```php
public function show(Product $product)
{
    $product->load('category');
    // ... lógica de cookie recent_products ...
    return view('products.show', compact('product', 'recentProducts'));
}
```

## 7. Explicación sencilla
El listado pregunta solo productos activos y arma cards con lo mínimo. Cuando haces clic, Laravel convierte el {product} de la URL automáticamente en el modelo desde la BD (route model binding); si no existe, 404 automático. La imagen vive en storage/app/public y se expone por el symlink public/storage.

## 8. Recorrido del sistema
Card en index → enlace /productos/3 → ProductController@show → Product find + category + cookie → SQLite → products/show.blade.php.

## 9. ¿Cómo lo pruebo?
1. /productos → verificar datos visibles en cada card.
2. Clic en un producto → detalle completo.
3. URL inventada /productos/999 → página 404 personalizada.
4. Ver imagen cargando desde /storage/... en la barra de redes.

## 10. ¿Qué evidencia puedo enseñarle?
Las dos pantallas en vivo, la tabla products abierta, carpeta storage/app/public/products.

## 11. Test relacionado
Archivo: `tests/Feature/ProductCatalogTest.php`
Nombre: `test_se_puede_ver_el_detalle_de_un_producto`

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Qué es route model binding?
2. ¿Por qué imágenes fuera de la BD?
3. ¿Cómo ocultas un producto sin borrarlo?

## 13. Respuesta corta para defenderlo
1. "Laravel resuelve {product} a un registro real o devuelve 404 solo."
2. "La BD guarda la ruta; el archivo vive en storage. Más liviano y estándar."
3. "Con el flag active=false desaparece del catálogo y no se puede comprar."

## 14. Problemas encontrados
Ninguno (imágenes verificadas OK en producción hoy).

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
