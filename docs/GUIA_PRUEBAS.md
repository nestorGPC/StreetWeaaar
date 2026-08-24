# GUÍA DE PRUEBAS — StreetWear CR
Objetivo: verificar TODO el sistema en ~40 minutos antes de entregar/defender.
Automatizadas: 41 tests / 129 assertions (verde = base sólida). Manuales: demuestran lo que la profesora verá.

---

## 0. PREPARACIÓN (2 min)
Credenciales demo (README):
| Rol | Correo | Contraseña |
|---|---|---|
| Admin | admin@streetwearcr.test | Admin12345 |
| Cliente | cliente@streetwearcr.test | Cliente12345 |

Reset SOLO LOCAL (borra y re-siembra): `php artisan migrate:fresh --seed`
⚠️ NUNCA en el servidor alwaysdata (tiene pedidos demo reales).
URLs: Local http://localhost/StreetWear%20CR/public · Producción https://nestor-alwaysdata-net.alwaysdata.net

---

## 1. PRUEBAS AUTOMATIZADAS (5 min)
```powershell
php artisan optimize:clear
php artisan test
```
Esperado: **41 passed, 129 assertions** (~18s). Documento oficial: `docs/PRUEBAS_UNITARIAS.md`.

Suite única: `php artisan test --filter=CartTest`

Mapa suite → requisito rúbrica:
| Suite | # | Cubre |
|---|---|---|
| AuthTest | 5 | P4/P5: registro+rol, login, error, logout, throttle |
| AccountTest | 5 | P6: perfil, email ajeno, historial, 403 ajeno |
| CartTest | 7 | P10: add/agotado/stock/update/max/inactivo/remove |
| ProductCatalogTest | 5 | P8/P9: activos, nombre, categoría, rango, detalle |
| CheckoutTest | 3 | P12/P14: compra feliz, inventario insuficiente, carrito vacío |
| CheckoutIdempotencyTest | 2 | P12: doble POST, token inválido |
| PaymentTest | 3 | P13: pending, actualizable, relación order |
| OrderTest | 2 | P6/P12: propios sí, ajenos no |
| RecentProductsTest | 3 | P19: cookie guarda/acumula/máx 5 |
| ReportTest | 4 | P15: cliente 403, PDF admin, invitado login |

---

## 2. MANUAL — FLUJO CLIENTE (15 min)
Anota ✓/✗ en cada paso:
| # | Acción | Resultado esperado |
|---|---|---|
| C1 | Abrir `/` | Redirige a /productos |
| C2 | Registrarte con datos nuevos | Logueado en /mi-cuenta, rol customer |
| C3 | Registrar email ya usado | Error "correo electrónico ya está en uso" |
| C4 | Login contraseña mala | Mensaje genérico; email conservado |
| C5 | Fallar login 6 veces seguidas | Bloqueo temporal (429) |
| C6 | Buscar "tenis" + categoría + precio máx | Solo productos que cumplen TODO |
| C7 | Ver 5 productos distintos | F12→Cookies→recent_products con ≤5 IDs |
| C8 | Abrir detalle del último | Sección recientes SIN incluirlo |
| C9 | Agregar agotado al carrito | Rechazado "agotado" |
| C10 | Actualizar cantidad > stock | Error de validación max |
| C11 | Eliminar ítem | Desaparece del carrito |
| C12 | Checkout dirección 5 chars | Error min:10 |
| C13 | Confirmar compra (tarjeta) | Tracking SWCR-FECHA-XXXXXX; IVA 13%; envío ₡3.000 |
| C14 | Comparar totales carrito vs confirmación vs BD | Idénticos |
| C15 | Reenviar el POST del checkout (F5 en confirmación no cuenta; usar atrás+reenviar) | NO crea segundo pedido (idempotencia) |
| C16 | /mi-cuenta/pedidos → abrir pedido | Detalle ítems+pago+tracking |
| C17 | Cambiar ID en URL por pedido ajeno | 403 |
| C18 | Editar perfil (nombre ok / email de otro) | Éxito / error unique |
| C19 | Logout | Flash sesión cerrada; rutas privadas piden login |

## 3. MANUAL — FLUJO ADMIN (10 min)
| # | Acción | Esperado |
|---|---|---|
| A1 | Login admin → /admin | Dashboard Filament |
| A2 | Crear categoría "Hoodies" | Aparece en filtros de tienda |
| A3 | Crear producto con imagen | Visible en catálogo |
| A4 | Desactivar ese producto | Desaparece de tienda y de recientes |
| A5 | Cliente entra a /admin | Sin acceso (canAccessPanel) |
| A6 | Cliente abre /reportes | 403 personalizado |
| A7 | Descargar Reporte de ventas PDF | Tablas POR MES y POR CLIENTE + totales |
| A8 | Descargar reporte pedidos y productos | Ambos PDF descargan |
| A9 | Filtrar reporte por fecha/estado/cliente | PDF respeta filtros |

## 4. SEGURIDAD (5 min)
| # | Prueba | Esperado |
|---|---|---|
| S1 | Buscar `' OR 1=1--` | Lista vacía, sin error SQL |
| S2 | Buscar `<script>alert(1)</script>` | Se muestra como TEXTO (escapado) |
| S3 | POST sin token CSRF (curl) | 419 |
| S4 | Abrir http://host... | 301 → https |
| S5 | `git ls-files | grep .env` | Solo .env.example |
| S6 | Servidor: APP_DEBUG | false |

## 5. RESPONSIVE (5 min)
DevTools F12 → modo dispositivo: iPhone SE 375px, iPad 768px, Desktop 1440px en: /productos, detalle, /carrito, /checkout, /mi-cuenta/pedidos, login.
Verificar: navbar hamburguesa <992px, cards apiladas, tablas usables, botones tocables.
Extra: abrir el HOSTING desde tu celular.

## 6. SMOKE TEST HOSTING (2 min)
1. /productos → 200 con estilos (CSS cargó)
2. Una imagen de producto carga (/storage/products/...)
3. Login con credenciales demo funciona
4. Compra completa de prueba → tracking visible
5. /admin entra solo con admin

---

## REGISTRO DE EJECUCIÓN
Fecha: ____ · Probador: ____
- Automatizadas: __ passed / __ assertions
- Cliente C1-C19: __ ✓ __ ✗
- Admin A1-A9: __ ✓ __ ✗
- Seguridad S1-S6: __ ✓ __ ✗
- Responsive: __ ✓ __ ✗
- Hosting: __ ✓ __ ✗
Fallas encontradas y capturas: ______________________
