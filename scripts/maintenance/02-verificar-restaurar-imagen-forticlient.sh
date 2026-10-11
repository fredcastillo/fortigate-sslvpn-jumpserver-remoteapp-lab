#!/usr/bin/env bash
# Ejecutar en GNS3 VM. No reinicia ni elimina el nodo GNS3.
set -euo pipefail
SOURCE='lab-backup/forticlient-vnc-firefox:20261009'
ORIGINAL='lab-backup/forticlient-original-before-vnc:20261009'
TARGET='forticlient-lite:7.2-fix3'

for img in "$SOURCE" "$ORIGINAL"; do
  if ! docker image inspect "$img" >/dev/null 2>&1; then
    echo "ERROR: falta la imagen de respaldo requerida: $img" >&2
    exit 1
  fi
done

SRC_ID="$(docker image inspect --format '{{.Id}}' "$SOURCE")"
if ! docker image inspect "$TARGET" >/dev/null 2>&1 || \
   [ "$(docker image inspect --format '{{.Id}}' "$TARGET")" != "$SRC_ID" ]; then
  echo "Actualizando etiqueta $TARGET a la imagen validada $SOURCE"
  docker tag "$SOURCE" "$TARGET"
else
  echo "La etiqueta $TARGET ya apunta a la imagen esperada."
fi

echo
printf 'ORIGINAL: '; docker image inspect "$ORIGINAL" --format '{{.Id}} {{.Size}} bytes'
printf 'WORKING:  '; docker image inspect "$SOURCE" --format '{{.Id}} {{.Size}} bytes'
printf 'TARGET:   '; docker image inspect "$TARGET" --format '{{.Id}} {{.Size}} bytes'
echo
echo 'Versión Firefox en imagen guardada:'
docker run --rm --entrypoint /usr/bin/firefox "$SOURCE" --version
echo
echo 'Sintaxis del script de arranque:'
docker run --rm --entrypoint /bin/bash "$SOURCE" -lc 'bash -n /usr/local/bin/start.sh && grep -nE "DISPLAY|firefox" /usr/local/bin/start.sh'
echo
echo 'Verificación completada. Si GNS3 conserva un contenedor antiguo en estado Created, reiniciar puede no bastar para recrearlo con la imagen nueva; conserva nodo/topología y revisa la plantilla antes de eliminar nada.'
