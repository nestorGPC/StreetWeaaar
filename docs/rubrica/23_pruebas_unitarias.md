# Punto 23 - Documento con pruebas unitarias

## 1. ¿Qué pide la profesora?
Un DOCUMENTO con pruebas unitarias que verifique la funcionalidad (no basta tener tests: hay que entregarlos documentados y demostrarlos corriendo).

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste?
- Suite real: **11 archivos** en `tests/Feature/` (Account, Auth, Cart, CheckoutIdempotency, Checkout, Example, Order, Payment, ProductCatalog, RecentProducts, Report) + 1 en `tests/Unit/`.
- EJECUTADO HOY dos veces: **41 tests passed, 129 assertions** (`php artisan test`, SQLite local, ~18s). En el repo la suite tiene 45 pruebas definidas (4 requieren entorno adicional).
- DOCUMENTO ENTREGABLE creado: `docs/PRUEBAS_UNITARIAS.md` con metodología (PHPUnit + RefreshDatabase), desglose POR SUITE de cada test y qué valida, resultado actual y comandos.
- Cobertura funcional amplia: auth/roles, catálogo/filtros, carrito (stock/inactivo/cantidades), checkout transaccional, idempotencia anti doble-POST, pedidos privados, pagos pending, cookies recientes (límite 5), seguridad de reportes.

## 4. ¿Dónde se encuentra?
- Documento: `docs/PRUEBAS_UNITARIAS.md`
- Tests: `tests/Feature/*.php`, `tests/Unit/ExampleTest.php`
- Config: `phpunit.xml` (entorno testing)
- Comando: `php artisan test`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `RefreshDatabase` (trait usado en todos)
- `#[Test]` o `function test_` en carpeta tests
- Abrir `docs/PRUEBAS_UNITARIAS.md`

## 6. Fragmento importante
```php
// tests/Feature/CheckoutIdempotencyTest.php
public function test_un_doble_post_no_crea_dos_pedidos(): void
{
    // ... primer POST crea orden ...
    $response = $this->post(route('checkout.store'), $payload);
    $this->assertDatabaseCount('orders', 1);
}
```

## 7. Explicación sencillo
Cada prueba simula una petición HTTP real contra una base SQLite limpia (el trait RefreshDatabase corre las migraciones frescas por test). Afirma resultados concretos: filas creadas, redirecciones, códigos 403, contenido de sesiones/cookies. El documento PRUEBAS_UNITARIAS.md explica QUÉ suite cubre QUÉ requisito de la rúbrica, así la profesora puede mapear prueba↔funcionalidad sin leer código.

## 8. Recorrido del sistema
php artisan test → PHPUnit → cada Feature test: fabrica datos (factories/seeders) → llama rutas internamente → aserta contra BD/sesión → verde o rojo.

## 9. ¿Cómo lo pruebo?
1. `php artisan test` → mostrar 41 passed / 129 assertions EN VIVO.
2. Abrir docs/PRUEBAS_UNITARIAS.md junto a la salida.
3. Romper algo a propósito (opcional) y ver un rojo → demuestra que prueban de verdad.

## 10. ¿Qué evidencia puedo enseñarle?
Terminal con la suite verde, el documento PDF/markdown, y GitHub mostrando la carpeta tests/.

## 11. Test relacionado
LA SUITE COMPLETA ES EL PUNTO. Destacadas: AuthTest (5), CartTest (7), CheckoutTest (3), CheckoutIdempotencyTest (2), AccountTest (5), ReportTest (4), RecentProductsTest (3), PaymentTest (3), ProductCatalogTest (5), OrderTest (2).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Qué es una assertion?
2. ¿Tus tests tocan mi base de datos real?
3. ¿Qué parte del sistema NO tienen pruebas?

## 13. Respuesta corta para defenderlo
1. "Una comprobación concreta: assertDatabaseHas verifica que exista una fila, por ejemplo; tengo 129 repartidas en 41 pruebas."
2. "No: usan SQLite de testing con RefreshDatabase; cada prueba arranca con migraciones frescas."
3. "Lo visual/pixel (responsive) y la pasarela externa real, que requiere sandbox de terceros."

## 14. Problemas encontrados
Ninguno (suite estable en verde en todas las ejecuciones del día).

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente. (Opcional: sumar tests de add()-producto-inactivo si se aplica la mejora del Punto 10.)
