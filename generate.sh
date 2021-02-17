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

echo "Fetching swagger spec for ODAHU API"
wget -O "${SRC_DIR}/odahu-core-openapi.yaml"  https://raw.githubusercontent.com/odahu/odahu-flow/feat/batch-test/packages/operator/docs/swagger.yaml

echo "Building of HTML docs"
sphinx-build -b html "${SRC_DIR}" "${OUT_DIR}"
touch "${OUT_DIR}"/.nojekyll

ls -al out
zip -r "odahu-docs.zip" ${OUT_DIR}/*

