#!/usr/bin/env bash

set -x

declare MANIFESTS_DIR
declare METADATA_DIR
declare IMAGES_DIGEST_CONF_FILE
declare ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_IMAGE
declare SPIRE_SERVER_IMAGE
declare SPIRE_AGENT_IMAGE
declare SPIFFE_CSI_DRIVER_IMAGE
declare SPIRE_OIDC_DISCOVERY_PROVIDER_IMAGE
declare SPIRE_CONTROLLER_MANAGER_IMAGE
declare SPIFFE_HELPER_IMAGE
declare NODE_DRIVER_REGISTRAR_IMAGE
declare SPIFFE_CSI_INIT_CONTAINER_IMAGE

CSV_FILE_NAME="zero-trust-workload-identity-manager.clusterserviceversion.yaml"
ANNOTATIONS_FILE_NAME="annotations.yaml"
GREEN_COLOR_TEXT='\033[0;32m'
RED_COLOR_TEXT='\033[0;31m'
REVERT_COLOR_TEXT='\033[0m'

log_info()
{
	echo -e "[$(date)] ${GREEN_COLOR_TEXT}-- INFO  --${REVERT_COLOR_TEXT} ${1}"
}

log_error()
{
	echo -e "[$(date)] ${RED_COLOR_TEXT}-- ERROR --${REVERT_COLOR_TEXT} ${1}"
}

update_csv_manifest()
{
	CSV_FILE="${MANIFESTS_DIR}/${CSV_FILE_NAME}"
	if [[ ! -f "${CSV_FILE}" ]]; then
		log_error "operator csv file \"${CSV_FILE}\" does not exist"
		exit 1
	fi

	sed -i "s#openshift.io/zero-trust-workload-identity-manager.*#${ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_IMAGE}#g" "${CSV_FILE}"
	sed -i "s#ghcr.io/spiffe/spire-server.*#${SPIRE_SERVER_IMAGE}#g" "${CSV_FILE}"
	sed -i "s#ghcr.io/spiffe/spire-agent.*#${SPIRE_AGENT_IMAGE}#g" "${CSV_FILE}"
	sed -i "s#ghcr.io/spiffe/spiffe-csi-driver.*#${SPIFFE_CSI_DRIVER_IMAGE}#g" "${CSV_FILE}"
	sed -i "s#ghcr.io/spiffe/oidc-discovery-provider.*#${SPIRE_OIDC_DISCOVERY_PROVIDER_IMAGE}#g" "${CSV_FILE}"
	sed -i "s#ghcr.io/spiffe/spire-controller-manager.*#${SPIRE_CONTROLLER_MANAGER_IMAGE}#g" "${CSV_FILE}"
	sed -i "s#ghcr.io/spiffe/spiffe-helper.*#${SPIFFE_HELPER_IMAGE}#g" "${CSV_FILE}"
	sed -i "s#registry.k8s.io/sig-storage/csi-node-driver-registrar.*#${NODE_DRIVER_REGISTRAR_IMAGE}#g" "${CSV_FILE}"
	sed -i "s#registry.access.redhat.com/ubi9.*#${SPIFFE_CSI_INIT_CONTAINER_IMAGE}#g" "${CSV_FILE}"

	## add annotations
	yq e -i ".metadata.annotations.createdAt=\"$(date -u +'%Y-%m-%dT%H:%M:%S')\"" "${CSV_FILE}"
}

update_annotations_metadata() {
	ANNOTATION_FILE="${METADATA_DIR}/${ANNOTATIONS_FILE_NAME}"
	if [[ ! -f ${ANNOTATION_FILE} ]]; then
		log_error "annotations metadata file \"${CSV_FILE}\" does not exist"
		exit 1
	fi

	# add annotations
	yq e -i '.annotations."operators.operatorframework.io.bundle.package.v1"="openshift-zero-trust-workload-identity-manager"' "${ANNOTATION_FILE}"
}

usage()
{
	echo -e "usage:\n\t$(basename "${BASH_SOURCE[0]}")" \
		'"<MANIFESTS_DIR>"' \
		'"<METADATA_DIR>"' \
		'"<IMAGES_DIGEST_CONF_FILE>"'
	exit 1
}

##############################################
###############  MAIN  #######################
##############################################

if [[ $# -lt 3 ]]; then
	usage
fi

MANIFESTS_DIR=$1
METADATA_DIR=$2
IMAGES_DIGEST_CONF_FILE=$3

log_info "$*"

if [[ ! -d ${MANIFESTS_DIR} ]]; then
	log_error "manifests directory \"${MANIFESTS_DIR}\" does not exist"
	exit 1
fi

if [[ ! -d ${METADATA_DIR} ]]; then
	log_error "metadata directory \"${METADATA_DIR}\" does not exist"
	exit 1
fi

if [[ ! -f ${IMAGES_DIGEST_CONF_FILE} ]]; then
	log_error "image digests conf file \"${IMAGES_DIGEST_CONF_FILE}\" does not exist"
	exit 1
fi

# shellcheck source=/dev/null
source "${IMAGES_DIGEST_CONF_FILE}"

if [[ -z ${SPIRE_SERVER_IMAGE} ]] || [[ -z ${SPIRE_AGENT_IMAGE} ]] || [[ -z ${SPIFFE_CSI_DRIVER_IMAGE} ]] || [[ -z ${SPIRE_OIDC_DISCOVERY_PROVIDER_IMAGE} ]] || [[ -z ${SPIRE_CONTROLLER_MANAGER_IMAGE} ]] || [[ -z ${SPIFFE_HELPER_IMAGE} ]] || [[ -z ${NODE_DRIVER_REGISTRAR_IMAGE} ]] || [[ -z ${ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_IMAGE} ]] || [[ -z ${SPIFFE_CSI_INIT_CONTAINER_IMAGE} ]]; then
	log_error "\"${SPIRE_SERVER_IMAGE}\" or \"${SPIRE_AGENT_IMAGE}\"  or \"${SPIFFE_CSI_DRIVER_IMAGE}\"  or \"${SPIRE_OIDC_DISCOVERY_PROVIDER_IMAGE}\"  or \"${SPIRE_CONTROLLER_MANAGER_IMAGE}\"  or \"${SPIFFE_HELPER_IMAGE}\" or \"${NODE_DRIVER_REGISTRAR_IMAGE}\" or \"${ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_IMAGE}\ or \"${SPIFFE_CSI_INIT_CONTAINER_IMAGE}\" is not set"
	exit 1
fi

update_csv_manifest
update_annotations_metadata

exit 0