# Punto 19 - Cookies en productos vistos recientemente

## 1. ¿Qué pide la profesora?
USAR cookies para recordar los productos vistos recientemente: nombre de cookie, dónde se crea, duración, contenido y máximo de productos.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
Todo definido y verificable en `ProductController@show`:
- Nombre: **`recent_products`**
- Contenido: JSON array de IDs `[3,7,12]`
- Dónde se crea: al VER un producto (show), vía `Cookie::queue(...)`
- Duración: **30 días** (minutos: 60*24*30)
- Máximo: **5 productos** (`array_slice(..., 0, 5)`)
- Lógica robusta: decodifica JSON (si viene corrupto usa []), elimina duplicado del actual, inserta el nuevo AL INICIO (más reciente primero).
- Tests dedicados cubren creación, acumulación y límite.

## 4. ¿Dónde se encuentra?
- Controlador: `app/Http/Controllers/ProductController.php` → `show()` líneas ~76–123
- Lectura de la cookie: mismo método (`request()->cookie('recent_products', '[]')`)
- Test: `tests/Feature/RecentProductsTest.php`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `recent_products`
- `Cookie::queue(`
- `array_slice(`
- `json_decode(` (dentro de ProductController)

## 6. Fragmento importante
```php
Cookie::queue(
    'recent_products',
    json_encode($recentIds),
    60 * 24 * 30   // 30 días en minutos
);
```

## 7. Explicación sencilla
Cuando entras a ver un producto, leo la cookie recent_products del navegador (JSON con IDs). Le quito el producto actual si ya estaba —para que no se repita— y lo pongo de primero, porque es el más reciente. Corto la lista a máximo 5 IDs y vuelvo a mandar la cookie con validez de 30 días usando Cookie::queue, que adjunta la cookie a la respuesta automáticamente. La cookie vive en el NAVEGADOR del cliente: por eso persiste aunque cierre sesión o apague la PC.

## 8. Recorrido del sistema
GET /productos/{id} → show() lee cookie → procesa IDs → Cookie::queue escribe nueva cookie → respuesta HTTP Set-Cookie: recent_products=[...] → navegador la guarda 30 días.

## 9. ¿Cómo lo pruebo?
1. Ver 3 productos distintos.
2. F12 → Application → Cookies → recent_products con los 3 IDs en orden.
3. Ver un 4º y 5º → acumula.
4. Ver un 6º → sigue habiendo solo 5 y desaparece el más viejo.

## 10. ¿Qué evidencia puedo enseñarle?
DevTools mostrando la cookie real con su valor JSON y expiración a 30 días, el código completo del bloque en show(), tests verdes.

## 11. Test relacionado
Archivo: `tests/Feature/RecentProductsTest.php`
Nombres: `test_ver_un_producto_guarda_su_id_en_la_cookie`, `test_ver_dos_productos_acumula_ambos_ids_en_la_cookie`, `test_la_cookie_de_recientes_no_almacena_mas_de_5`.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué cookie y no sesión ni BD?
2. ¿Qué significa Cookie::queue?
3. ¿Qué guardas exactamente: productos o IDs?

## 13. Respuesta corta para defenderlo
1. "La rúbrica lo pide con cookies y tiene sentido: son datos de comportamiento que deben sobrevivir sesiones y no requieren registro."
2. "Encola la cookie para que Laravel la adjunte a ESTA respuesta sin tener que construir el Response a mano."
3. "Solo los IDs en JSON; los datos frescos de cada producto se consultan a la BD al mostrarlos."

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
