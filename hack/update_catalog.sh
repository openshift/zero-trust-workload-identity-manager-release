#!/usr/bin/env bash


declare OPM_TOOL_PATH
declare OPERATOR_BUNDLE_IMAGE
declare CATALOG_DIR
declare BUNDLE_FILE_NAME
declare REPLICATE_BUNDLE_FILE_IN_CATALOGS
declare USE_MIGRATE_LEVEL_FLAG

ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_CATALOG_NAME="openshift-zero-trust-workload-identity-manager"

render_catalog_bundle()
{
  render_cmd_args=""
  # --migrate-level=bundle-object-to-csv-metadata is used for creating bundle metadata in `olm.csv.metadata` format.
  # Refer https://github.com/konflux-ci/build-definitions/blob/main/task/fbc-validation/0.1/TROUBLESHOOTING.md for details.
  if [[ ${USE_MIGRATE_LEVEL_FLAG} == "yes" ]]; then
    render_cmd_args="--migrate-level=bundle-object-to-csv-metadata"
  fi

  bundle_file="${CATALOG_DIR}/${ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_CATALOG_NAME}/${BUNDLE_FILE_NAME}"
  echo "[$(date)] -- INFO  -- generating catalog bundle \"${bundle_file}\""
  if ! "${OPM_TOOL_PATH}" render "${OPERATOR_BUNDLE_IMAGE}" $render_cmd_args -o yaml > "${bundle_file}"; then
    echo "[$(date)] -- ERROR -- failed to render catalog bundle"
    exit 1
  fi

  if ! "${OPM_TOOL_PATH}" validate "${CATALOG_DIR}"; then
    echo "[$(date)] -- ERROR -- failed to validate catalog"
    exit 1
  fi
}

usage()
{
	echo -e "usage:\n\t$(basename "${BASH_SOURCE[0]}")" \
		'"<OPM_TOOL_PATH>"' \
		'"<OPERATOR_BUNDLE_IMAGE>"' \
		'"<CATALOG_DIR>"' \
		'"<BUNDLE_FILE_NAME>"' \
		'"<REPLICATE_BUNDLE_FILE_IN_CATALOGS>"' \
		'"<USE_MIGRATE_LEVEL_FLAG>"'
	exit 1
}

replicate_catalog_bundle()
{
  if [[ "${REPLICATE_BUNDLE_FILE_IN_CATALOGS}" == "no" ]]; then
    return
  fi

  bundle_file="${CATALOG_DIR}/${ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_CATALOG_NAME}/${BUNDLE_FILE_NAME}"

  find catalogs/*/catalog/openshift-zero-trust-workload-identity-manager -type d ! -path "${CATALOG_DIR}/*" -exec /bin/cp "${bundle_file}" {} \; -print
}

##############################################
###############  MAIN  #######################
##############################################

if [[ $# -ne 6 ]]; then
  usage
fi

OPM_TOOL_PATH=$1
OPERATOR_BUNDLE_IMAGE=$2
CATALOG_DIR=$3
BUNDLE_FILE_NAME=$4
REPLICATE_BUNDLE_FILE_IN_CATALOGS=$5
USE_MIGRATE_LEVEL_FLAG=$6

echo "[$(date)] -- INFO  -- $*"

if [[ ! -d "${CATALOG_DIR}" ]]; then
  echo "[$(date)] -- ERROR -- catalog directory \"${CATALOG_DIR}\" does not exist"
	exit 1
fi

if [[ ! -x "${OPM_TOOL_PATH}" ]]; then
  echo "[$(date)] -- ERROR -- \"${OPM_TOOL_PATH}\" does not exist or does not execute permissions"
  exit 1
fi

if [[ -z "${BUNDLE_FILE_NAME}" ]]; then
  echo "[$(date)] -- ERROR -- \"\" bundle file name cannot be empty"
  exit 1
fi

if [[ -z "${REPLICATE_BUNDLE_FILE_IN_CATALOGS}" ]] || [[ "${REPLICATE_BUNDLE_FILE_IN_CATALOGS}" != @(yes|no) ]]; then
  echo "[$(date)] -- ERROR -- invalid value provided for \"REPLICATE_BUNDLE_FILE_IN_CATALOGS\", must be \"yes\" or \"no\""
  exit 1
fi

if [[ -z "${USE_MIGRATE_LEVEL_FLAG}" ]] || [[ "${USE_MIGRATE_LEVEL_FLAG}" != @(yes|no) ]]; then
  echo "[$(date)] -- ERROR -- invalid value provided for \"USE_MIGRATE_LEVEL_FLAG\", must be \"yes\" or \"no\""
  exit 1
fi

render_catalog_bundle

replicate_catalog_bundle

exit 0