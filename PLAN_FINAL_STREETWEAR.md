# Plan Final — StreetWear CR

> Generado el 2026-08-19 a partir de la auditoría completa del proyecto.
> Solo incluye problemas que REALMENTE sigan existiendo.

---

## FASE 0 — Bloqueadores

Ningún bloqueador absoluto. El sistema funciona para demo con pagos en modo demostración.

---

## FASE 1 — Requisitos Obligatorios Faltantes

### TAREA 1.1 — Integrar PayPal Sandbox

| Campo | Valor |
|---|---|
| Problema | PayPal es puramente cosmético. No hay SDK, no hay API calls, no hay capture, no hay webhook |
| Prioridad | CRÍTICA |
| Responsable | DARÍO (backend, integración) |
| Archivos | `composer.json`, `config/services.php`, `CheckoutController.php`, `resources/views/checkout/index.blade.php`, `.env.alwaysdata.example` |
| Pruebas | Crear `tests/Feature/PayPalTest.php` |
| Criterio de aceptación | Un usuario puede seleccionar PayPal, ser redirigido a PayPal Sandbox, completar el pago, y volver a la tienda con el pago confirmado |

### TAREA 1.2 — Transición Payment pending → paid

| Campo | Valor |
|---|---|
| Problema | El Payment siempre queda `pending`. No hay código que lo cambie a `paid` |
| Prioridad | CRÍTICA |
| Responsable | DARÍO |
| Archivos | `CheckoutController.php` (o nuevo método de callback) |
| Pruebas | Test que verifique que después de un pago exitoso, el status es `paid` |
| Criterio de aceptación | Después de confirmar el pago (PayPal callback o demo), el payment tiene `status: 'paid'`, `transaction_id` no nulo, `paid_at` con fecha |

### TAREA 1.3 — Order status update tras pago

| Campo | Valor |
|---|---|
| Problema | El Order status nunca cambia de `pending` automáticamente |
| Prioridad | ALTA |
| Responsable | DARÍO |
| Archivos | `CheckoutController.php` (o listener) |
| Pruebas | Test que verifique cambio de order status |
| Criterio de aceptación | Después del pago, el order status cambia a `processing` |

### TAREA 1.4 — Stock rollback si pago falla

| Campo | Valor |
|---|---|
| Problema | Si el pago falla después de la transacción, el stock queda descontado sin restaurar |
| Prioridad | ALTA |
| Responsable | DARÍO / NÉSTOR |
| Archivos | `CheckoutController.php` |
| Pruebas | Test de rollback de stock |
| Criterio de aceptación | Si el pago falla, el stock se restaura a su valor original |

---

## FASE 2 — Pagos (continuación de Fase 1)

### TAREA 2.1 — Configurar credenciales PayPal Sandbox

| Campo | Valor |
|---|---|
| Problema | No hay `PAYPAL_CLIENT_ID` ni `PAYPAL_CLIENT_SECRET` en .env |
| Prioridad | ALTA |
| Responsable | DARÍO |
| Archivos | `.env.alwaysdata.example`, `config/services.php` |
| Pruebas | Verificar que las credenciales se leen correctamente |
| Criterio de aceptación | Las credenciales están en .env.example con placeholders y se cargan en config |

### TAREA 2.2 — Crear vista de confirmación post-PayPal

| Campo | Valor |
|---|---|
| Problema | Después de PayPal, el usuario debe volver a la tienda y ver confirmación |
| Prioridad | ALTA |
| Responsable | DARÍO / NÉSTOR |
| Archivos | `CheckoutController.php` (callback), `resources/views/checkout/success.blade.php` |
| Pruebas | Test de flujo completo PayPal |
| Criterio de aceptación | El usuario ve la confirmación con tracking después de pagar con PayPal |

---

## FASE 3 — Errores Funcionales

### TAREA 3.1 — Unificar CartController con CartCalculator

| Campo | Valor |
|---|---|
| Problema | `CartController::index()` calcula subtotal inline; `CheckoutController` usa `CartCalculator` |
| Prioridad | MEDIA |
| Responsable | NÉSTOR |
| Archivos | `CartController.php`, `app/Services/CartCalculator.php` |
| Pruebas | Tests existentes deben seguir pasando |
| Criterio de aceptación | Solo hay una fuente de cálculo (CartCalculator) |

### TAREA 3.2 — Agregar protección de rol en rutas de reportes

| Campo | Valor |
|---|---|
| Problema | Las rutas `/reportes/*` solo verifican `auth`, no `role:super_admin` a nivel de middleware |
| Prioridad | ALTA |
| Responsable | NÉSTOR |
| Archivos | `routes/web.php`, `bootstrap/app.php` (o middleware personalizado) |
| Pruebas | Test que verifique 403 para cliente en /reportes/* |
| Criterio de aceptación | Un usuario sin rol `super_admin` recibe 403 al acceder a cualquier ruta de reportes |

---

## FASE 4 — Seguridad

### TAREA 4.1 — Validar tamaño/tipo de uploads

| Campo | Valor |
|---|---|
| Problema | FileUpload de Filament valida imagen pero sin límite de tamaño custom |
| Prioridad | MEDIA |
| Responsable | NÉSTOR |
| Archivos | `app/Filament/Resources/Products/Schemas/ProductForm.php` |
| Pruebas | Test de upload con archivo grande |
| Criterio de aceptación | Solo se permiten imágenes menores a 2MB en formatos comunes |

### TAREA 4.2 — Cambiar credenciales demo antes de producción

| Campo | Valor |
|---|---|
| Problema | Credenciales demo (admin@streetwearcr.test / Admin12345) en seeder |
| Prioridad | BAJA (para demo es aceptable) |
| Responsable | NÉSTOR |
| Archivos | `database/seeders/UserSeeder.php` |
| Pruebas | N/A |
| Criterio de aceptación | Credenciales actualizadas o documentadas como "solo para demo" |

---

## FASE 5 — Pruebas Faltantes

### TAREA 5.1 — Tests de reportes (ventas y productos)

| Campo | Valor |
|---|---|
| Problema | Solo hay test de descarga de reporte de pedidos. Falta ventas y productos |
| Prioridad | ALTA |
| Responsable | DARÍO |
| Archivos | `tests/Feature/ReportTest.php` |
| Pruebas | Agregar tests de descarga de ventas y productos |
| Criterio de aceptación | Admin puede descargar los 3 reportes; cliente no puede |

### TAREA 5.2 — Tests de filtros de reportes

| Campo | Valor |
|---|---|
| Problema | No hay tests que verifiquen filtros por fecha, estado o cliente |
| Prioridad | MEDIA |
| Responsable | DARÍO |
| Archivos | `tests/Feature/ReportTest.php` |
| Pruebas | Tests de filtros |
| Criterio de aceptación | Los filtros reducen los resultados correctamente |

### TAREA 5.3 — Tests de PayPal

| Campo | Valor |
|---|---|
| Problema | No hay tests de integración PayPal (ni mock) |
| Prioridad | ALTA |
| Responsable | DARÍO |
| Archivos | `tests/Feature/PayPalTest.php` (nuevo) |
| Pruebas | Tests de flujo PayPal |
| Criterio de aceptación | Al menos un test que verifique el flujo completo de PayPal con mock |

### TAREA 5.4 — Tests de permisos admin

| Campo | Valor |
|---|---|
| Problema | No hay tests que verifiquen que solo admin accede a /admin y /reportes |
| Prioridad | MEDIA |
| Responsable | DARÍO |
| Archivos | `tests/Feature/` (nuevos tests) |
| Pruebas | Tests de 403 para no-admin |
| Criterio de aceptación | Cliente recibe 403 en /admin; invitado es redirigido a login |

### TAREA 5.5 — Tests de 403/404

| Campo | Valor |
|---|---|
| Problema | No hay tests de páginas de error personalizadas |
| Prioridad | BAJA |
| Responsable | DARÍO |
| Archivos | `tests/Feature/` (nuevos tests) |
| Pruebas | Tests de error pages |
| Criterio de aceptación | Las páginas 403 y 404 se renderizan correctamente |

### TAREA 5.6 — Test de instalación limpia

| Campo | Valor |
|---|---|
| Problema | No hay test automatizado de `migrate:fresh --seed` |
| Prioridad | MEDIA |
| Responsable | DARÍO / NÉSTOR |
| Archivos | `tests/Feature/` (nuevo test o script) |
| Pruebas | Script de verificación |
| Criterio de aceptación | Un script verifica que la instalación limpia produce un sistema funcional |

---

## FASE 6 — UX/UI

### TAREA 6.1 — PayPal visual mejorado

| Campo | Valor |
|---|---|
| Problema | El selector de PayPal es solo un radio button sin indicador visual de "sandbox" |
| Prioridad | MEDIA |
| Responsable | ANDRIY |
| Archivos | `resources/views/checkout/index.blade.php` |
| Pruebas | Verificación visual |
| Criterio de aceptación | Se indica claramente que PayPal está en modo demostración |

### TAREA 6.2 — Estado de pago en confirmación

| Campo | Valor |
|---|---|
| Problema | La vista de confirmación muestra "Pago pendiente" pero no hay forma de actualizarlo |
| Prioridad | MEDIA |
| Responsable | ANDRIY / NÉSTOR |
| Archivos | `resources/views/checkout/success.blade.php` |
| Pruebas | Verificación visual |
| Criterio de aceptación | La confirmación refleja el estado real del pago |

### TAREA 6.3 — Pulido visual general

| Campo | Valor |
|---|---|
| Problema | El frontend funciona pero puede necesitar ajustes de espaciado, colores, tipografía |
| Prioridad | BAJA |
| Responsable | ANDRIY |
| Archivos | `resources/css/app.css`, `resources/views/**/*.blade.php` |
| Pruebas | Verificación visual |
| Criterio de aceptación | La interfaz es consistente y profesional |

---

## FASE 7 — Documentación

### TAREA 7.1 — Convertir requisitos.docx

| Campo | Valor |
|---|---|
| Problema | `requisitos.docx` no se puede leer programáticamente |
| Prioridad | ALTA |
| Responsable | COMPARTIDA |
| Archivos | `requisitos.docx` → `docs/REQUISITOS.md` |
| Pruebas | N/A |
| Criterio de aceptación | Los requisitos están en Markdown y se usa como fuente para la matriz de cumplimiento |

### TAREA 7.2 — Actualizar documentación de PayPal

| Campo | Valor |
|---|---|
| Problema | La documentación describe PayPal como "modo demo" sin explicar que no está integrado |
| Prioridad | MEDIA |
| Responsable | DARÍO |
| Archivos | `docs/TECNICA.md`, `docs/MANUAL.md`, `README.md` |
| Pruebas | N/A |
| Criterio de aceptación | La documentación refleja el estado real de PayPal |

### TAREA 7.3 — Documentar contribuciones del equipo

| Campo | Valor |
|---|---|
| Problema | El historial de Git no refleja las contribuciones reales de Darío y Andriy |
| Prioridad | MEDIA |
| Responsable | COMPARTIDA |
| Archivos | `README.md` o nuevo `CONTRIBUCIONES.md` |
| Pruebas | N/A |
| Criterio de aceptación | Cada integrante tiene documentado su contribución |

---

## FASE 8 — Hosting

### TAREA 8.1 — Verificar storage:link en servidor

| Campo | Valor |
|---|---|
| Problema | No se puede verificar si `storage:link` está ejecutado en alwaysdata |
| Prioridad | ALTA |
| Responsable | NÉSTOR |
| Archivos | Servidor alwaysdata |
| Pruebas | Verificar que las imágenes de productos cargan |
| Criterio de aceptación | Las imágenes SVG de productos se muestran correctamente en producción |

### TAREA 8.2 — Verificar .gitignore completo

| Campo | Valor |
|---|---|
| Problema | `reportes/` no está en .gitignore (contiene PDF generado) |
| Prioridad | BAJA |
| Responsable | NÉSTOR |
| Archivos | `.gitignore` |
| Pruebas | `git status` no debería mostrar `reportes/` |
| Criterio de aceptación | Los archivos generados no se versionan |

---

## FASE 9 — Preparación de Exposición

### TAREA 9.1 — Preparar demo flujo completo

| Campo | Valor |
|---|---|
| Problema | Necesitan una demo fluida para la presentación |
| Prioridad | ALTA |
| Responsable | COMPARTIDA |
| Archivos | `docs/DEFENSA.md` |
| Pruebas | Ensayo de demo |
| Criterio de aceptación | La demo de 5 minutos (cliente) + 3 minutos (admin) funciona sin errores |

### TAREA 9.2 — Verificar datos demo en producción

| Campo | Valor |
|---|---|
| Problema | Los seeders deben haber creado datos suficientes para la demo |
| Prioridad | ALTA |
| Responsable | NÉSTOR |
| Archivos | Servidor alwaysdata |
| Pruebas | Verificar catálogo, pedidos, pagos en producción |
| Criterio de aceptación | Hay productos, pedidos y pagos de demo visibles |

### TAREA 9.3 — Ensayar defensa

| Campo | Valor |
|---|---|
| Problema | Cada integrante debe poder defender su parte |
| Prioridad | ALTA |
| Responsable | COMPARTIDA |
| Archivos | `docs/DEFENSA.md` |
| Pruebas | Ensayo |
| Criterio de aceptación | Cada integrante puede explicar las partes difíciles del sistema |

---

## Resumen por Responsable

### NÉSTOR (integración, deploy, MVC)
- 3.1 Unificar CartController
- 3.2 Protección de rol en reportes
- 4.1 Validar uploads
- 8.1 Verificar storage:link
- 8.2 Actualizar .gitignore

### DARÍO (backend, pagos, pruebas)
- 1.1 PayPal Sandbox completo
- 1.2 Payment pending → paid
- 1.3 Order status update
- 1.4 Stock rollback
- 2.1 Credenciales PayPal
- 2.2 Vista post-PayPal
- 5.1 Tests de reportes
- 5.2 Tests de filtros
- 5.3 Tests de PayPal
- 5.4 Tests de permisos
- 5.5 Tests de 403/404
- 5.6 Test de instalación limpia
- 7.2 Documentación PayPal

### ANDRIY (UX, frontend, responsive)
- 6.1 PayPal visual mejorado
- 6.2 Estado de pago en confirmación
- 6.3 Pulido visual general

### COMPARTIDA
- 7.1 Convertir requisitos.docx
- 7.3 Documentar contribuciones
- 9.1 Preparar demo
- 9.2 Verificar datos demo
- 9.3 Ensayar defensa
