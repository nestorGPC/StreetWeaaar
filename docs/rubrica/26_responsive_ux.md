# Punto 26 - Diseño responsivo y experiencia intuitiva

## 1. ¿Qué pide la profesora?
Que el diseño se adapte a escritorio, tablet y móvil con una experiencia intuitiva.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
- Base Bootstrap 5 vía Vite: grid responsive (container/row/col-md-*), cards fluidas, navbar con `navbar-expand-lg` + toggler hamburguesa en móvil, botones y formularios nativos adaptativos.
- Grillas de productos usan columnas que colapsan (ej: col-6 col-md-4 col-lg-3) → 2 tarjetas en móvil, más columnas en escritorio.
- Tablas de pedidos/reportes envueltas en contenedores scrollables; formularios checkout/perfil apilados en pantallas pequeñas.
- Sin media queries custom rotas: el peso responsivo recae en breakpoints estándar de Bootstrap (576/768/992/1200).
- UX intuitiva: navbar con estados activos, mensajes flash claros, badges de stock/agotado, breadcrumbs visuales entre catálogo→detalle→carrito→checkout.

## 4. ¿Dónde se encuentra?
- Layout: `resources/views/layouts/app.blade.php` (navbar/toggler)
- Cards: `products/index.blade.php`, sección recientes en `products/show.blade.php`
- Formularios: `auth/*.blade.php`, `checkout/index.blade.php`, `account/profile.blade.php`
- Assets: `package.json` (bootstrap), `public/build/`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `navbar-toggler`
- `col-md-` o `col-lg-`
- `container`
- `navbar-expand`

## 6. Fragmento importante
```blade
<nav class="navbar navbar-expand-lg bg-body-tertiary">
    ...
    <button class="navbar-toggler" type="button"
            data-bs-toggle="collapse" data-bs-target="#mainNav">
        <span class="navbar-toggler-icon"></span>
    </button>
```

## 7. Explicación sencillo
Bootstrap define breakpoints: debajo de 992px el navbar se convierte en menú hamburguesa y las columnas de productos se apilan. No escribí CSS responsive propio arriesgado; usé el sistema de grillas probado, así que cualquier pantalla nueva se acomoda sola. La intuición viene de flujos cortos y feedback visual constante (alertas verde/rojo, badges).

## 8. Recorrido del sistema
N/A (presentación).

## 9. ¿Cómo lo pruebo? (PÁGINAS A PROBAR MANUALMENTE)
En Chrome DevTools (F12 → modo dispositivo) probar: iPhone SE (375px), iPad (768px), escritorio (1440px) en:
1. `/productos` (grid + filtros)
2. Detalle de producto (recientes)
3. `/carrito` y `/checkout`
4. `/mi-cuenta/pedidos` (tablas)
5. Login/registro
6. Hosting real desde tu CELULAR (prueba de fuego)

## 10. ¿Qué evidencia puedo enseñarle?
DevTools mostrando 3 tamaños en vivo + el sitio desde un teléfono físico.

## 11. Test relacionado
TEST FALTANTE (lo visual no se automatiza aquí; demostración manual).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Cómo lograste el responsive?
2. ¿Escribiste media queries propias?
3. ¿En qué breakpoint cambia el menú?

## 13. Respuesta corta para defenderlo
1. "Con el sistema de grillas y componentes de Bootstrap 5 compilados por Vite."
2. "Mínimas; casi todo sale de los breakpoints estándar de Bootstrap."
3. "A 992px (lg): debajo de eso aparece el botón hamburguesa."

## 14. Problemas encontrados
Ninguno estructural.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente (hacer la pasada manual de 10 minutos listada arriba para presentarlo seguro).
