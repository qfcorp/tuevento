#!/usr/bin/env bash
# Respaldo diario de TuEvento: base de datos + archivos subidos (logos, fotos, comprobantes, firmas). Guarda 14 dias.
# Cron (todos los dias a las 3:25 de la manana):
#   25 3 * * * APP=/var/www/tuevento /var/www/tuevento/deploy/respaldo.sh >> /var/log/tuevento-respaldo.log 2>&1
set -euo pipefail
umask 077   # solo el dueno del servidor puede leer los respaldos

APP="${APP:-/var/www/tuevento}"
DESTINO="${DESTINO:-/var/backups/tuevento}"
DIAS="${DIAS:-14}"

if [ ! -f "$APP/config/.env" ]; then
  echo "$(date '+%F %T') ERROR: no existe $APP/config/.env"
  exit 1
fi
# Lee los datos de conexion de config/.env
set -a
# shellcheck disable=SC1090
. <(grep -E '^TUEVENTO_(DB_HOST|DB_NAME|DB_USER|DB_PASS|UPLOADS)=' "$APP/config/.env")
set +a
export PGPASSWORD="${TUEVENTO_DB_PASS:-}"
UPLOADS="${TUEVENTO_UPLOADS:-$APP/uploads}"

FECHA=$(date +%Y-%m-%d_%H%M)
mkdir -p "$DESTINO"
chmod 700 "$DESTINO"

pg_dump -h "${TUEVENTO_DB_HOST:-127.0.0.1}" -U "${TUEVENTO_DB_USER:-tuevento}" -Fc "${TUEVENTO_DB_NAME:-tuevento}" > "$DESTINO/base_$FECHA.dump"
if [ -d "$UPLOADS" ]; then
  tar -czf "$DESTINO/archivos_$FECHA.tar.gz" -C "$(dirname "$UPLOADS")" "$(basename "$UPLOADS")"
fi

# Verifica que el respaldo se pueda leer
pg_restore --list "$DESTINO/base_$FECHA.dump" > /dev/null

# Borra respaldos de mas de $DIAS dias
find "$DESTINO" -name 'base_*.dump' -mtime +"$DIAS" -delete
find "$DESTINO" -name 'archivos_*.tar.gz' -mtime +"$DIAS" -delete

echo "$(date '+%F %T') respaldo OK: base $(du -h "$DESTINO/base_$FECHA.dump" | cut -f1)$([ -f "$DESTINO/archivos_$FECHA.tar.gz" ] && echo ", archivos $(du -h "$DESTINO/archivos_$FECHA.tar.gz" | cut -f1)")"
