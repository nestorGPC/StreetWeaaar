# Punto 24 - Participó en la exposición

## 1. ¿Qué pide la profesora?
Presentar el proyecto en clase (presencial o virtual). NO verificable por código: depende de ti.

## 2. Estado actual
NO VERIFICABLE SOLO CON EL CÓDIGO

## 3. ¿Qué encontraste?
Ya existe material de apoyo: `docs/DEFENSA.md` (guion previo) y ahora además `docs/GUIA_DEFENSA_RUBRICA.md` (guía punto por punto de la rúbrica: qué mostrar, dónde está, cómo explicarlo y preguntas probables). El sistema está 100% operativo en hosting para hacer DEMO EN VIVO sin depender de tu PC.

## 4. ¿Dónde se encuentra?
- Guía nueva: `docs/GUIA_DEFENSA_RUBRICA.md`
- Guion anterior: `docs/DEFENSA.md`
- URL demo: https://nestor-alwaysdata-net.alwaysdata.net
- Panel admin: `/admin` (admin@streetwearcr.test / Admin12345)

## 5. Qué buscar en VS Code
N/A (preparación personal).

## 6. Fragmento importante
GUION SUGERIDO (8–10 min):
1. Intro (30s): qué es StreetWear CR + stack (Laravel 12, SQLite, Bootstrap, Filament).
2. Demo cliente (3 min): registro → catálogo con filtros → detalle (mostrar cookie recientes en F12) → carrito (stock) → checkout (desglose IVA/envío) → confirmación con tracking.
3. Demo admin (2 min): login admin → panel Filament → CRUD producto → /reportes → descargar PDF de ventas (mes + cliente).
4. Código clave (2 min): CartCalculator (totales únicos) + transacción checkout (lockForUpdate) + ensureIsAdmin.
5. Calidad (1.5 min): php artisan test en vivo (41/129) + GitHub + HTTPS del hosting.
6. Cierre honesto (30s): pagos en modo demo pendiente-pasarela; roadmap.

## 7. Explicación sencilla
La exposición se gana mostrando el RECORRIDO COMPLETO de una compra real más UNA pieza de código por concepto (cálculo, transacción, seguridad). Tener el hosting abierto evita problemas técnicos; tener los tests listos demuestra rigor sin explicar todo el código.

## 8. Recorrido del sistema
N/A.

## 9. ¿Cómo lo pruebo?
Ensayar 2 veces el guion cronometrado; preparar pestañas abiertas: tienda, F12 (cookies), /admin, /reportes, GitHub, terminal con php artisan test.

## 10. ¿Qué evidencia puedo enseñarle?
La demo en vivo misma + documentos de auditoría como respaldo ante preguntas.

## 11. Test relacionado
`php artisan test` como cierre técnico de la presentación (41 passed / 129 assertions).

## 12. ¿Qué podría preguntarme la profesora? (las típicas de exposición)
1. ¿Por qué elegiste este stack?
2. ¿Qué fue lo más difícil?
3. ¿Qué mejorarías con más tiempo?

## 13. Respuesta corta para defenderlo
1. "Laravel por productividad MVC madura; SQLite porque el proyecto lo define y simplifica entrega/hosting; Bootstrap por responsive rápido."
2. "Garantizar consistencia en checkout: resolvido con transacción + lockForUpdate + token de idempotencia."
3. "Conectar PayPal Sandbox real y agregar paginación/roles adicionales."

## 14. Problemas encontrados
Ninguno técnico. Riesgo: tiempo — ensayar cronometrado.

## 15. ¿Qué falta para obtener los 3 puntos?
PRESENTARTE y completar el guion. Material listo en GUIA_DEFENSA_RUBRICA.md.
