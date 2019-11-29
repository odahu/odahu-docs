#!/usr/bin/env sh
set -e

SRC_DIR=source
OUT_DIR=out

rm -rf "${OUT_DIR}"

echo "Building of HTML docs"
sphinx-build -b html "${SRC_DIR}" "${OUT_DIR}"
touch "${OUT_DIR}"/.nojekyll

ls -al out
zip -r "odahu-docs.zip" ${OUT_DIR}/*

echo "Building of PDF docs"
sphinx-build -b pdf "${SRC_DIR}" "."
