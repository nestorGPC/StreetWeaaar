# Punto 21 - Código fuente completo del proyecto

## 1. ¿Qué pide la profesora?
Entregar TODO el código fuente necesario: app, routes, resources, database, config, public, tests, composer.json/lock, package.json — sin archivos faltantes ni dependencias innecesarias.

## 2. Estado actual
CUMPLE A CABALIDAD (con limpieza recomendada antes del ZIP)

## 3. ¿Qué encontraste?
- `git ls-files` = **215 archivos versionados** incluyendo: `app/` completo (Controllers, Models, Services, Filament), `routes/web.php`, `resources/views` (todas las vistas) + css/js, `database/` (9 migraciones + 6 seeders + factory), `config/`, `public/` (index.php, .htaccess con HTTPS, build/), `tests/` (11 feature + 1 unit), `composer.json`+`composer.lock`, `package.json`, `.env.example`, README.md y docs/.
- `.gitignore` correcto: vendor/, node_modules/, .env NO se versionan (se regeneran con composer/npm install según README).
- PENDIENTE DE COMMIT (untracked): los nuevos `docs/rubrica/*`, `docs/AUDITORIA*`, etc. y la carpeta `reportes/` (salidas locales de PDFs — NO debe ir al repo). `README.md` modificado sin commitear.

## 4. ¿Dónde se encuentra?
- Todo el árbol del proyecto en `C:\xampp\htdocs\StreetWear CR`
- Estado exacto: `git status --short`
- Remoto: origin = https://github.com/nestorGPC/StreetWeaaar.git (rama main)

## 5. ¿Qué buscar en VS Code?
Buscar (o ejecutar en terminal):
- `git status --short`
- `git ls-files | Measure-Object` (PowerShell)
- Abrir `.gitignore`

## 6. Fragmento importante
```
# .gitignore (extracto)
/vendor
/node_modules
/.env
/reportes
```

## 7. Explicación sencilla
El ZIP/repo contiene el 100% del código que YO escribí: lógica, vistas, migraciones, tests y configuración. Las carpetas gigantes (vendor con miles de librerías, node_modules) no se incluyen porque Composer/npm las reconstruyen EXACTAMENTE igual usando los archivos lock. El .env tampoco va (contiene secretos); va .env.example como plantilla.

## 8. Recorrido del sistema
N/A (entrega).

## 9. ¿Cómo lo pruebo?
1. `git status --short` → solo cambios intencionales pendientes.
2. Clonar el repo limpio en otra carpeta → composer install → php artisan migrate --seed → la app levanta.
3. Revisar el ZIP final: app/, routes/, database/, tests/, docs/ presentes.

## 10. ¿Qué evidencia puedo enseñarle?
GitHub con el árbol completo visible, git ls-files, instalación desde cero funcionando.

## 11. Test relacionado
La suite completa (41 tests / 129 assertions) corre contra ESTE código fuente: es la prueba de integridad.

## 12. ¿Qué podría preguntarme la profesora?
1. ¿Por qué no viene vendor en tu entrega?
2. ¿Cómo instalaría yo tu proyecto desde cero?
3. ¿Qué es composer.lock?

## 13. Respuesta corta para defenderlo
1. "Es regenerable e idéntica con composer install usando el lock; incluir 30 MB de librerías ensucia la entrega."
2. "README sección Instalación: composer install, copiar .env.example a .env, php artisan key:generate, migrate --seed, npm install && build."
3. "Congela las versiones exactas de cada paquete para que todos instalemos lo mismo."

## 14. Problemas encontrados
- Untracked pendientes: documentación nueva de auditoría (commitear) y `reportes/` (excluir).
- README.md modificado sin commit (además su texto de PayPal Sandbox adelanta trabajo no versionado — alinear).

## 15. ¿Qué falta para obtener los 3 puntos?
Un commit final con la documentación nueva (excluyendo reportes/) y crear el ZIP desde ese estado limpio.
