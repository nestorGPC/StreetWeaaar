#!/usr/bin/env bash
#
# deploy-alwaysdata.sh — StreetWear CR
# Actualización segura del despliegue en alwaysdata.
#
# Este script SOLO ejecuta operaciones de actualización seguras:
#   git pull | composer install | migrate --force | caches
#
# NO borra database.sqlite, NO usa migrate:fresh, NO borra storage,
# NO resetea Git y NO hace force push.
#
# Uso:
#   bash scripts/deploy-alwaysdata.sh
#
# Requisitos previos (una sola vez):
#   1. Código clonado en ~/www/streetwear (repo: nestorGPC/StreetWeaaar)
#   2. .env de producción creado (ver DEPLOY_ALWAYSDATA.md)
#   3. database/database.sqlite creado y migrado
#
# NOTA: composer se instala CON dependencias dev porque los seeders usan
# factories que dependen de fakerphp/faker (require-dev). Sin ellas,
# `php artisan db:seed` falla con "Call to undefined function fake()".
# Si prefieres --no-dev, reemplaza la línea de composer y NO vuelvas a
# ejecutar db:seed (o reescribe los seeders para no usar faker).

set -euo pipefail

APP_DIR="${1:-$HOME/www/streetwear}"

if [ ! -d "$APP_DIR/.git" ]; then
    echo "ERROR: $APP_DIR no parece un repositorio Git (falta .git)."
    echo "Ajusta la ruta: bash scripts/deploy-alwaysdata.sh /ruta/al/proyecto"
    exit 1
fi

cd "$APP_DIR"

echo "==> [1/7] git pull (solo fast-forward)"
git pull --ff-only

echo "==> [2/7] composer install --optimize-autoloader"
composer install --no-interaction --optimize-autoloader

echo "==> [3/7] php artisan migrate --force"
php artisan migrate --force

echo "==> [4/7] php artisan optimize:clear"
php artisan optimize:clear

echo "==> [5/7] php artisan config:cache"
php artisan config:cache

echo "==> [6/7] php artisan view:cache"
php artisan view:cache

echo "==> [7/7] php artisan route:cache"
php artisan route:cache

echo ""
echo "Despliegue completado. Verifica:"
echo "  php artisan about"
echo "  https://nestor-alwaysdata-net.alwaysdata.net"
