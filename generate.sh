#!/usr/bin/env sh
set -e
SRC_DIR=source
OUT_DIR=out
SKIP_PDF=false

while [ "$#" -gt 0 ]; do
    sleep 1
    case "$1" in
    -skip-pdf)
      SKIP_PDF=true
      shift
      ;;
    -*) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    esac
done


rm -rf "${OUT_DIR}"

echo "Building of HTML docs"
sphinx-build -b html "${SRC_DIR}" "${OUT_DIR}"
touch "${OUT_DIR}"/.nojekyll

ls -al out
zip -r "odahu-docs.zip" ${OUT_DIR}/*

if [ "$SKIP_PDF" = false ]; then
  echo "Building of PDF docs"
  sphinx-build -b pdf "${SRC_DIR}" "."
fi

