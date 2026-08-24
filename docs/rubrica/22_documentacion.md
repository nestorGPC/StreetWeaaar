# Punto 22 - Documentación detallada con instrucciones de uso

## 1. ¿Qué pide la profesora?
Documentación detallada con: A) descripción del proyecto; B) instrucciones de instalación; C) instrucciones de uso; D) credenciales demo; E) diagrama de caso de uso del proceso de compra.

## 2. Estado actual
CUMPLE A CABALIDAD

## 3. ¿Qué encontraste? (verificado A–E por separado)
- A. DESCRIPCIÓN: `README.md` presenta StreetWear CR (tienda streetwear Laravel+SQLite), stack y funcionalidades.
- B. INSTALACIÓN: README paso a paso (composer install, .env, key:generate, sqlite, migrate --seed, npm).
- C. USO: `docs/MANUAL.md` completo (flujo cliente: registro→catálogo→carrito→checkout→pedidos; flujo admin) + README sección uso.
- D. CREDENCIALES DEMO: tabla en README: admin@streetwearcr.test / Admin12345 y cliente@streetwearcr.test / Cliente12345 (verificadas contra seeders y BD real hoy).
- E. DIAGRAMA CASO DE USO COMPRA: `docs/diagrama-uso-compra.md`.
- Extras: `docs/TECNICA.md` (arquitectura/tablas), `docs/DEPLOYMENT.md`+`DEPLOY_ALWAYSDATA.md` (hosting real), `docs/PRUEBAS_UNITARIAS.md` (punto 23), `docs/DEFENSA.md`.

## 4. ¿Dónde se encuentra?
- `README.md` (raíz) — A, B, D (+uso resumido)
- `docs/MANUAL.md` — C
- `docs/diagrama-uso-compra.md` — E
- `docs/TECNICA.md`, `docs/DEPLOYMENT.md`, `docs/PRUEBAS_UNITARIAS.md`

## 5. ¿Qué buscar en VS Code?
Buscar:
- `## Instalación` (en README)
- `admin@streetwearcr.test`
- `diagrama` (en docs/)
- `## Uso` (en MANUAL)

## 6. Fragmento importante
```markdown
| Rol     | Correo                     | Contraseña    |
|---------|----------------------------|---------------|
| Administrador | `admin@streetwearcr.test` | `Admin12345` |
| Cliente      | `cliente@streetwearcr.test` | `Cliente12345` |
```

## 7. Explicación sencillo
El README es la puerta de entrada: explica qué es el proyecto, cómo montarlo desde cero en cualquier máquina y con qué cuentas probarlo. El MANUAL detalla el uso paso a paso para usuario y administrador. El diagrama muestra gráficamente el caso de uso del proceso de compra exigido. Documentación técnica y de despliegue complementan para quien quiera profundizar.

## 8. Recorrido del sistema
N/A.

## 9. ¿Cómo lo pruebo?
1. Abrir README → recorrer descripción/instalación/credenciales.
2. Seguir la guía de instalación EN OTRA CARPETA clonada → funciona.
3. Abrir docs/MANUAL.md y seguirlo como cliente nuevo.
4. Abrir docs/diagrama-uso-compra.md → caso de uso de la compra.

## 10. ¿Qué evidencia puedo enseñarle?
README renderizado en GitHub, MANUAL abierto, diagrama proyectado, y demostrar que las credenciales de la tabla SÍ entran al sistema en vivo.

## 11. Test relacionado
TEST FALTANTE (la documentación no se testa; se valida siguiéndola manualmente — hecho).

## 12. ¿Qué podría preguntarme la profesora?
1. Si te olvido mi contraseña demo, ¿dónde está?
2. ¿Tu instalación funciona en Windows y Linux?
3. ¿Dónde está el diagrama que pedí?

## 13. Respuesta corta para defenderlo
1. "En la tabla de credenciales del README y en database/seeders/UserSeeder.php."
2. "Sí: PHP 8.2+, SQLite y Composer; el README lista los pasos agnósticos de SO."
3. "En docs/diagrama-uso-compra.md, junto al resto de la documentación."

## 14. Problemas encontrados
- README menciona PayPal Sandbox operativo mientras el código versionado mantiene el pago en modo demo (Punto 13) → ALINAR texto antes de entregar para no generar contradicción.

## 15. ¿Qué falta para obtener los 3 puntos?
Nada obligatorio pendiente (solo alinear el párrafo PayPal del README con el estado real del código).
