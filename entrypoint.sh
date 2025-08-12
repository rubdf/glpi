#!/usr/bin/env bash
set -euo pipefail

DOCROOT="${HTTPD_DOCUMENT_ROOT:-/opt/app-root/src}"
ORIG="/opt/app-root/glpi-orig"

mkdir -p "$DOCROOT"

# Se o docroot estiver vazio (primeira execução com volume/pasta montada), copia o GLPI "orig"
if [ -z "$(ls -A "$DOCROOT" 2>/dev/null || true)" ]; then
  echo "[init] Populando GLPI em ${DOCROOT}..."
  cp -a "${ORIG}/." "${DOCROOT}/"
fi

# Ajusta permissões a cada start (útil para bind/pvc)
chgrp -R 0 "$DOCROOT" "$ORIG" || true
chmod -R g+rwX "$DOCROOT" "$ORIG" || true

# Chama o run padrão da imagem S2I (Apache + PHP-FPM)
exec "$@"
