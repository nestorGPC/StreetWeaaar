# PENDIENTES REALES — StreetWear CR (24/08/2026)

> SOLO tareas pendientes de verdad. Si algo está aquí, es porque hoy NO está hecho.
> Verificado contra código repo (`StreetWear-CR` @9ce00c4), carpeta local y servidor alwaysdata.

---

# EN PROCESO AHORA

## 1. Hosting: páginas públicas dan 500
- **Causa confirmada** (log del servidor): `public/build` no existe → "Vite manifest not found".
- Hecho ya: root apuntado a `streetwear/public`, HTTPS OK, SQLite migrada/sembrada, .env producción OK, vendor OK.
- Falta:
  - [ ] Compilar assets. Opción A (servidor tiene Node v24): `npm ci && npm run build`. Opción B: compilar local y subir `public/build/` por SCP.
  - [ ] `php artisan storage:link` en servidor (imágenes 404 ahora).
  - [ ] Caches: `php artisan config:cache && php artisan view:cache` (y `route:cache` si no falla).
- Comprobación de cierre: `/productos`, `/login`, `/registro`, `/carrito` devuelven 200 con CSS e imágenes.

# FALTA PROGRAMAR

Nada crítico pendiente de programar. Todo el código de la rúbrica existe.

Opcional (mejora, no requisito):
- [ ] Webhook PayPal para capturas asíncronas (hoy la captura es síncrona en el return — aceptable).
- [ ] `CartController@add`: verificar `$product->active` igual que hace `update()`.

# FALTA CORREGIR

- [ ] **Permisos Shield en producción:** super_admin entra a `/admin` pero NO puede editar categorías/productos (policies `ViewAny:Category` etc. sin permisos en BD; config Shield usa `define_via_gate=false`). Corrección (solo BD): generar permisos y asignárselos al rol super_admin (`php artisan shield:generate --all --option=permissions` + asignación al rol, o cambiar config a gate). Verificado hoy: admin `viewAny Category = NO`.
- [ ] **Credenciales PayPal sandbox vacías** en `.env` del servidor → completar `PAYPAL_SANDBOX_CLIENT_ID` / `PAYPAL_SANDBOX_CLIENT_SECRET` manualmente (no versionarlas).
- [ ] **OrderSeeder en producción falla** con `--no-dev` (usa `fake()` de fakerphp/faker que es dependencia dev). Los pedidos demo quedaron sin sembrar (0 pedidos). Opciones: sembrar un pedido vía checkout real (recomendado) o mover faker a `require`.
- [ ] **[LOCAL] Sincronizar carpeta local con el repo** si vas a defender desde VS Code local: tu carpeta no tiene `PayPalService`, `config/paypal.php`, ni `PayPalCheckoutTest`; y el `.htaccess` difiere (el local sí trae el fix X-Forwarded-Proto). Decidir versión canónica y alinear.
- [ ] **[LOCAL]** Añadir `reportes/` al `.gitignore` (queda como untracked).

# FALTA PROBAR

- [ ] **Flujo PayPal end-to-end en Sandbox** tras poner credenciales: comprar con cuenta buyer falsa → aprobar → verificar Payment `paid` + `transaction_id` + order `processing`.
- [ ] **Responsive visual** (15 min): DevTools móvil/tablet en `/productos`, detalle, `/carrito`, `/checkout`, `/mi-cuenta/pedidos`, `/admin`.
- [ ] **Checklist final de hosting** (ver §HOSTING en ESTADO_ACTUAL_RUBRICA.md): registro, login, carrito completo, IVA/envío, pedido+tracking, admin CRUD, reportes PDF mes/cliente, logout.
- [ ] Re-ejecutar `php artisan test` tras cualquier cambio y registrar salida.

# FALTA DOCUMENTAR

- [ ] **docs/PRUEBAS_UNITARIAS.md**: documento exigido por Punto 23. Incluir lista de suites + output real: repo **45 passed / 148 assertions**, local 41/129 (ejecutados hoy).
- [ ] **Actualizar README/docs** con: integración PayPal real (flujo + credenciales sandbox cómo configurar), URL pública https://nestor-alwaysdata-net.alwaysdata.net, pasos de actualización en hosting.
- [ ] Capturas finales para la defensa (catálogo, checkout PayPal, tracking, reportes PDF, admin).

# ACCIONES MANUALES DE ENTREGA

- [ ] Cambiar credenciales demo antes/después de exponer si se desea (`admin@streetwearcr.test` / `cliente@streetwearcr.test` documentadas en README L123-124).
- [ ] Crear ZIP: `ProyectoFinal-NestorPalacios.zip` (sin vendor/node_modules/.git/sqlite).
- [ ] Subir a la plataforma universitaria dentro del plazo.
- [ ] Preparar exposición (guía en docs/DONDE_ESTA_CADA_REQUISITO.md + docs/DEFENSA.md).
- [ ] Practicar respuestas probables (secciones 29-31 de la rúbrica).
