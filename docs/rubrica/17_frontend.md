# Punto 17 - Diseño Frontend adecuado (HTML/CSS/Bootstrap/JS)

## 1. ¿Qué pide la profesora?
Frontend coherente y completo construido con HTML, CSS, Bootstrap y JavaScript: layouts, navbar, cards, formularios, botones, checkout, historial y manejo de errores visual.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
- Layout principal `layouts/app.blade.php` con navbar Bootstrap responsive (colapsable en móvil), mensajes flash (success/error) y footer.
- Assets compilados con Vite (`@vite` en layout; `public/build/` presente; package.json con Bootstrap).
- Vistas completas: auth (login/register con errores por campo), products index (grid de cards con imagen/categoría/precio/badge stock) y show, cart, checkout (form + selector pago + resumen), account (dashboard/profile/orders/order-detail), checkout success, reports index, y páginas de error personalizadas 403/404/500.
- JavaScript: envío de formularios carrito (PUT/DELETE), confirmaciones y comportamiento del checkout.
- Coherencia visual: misma navbar/layout en tienda y cuenta; admin usa tema propio de Filament.

## 4. ¿Dónde se encuentra?
- Layout: `resources/views/layouts/app.blade.php`
- Vistas: `auth/`, `products/`, `cart/`, `checkout/`, `account/`, `reports/`, `errors/{403,404,500}.blade.php`
- CSS/JS: `package.json`, `resources/css/`, `resources/js/`, `public/build/`
- Componentes: clases Bootstrap (container, row, col, card, btn, navbar)

## 5. ¿Qué buscar en VS Code?
Buscar:
- `navbar-expand`
- `class="card`
- `@vite(`
- `@error(` (errores de validación en formularios)
- `session('success')` / `session('error')` (flash messages)

## 6. Fragmento importante
```blade
@if (session('success'))
    <div class="alert alert-success">{{ session('success') }}</div>
@endif
@if (session('error'))
    <div class="alert alert-danger">{{ session('error') }}</div>
@endif
@error('email')
    <span class="text-danger small">{{ $message }}</span>
@enderror
```

## 7. Explicación sencilla
Todas las páginas heredan de un mismo layout con Bootstrap, así la tienda se ve uniforme. Los mensajes que los controladores mandan con `with('success'|'error')` aparecen como alertas coloridas. Cada formulario muestra debajo del campo el error exacto devuelto por la validación del servidor. Y si algo sale mal (403/404/500), el usuario ve páginas de error propias en lugar de la fea pantalla por defecto.

## 8. Recorrido del sistema
Controller → view(...) → layouts/app.blade.php (@extends/@yield) → secciones de cada vista → Vite sirve CSS/JS compilados → navegador.

## 9. ¿Cómo lo pruebo?
1. Recorrer /productos, detalle, /carrito, /checkout, /mi-cuenta: mismo navbar y estilos.
2. Provocar error (login vacío) → mensajes bajo cada campo.
3. Acción exitosa → alerta verde flash.
4. Visitar /productos/99999 → página 404 personalizada.

## 10. ¿Qué evidencia puedo enseñarle?
Recorrido visual completo de la tienda, carpeta views en VS Code, páginas de error personalizadas, layout compartido.

## 11. Test relacionado
Los feature tests verifican respuestas HTTP y contenido de las vistas (p.ej. `ProductCatalogTest::test_catalogo_muestra_productos_activos`). TEST específico de UI visual: FALTANTE (normal; lo visual se demuestra en vivo).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Usaste Bootstrap real o copiaste estilos?
2. ¿Cómo llegan tus CSS al navegador?
3. ¿Dónde manejas los errores visuales?

## 13. Respuesta corta para defenderlo
1. "Bootstrap vía npm/Vite: grid, cards, navbar y componentes nativos, con ajustes propios en CSS."
2. "Con Vite: compilo recursos y Laravel inyecta los hashes con @vite en el layout."
3. "Dos niveles: alertas flash para acciones y @error bajo cada campo para validaciones."

## 14. Problemas encontrados
Ninguno relevante.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente.
