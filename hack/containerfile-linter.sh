#!/usr/bin/env bash

declare -a CONTAINERFILES
declare -a ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_CONTAINERFILES


linter()
{
	containerfiles=("$@")
	for containerfile in "${containerfiles[@]}"; do
		if [[ ! -f "${containerfile}" ]]; then
			echo "[$(date)] -- ERROR -- ${containerfile} does not exist"
			exit 1
		fi
		echo "[$(date)] -- INFO  -- running linter on ${containerfile}"
		if ! podman run --rm -i -e "HADOLINT_FAILURE_THRESHOLD=error" ghcr.io/hadolint/hadolint < "${containerfile}" ; then
			exit 1
		fi
	done
}

containerfile_linter()
{
	if [[ "${#CONTAINERFILES[@]}" -gt 0 ]]; then
		linter "${CONTAINERFILES[@]}"
		return
	fi
	mapfile -t ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_CONTAINERFILES < <(find . -type f -name 'Containerfile*' '!' -path './zero-trust-workload-identity-manager/*' '!' -path './spiffe-spire/*' '!' -path './spiffe-spiffe-helper/*' '!' -path './spiffe-spire-controller-manager/*' '!' -path './spiffe-spiffe-csi/*' '!' -path './spiffe-go-spiffe/*')
	echo "[$(date)] -- INFO  -- running linter on ${ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_CONTAINERFILES[*]}"
	linter "${ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_CONTAINERFILES[@]}"
}

##############################################
###############  MAIN  #######################
##############################################

if [[ $# -ge 1 ]]; then
	CONTAINERFILES=("$@")
	echo "[$(date)] -- INFO  -- running linter on $*"
fi

containerfile_linter

exit 0
