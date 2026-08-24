# Punto 30 - Pregunta docente 2 (banco de preparación)

## 1. ¿Qué pide la profesora?
Segunda pregunta sorpresa de defensa.

## 2. Estado actual
NO VERIFICABLE SOLO CON EL CÓDIGO

## 3-4. Banco GRUPO 2 — DATOS, COOKIES Y REPORTES (código real)
Banco maestro: `docs/PREGUNTAS_Y_RESPUESTAS_DEFENSA.md`

1. **"¿Qué tabla guarda la compra y qué columnas tiene?"**
   R: "orders: id, user_id (quién), created_at (cuándo), subtotal/tax/shipping/total (cuánto), tracking_number único, status, shipping_address. Líneas en order_items y pago en payments."

2. **"¿Por qué order_items repite nombre y precio si ya están en products?"**
   R: "Histórico inmutable: si mañana edito el producto, las facturas antiguas conservan lo comprado ese día."

3. **"Explícame tu cookie de recientes."**
   R: "recent_products: JSON con hasta 5 IDs, se actualiza al ver un producto (el nuevo va primero sin duplicados), dura 30 días vía Cookie::queue; al mostrar consulto solo IDs activos existentes y reordeno según la cookie porque whereIn no preserva orden."

4. **"¿El reporte de ventas cumple por mes Y por cliente?"**
   R: "Ambos en un PDF: ventasPorMes agrupa por format('Y-m') y ventasPorCliente agrupa por usuario con conteo y suma; DomPDF descarga reporte-ventas.pdf. Solo super_admin (403 para el resto)."

5. **"¿Qué pasa si borro un producto que fue vendido?"**
   R: "Las órdenes no rompen: order_items guardó product_name/price/subtotal copiados; además mi flujo normal usa active=false (soft-hide), no borrado."

6. **"Diferencia entre sesión y cookie EN TU app."**
   R: "La SESIÓN (driver database) guarda el carrito y autenticación del lado servidor, ligada a cookie de ID; la COOKIE recent_products guarda comportamiento simple legible por el navegador. Carrito=sesión porque es sensible y transitorio; recientes=cookie porque debe sobrevivir sesiones."

## 5. Qué buscar en VS Code
`create_orders_table`, `Cookie::queue`, `ventasPorMes`, `array_search`

## 6. Fragmento importante
```php
$ventasPorCliente = $orders
    ->groupBy(fn ($order) => $order->user->name ?? 'Cliente eliminado')
    ...
    ->sortByDesc('total_vendido');
```

## 7. Explicación sencillo
Este grupo mide dominio de DATOS: modelo relacional, cookies y agregaciones de reportes. La clave es responder citando tabla+columna+test exactos.

## 8-9. Recorrido/prueba
Tener abierto DB Browser con orders/order_items/payments mientras respondes.

## 10. Evidencia
BD abierta + PDF de reportes descargado en vivo.

## 11. Test relacionado
RecentProductsTest (límite 5), ReportTest, OrderTest.

## 12. ¿Qué podría preguntarme la profesora?
Las 6 listadas son el grupo 2.

## 13. Respuesta corta
Incluida arriba.

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta?
Repasar esquema BD 15 min antes de la defensa.
