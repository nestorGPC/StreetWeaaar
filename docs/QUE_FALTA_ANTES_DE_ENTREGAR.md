# QUÉ FALTA ANTES DE ENTREGAR — Plan urgente (entrega en ~7 horas)

# CRÍTICO (podría generar 0 puntos) — hazlo PRIMERO
1. **Crear el ZIP de entrega** → `ProyectoFinal-NestorPalacios.zip` (ajusta tu apellido real):
   ```powershell
   Compress-Archive -Path "C:\xampp\htdocs\StreetWear CR\*" -DestinationPath "$env:USERPROFILE\Desktop\ProyectoFinal-NestorPalacios.zip" -Force
   ```
   Antes de comprimir confirma que NO incluya `vendor\`, `node_modules\`, `.git\` ni `reportes\` si quieres ZIP liviano (opcional; el README explica cómo regenerar dependencias).
2. **Subir el ZIP a la plataforma universitaria DENTRO DEL PLAZO** (Puntos 1 y 2).
3. **Push final a GitHub** (ya solicitado y en ejecución hoy) para que compañeros y profesora vean todo.

# ALTO (hoy darían "funciona con deficiencias")
1. **Punto 10/18 — Carrito acepta producto INACTIVO vía POST directo en add()**
   Fix exacto en `app/Http/Controllers/CartController.php`, método `add`, justo después del chequeo de stock:
   ```php
   if (! $product->active) {
       return back()->with('error', 'Este producto ya no está disponible.');
   }
   ```
   + duplicar el test `test_no_se_puede_actualizar_un_producto_inactivo` como `test_no_se_puede_agregar_un_producto_inactivo`. Impacto: sube puntos 10, 18 y ayuda al 25.
2. **Punto 13/22 — Contradicción README vs código**: README describe PayPal Sandbox operativo pero el código versionado crea Payment `pending` demo. DECIDE UNA:
   - Opción rápida (recomendada): editar README marcando claramente "PayPal: roadmap/planned" y defender el modo demo con honestidad (respuesta preparada en rubrica/31).
   - Opción lenta: integrar PayPal Orders API real — NO factible con seguridad en las horas restantes.
3. **APP_DEBUG=false en el .env del servidor alwaysdata** antes de la defensa (Punto 27).

# MEDIO (mejoran calidad, no bloquean)
- Usar `CartCalculator` también en `CartController@index` (elimina única duplicación, Punto 11/28).
- Agregar `.gitignore` entrada `/reportes`.
- Paginación del catálogo (escala futura).

# ENTREGA MANUAL (el código no puede resolverlo)
1. ZIP + plataforma (ver CRÍTICO).
2. **Exposición**: seguir `docs/GUIA_DEFENSA_RUBRICA.md` (guion 8-10 min con demos en https://nestor-alwaysdata-net.alwaysdata.net — YA ONLINE, probar desde tu celular).
3. **Estudiar bancos de preguntas**: `docs/PREGUNTAS_Y_RESPUESTAS_DEFENSA.md` + rubrica/29,30,31 (riesgo de perder hasta 75% si <50% aciertos).
4. Ensayo cronometrado ×2 + pasada responsive DevTools (Punto 26).
5. Verificar credenciales demo funcionando en vivo: admin@streetwearcr.test/Admin12345 · cliente@streetwearcr.test/Cliente12345.
