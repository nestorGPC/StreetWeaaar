# Punto 2 - Carpeta comprimida "ProyectoFinal-NombreEstudiantes"

## 1. ¿Qué pide la profesora?
Un ZIP adjunto en la plataforma con nombre exacto `ProyectoFinal-NombreEstudiantes`.

## 2. Estado actual
NO VERIFICABLE SOLO CON EL CÓDIGO (verificado hoy: **NO existe ningún ZIP** aún)

## 3. ¿Qué encontraste?
Busqué archivos `.zip` en la raíz y en `docs/`: no hay ninguno. Es correcto no crearlo hasta cerrar todos los pendientes.

## 4. ¿Dónde se encuentra?
No existe todavía. Debe crearse desde la raíz del proyecto.

## 5. ¿Qué debe buscarse en VS Code?
N/A.

## 6. Fragmento importante
Comando sugerido para cuando toque crearlo (PowerShell, desde la carpeta padre):

```powershell
Compress-Archive -Path "StreetWear CR" -DestinationPath "ProyectoFinal-NestorPalacios.zip"
```

(excluyendo antes `vendor\`, `node_modules\`, `.git\` si se desea un ZIP ligero)

## 7. Explicación sencilla
El ZIP debe contener el código fuente completo sin dependencias instalables (`vendor`, `node_modules`), porque esas se regeneran con `composer install` / `npm install` según el README.

## 8. Recorrido del sistema
N/A.

## 9. ¿Cómo lo pruebo?
Después de crearlo: abrir el ZIP y verificar carpetas `app/`, `routes/`, `database/`, `docs/`, `README.md`.

## 10. ¿Qué evidencia puedo enseñarle a la profesora?
El ZIP descargado desde la plataforma con su nombre correcto.

## 11. Test relacionado
TEST FALTANTE (no aplica).

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué no incluyes `vendor`?
2. ¿Cómo instalaría yo tu proyecto desde este ZIP?

## 13. Respuesta corta para defenderlo
"Vendor y node_modules son dependencias que Composer/npm restauran solas con composer.lock/package.lock; así el ZIP pesa poco y siempre instala versiones exactas."

## 14. Problemas encontrados
- El ZIP aún no existe (pendiente manual).

## 15. ¿Qué falta para obtener los 3 puntos?
Crear `ProyectoFinal-NestorPalacios.zip` (ajustar apellido real) y adjuntarlo a la plataforma.
