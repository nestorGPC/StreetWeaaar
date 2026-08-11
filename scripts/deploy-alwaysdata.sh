#!/usr/bin/env bash
#
# deploy-alwaysdata.sh — StreetWear CR
# Actualización segura del despliegue en alwaysdata.
#
# Este script SOLO ejecuta operaciones de actualización seguras:
#   git pull | composer install --no-dev | migrate --force | caches
#
# NO borra database.sqlite, NO usa migrate:fresh, NO borra storage,
# NO resetea Git y NO hace force push.
#
# Uso:
#   bash scripts/deploy-alwaysdata.sh
#
# Requisitos previos (una sola vez):
#   1. Código clonado en ~/www/streetwear
#   2. .env de producción creado (ver DEPLOY_ALWAYSDATA.md)
#   3. database/database.sqlite creado y migrado

set -euo pipefail

APP_DIR="${1:-$HOME/www/streetwear}"

if [ ! -d "$APP_DIR/.git" ]; then
    echo "ERROR: $APP_DIR no parece un repositorio Git (falta .git)."
    echo "Ajusta la ruta: bash scripts/deploy-alwaysdata.sh /ruta/al/proyecto"
    exit 1
fi

cd "$APP_DIR"

echo "==> [1/6] git pull"
git pull --ff-only

echo "==> [2/6] composer install --no-dev --optimize-autoloader"
composer install --no-dev --optimize-autoloader --no-interaction

echo "==> [3/6] php artisan migrate --force"
php artisan migrate --force

echo "==> [4/6] php artisan optimize:clear"
php artisan optimize:clear

echo "==> [5/6] php artisan config:cache"
php artisan config:cache

echo "==> [6/6] php artisan view:cache"
php artisan view:cache

echo ""
echo "Despliegue completado. Verifica:"
echo "  php artisan about"
echo "  https://USUARIO_ALWAYSDATA.alwaysdata.net"
