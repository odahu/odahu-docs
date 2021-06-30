#!/usr/bin/env bash
set -e
SRC_DIR=source
OUT_DIR=out
SKIP_PDF=false

function setup_openapi_ref() {
  echo "Fetching  ${SHORT_VERSION} branch in odahu/odahu-flow repository for open api spec"
  set +e
  http_code=$(wget -S -O "${SRC_DIR}/odahu-core-openapi.yaml" https://raw.githubusercontent.com/odahu/odahu-flow/${SHORT_VERSION}/packages/operator/docs/swagger.yaml 2>&1 | grep "HTTP/" | awk '{print $2}')
  echo "Fetching ${SHORT_VERSION} branch HTTP response code = ${http_code}"
  # Use develop branch in odahu/odahu-flow repo to fetch API specification (OpenAPI yaml config)
  # We consider that this is feature branch in docs repo and there is no corresponding branch in odahu-flow repo
  if [[ $http_code -ne 200 ]]; then
      echo "Unable to fetch ${SHORT_VERSION} branch in odahu/odahu-flow repository. Fetching develop branch..."
      wget -O "${SRC_DIR}/odahu-core-openapi.yaml"  https://raw.githubusercontent.com/odahu/odahu-flow/develop/packages/operator/docs/swagger.yaml
  fi
  set -e
}

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

setup_openapi_ref

echo "Building of HTML docs"
sphinx-build -b html "${SRC_DIR}" "${OUT_DIR}"
touch "${OUT_DIR}"/.nojekyll

ls -al out
zip -r "odahu-docs.zip" ${OUT_DIR}/*

if [ "$SKIP_PDF" = false ]; then
  echo "Building of PDF docs"
  sphinx-build -b pdf "${SRC_DIR}" "."
fi