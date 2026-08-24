# Punto 31 - Pregunta docente 3 (banco de preparación)

## 1. ¿Qué pide la profesora?
Tercera pregunta sorpresa. AVISO DE LA PROFESORA: responder menos del 50% puede costar hasta el 75% del valor evaluativo → estudiar OBLIGATORIO.

## 2. Estado actual
NO VERIFICABLE SOLO CON EL CÓDIGO

## 3-4. Banco GRUPO 3 — SEGURIDAD, GITHUB Y HONESTIDAD TÉCNICA
Banco maestro: `docs/PREGUNTAS_Y_RESPUESTAS_DEFENSA.md`

1. **"¿Cómo proteges contraseñas?"**
   R: "Hash::make = bcrypt con salt automático al registrar; Auth::attempt compara hashes; jamás logeo ni devuelvo password; .env fuera de Git."

2. **"Muéstrame que no tienes SQL Injection."**
   R: "Todo Eloquent/Builder parametrizado; grep de DB::raw|selectRaw|whereRaw en app/ da CERO. Demo: buscar ' OR 1=1-- en el buscador devuelve cero resultados sin romper nada."

3. **"¿Y XSS?"**
   R: "Blade escapa con {{ }}; no existe ningún {!! !!} en mis vistas (verificable); datos de usuario jamás se imprimen crudos."

4. **"¿Quién entra a /admin y /reportes?"**
   R: "/admin exige canAccessPanel (rol super_admin); /reportes ensureIsAdmin→403. Cliente demo cliente@streetwearcr.test queda afuera: hay 3 tests de ReportTest comprobándolo."

5. **"Enséñame tu GitHub: ¿trabajo colaborativo?"**
   R: "Repo público nestorGPC/StreetWeaaar, rama main, historial consolidado + branch backup/pre-integracion; .gitignore sano (vendor/node_modules/.env); 215 archivos trackeados; commits descriptivos en español."

6. **"Si tu pago es demo, ¿por qué debería creerte que FUNCIONA?"**
   R: "Porque separo responsabilidades: la ORDEN sí es 100% real (transacción, inventario, tracking, historial); el Payment registra method/status/transaction_id/amount/paid_at con estado pending VERDADERO — no simulo cobros falsos. Conectar PayPal Orders API es plug-in sobre esa estructura ya testeada."

## 5. Qué buscar en VS Code
`Hash::make`, `{!!`, `canAccessPanel`, `.gitignore`

## 6. Fragmento importante
```php
public function canAccessPanel(Panel $panel): bool
{
    return $this->hasRole('super_admin');
}
```

## 7. Explicación sencillo
El grupo 3 premia HONESTIDAD + dominio de seguridad. Nunca improvises un "sí funciona" sobre pagos: la respuesta ganadora es la estructurada del punto 6.

## 8-9. Recorrido/prueba
Ejecutar los greps EN VIVO (resultado vacío impresiona); tener GitHub abierto en otra pestaña.

## 10. Evidencia
Terminal con greps vacíos, candado HTTPS, tests de autorización verdes, repo en pantalla.

## 11. Test relacionado
ReportTest (403s), AccountTest (pedido ajeno), AuthTest (throttle).

## 12. ¿Qué podría preguntarme la profesora?
Las 6 de arriba son el grupo 3.

## 13. Respuesta corta
Incluida arriba.

## 14. Problemas encontrados
Ninguno.

## 15. ¿Qué falta?
Memorizar respuesta-honesta-de-pagos (la #6) palabra por palabra.
