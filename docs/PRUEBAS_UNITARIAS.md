# Pruebas Unitarias y de Integración — StreetWear CR

> Documento de evidencia del Punto 23 de la rúbrica: pruebas automáticas
> que verifican la funcionalidad del sistema.

---

## 1. Cómo ejecutarlas

```bash
composer install
php artisan test
```

Las pruebas usan SQLite en memoria (`:memory:` según `phpunit.xml`), por lo
que **nunca modifican** la base de datos real del proyecto o de producción.

## 2. Resultados obtenidos

Ejecución verificada el **24/08/2026**:

| Entorno | Comando | Resultado |
| --- | --- | --- |
| Código desplegado (repo `StreetWear-CR`) | `php artisan test` | **PASS — 45 pruebas, 148 aserciones** |
| Copia local de desarrollo | `php artisan test` | PASS — 41 pruebas, 129 aserciones |

La diferencia de 4 pruebas corresponde a la suite `PayPalCheckoutTest`,
incluida en el repositorio con la integración de PayPal Sandbox.

Salida resumida del entorno desplegado:

```text
   PASS  Tests\Feature\AccountTest
   PASS  Tests\Feature\AuthTest
   PASS  Tests\Feature\CartTest
   PASS  Tests\Feature\CheckoutIdempotencyTest
   PASS  Tests\Feature\CheckoutTest
   PASS  Tests\Feature\OrderTest
   PASS  Tests\Feature\PaymentTest
   PASS  Tests\Feature\PayPalCheckoutTest
   PASS  Tests\Feature\ProductCatalogTest
   PASS  Tests\Feature\RecentProductsTest
   PASS  Tests\Feature\ReportTest

  Tests:    45 passed (148 assertions)
  Duration: ~33s
```

## 3. Inventario de suites y qué valida cada una

### AuthTest (5 pruebas)
| Prueba | Qué valida |
| --- | --- |
| `test_el_registro_crea_un_usuario_y_le_asigna_el_rol_customer` | Registro completo + rol automático |
| `test_un_usuario_registrado_puede_iniciar_sesion` | Login con credenciales válidas |
| `test_no_puede_iniciar_sesion_con_la_contrasena_incorrecta` | Rechazo de contraseña inválida |
| `test_un_usuario_autenticado_puede_cerrar_sesion` | Logout e invalidación de sesión |
| `test_se_limitan_los_intentos_de_inicio_de_sesion` | Rate limiting `throttle:5,1` |

### AccountTest (5 pruebas)
| Prueba | Qué valida |
| --- | --- |
| `test_un_cliente_puede_ver_el_detalle_de_su_pedido` | Historial/detalle propio |
| `test_un_cliente_no_puede_ver_el_pedido_de_otro_cliente` | Protección 403 de pedidos ajenos |
| `test_un_invitado_no_puede_ver_sus_pedidos` | Middleware `auth` |
| `test_un_cliente_puede_actualizar_su_perfil` | Edición de nombre/email |
| `test_no_se_puede_usar_un_email_de_otro_usuario` | Unicidad de email (`Rule::unique`) |

### CartTest (7 pruebas)
Agregar producto, rechazo de agotados, no superar stock al agregar,
actualizar cantidad, no superar stock al actualizar, rechazo de producto
inactivo, eliminar producto. Valida todo el ciclo del carrito en sesión
con sus reglas de inventario.

### CheckoutIdempotencyTest (2 pruebas)
| Prueba | Qué valida |
| --- | --- |
| `test_un_doble_post_no_crea_dos_pedidos` | Token anti doble-envío: un solo pedido |
| `test_el_checkout_rechaza_un_token_invalido` | Rechazo de token inválido/expirado |

### CheckoutTest (3 pruebas)
Checkout exitoso completo, rechazo por inventario insuficiente dentro de la
transacción (`lockForUpdate`), y rechazo con carrito vacío.

### OrderTest (2 pruebas)
El cliente ve únicamente sus propios pedidos; los ajenos quedan bloqueados.

### PaymentTest (3 pruebas)
El checkout crea el pago en `pending`, el pago pertenece al pedido correcto
y su estado es actualizable.

### PayPalCheckoutTest (4 pruebas — solo repo integrado)
| Prueba | Qué valida |
| --- | --- |
| `test_el_checkout_con_paypal_redirige_a_la_pagina_de_aprobacion` | Creación de orden sandbox + redirect a approve URL |
| `test_el_retorno_exitoso_marca_el_pago_como_pagado` | Captura `COMPLETED` → Payment `paid` + `transaction_id` + pedido `processing` |
| `test_la_cancelacion_en_paypal_marca_el_pago_como_fallido_sin_afectar_el_pedido` | Cancelación controlada |
| `test_un_cliente_no_puede_confirmar_el_pago_de_otro_cliente` | Autorización del retorno |

### ProductCatalogTest (5 pruebas)
Catálogo solo con productos activos, búsqueda por nombre, filtro por
categoría, filtro por rango de precio y vista de detalle.

### RecentProductsTest (3 pruebas)
La cookie `recent_products` guarda el ID visitado, acumula varios IDs y se
limita a un máximo de 5 productos.

### ReportTest (4 pruebas)
Un cliente NO puede ver `/reportes` ni descargar PDFs; un invitado es
redirigido al login; el administrador sí descarga el reporte de pedidos.

## 4. Cobertura frente a la rúbrica

Área rúbrica | Suite que la respalda
--- | ---
Autenticación / registro / login | `AuthTest`
Perfil e historial | `AccountTest`
Catálogo / filtros / detalle | `ProductCatalogTest`
Carrito (agregar/actualizar/eliminar) | `CartTest`
Totales / checkout / transacción | `CheckoutTest`, `CheckoutIdempotencyTest`
Pedidos y privacidad | `OrderTest`
Pagos y PayPal Sandbox | `PaymentTest`, `PayPalCheckoutTest`
Cookies de recientes | `RecentProductsTest`
Reportes protegidos | `ReportTest`
