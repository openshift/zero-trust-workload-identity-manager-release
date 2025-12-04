## local variables.

zero_trust_workload_identity_manager_submodule_dir = zero-trust-workload-identity-manager
zero_trust_workload_identity_manager_containerfile_name = Containerfile.zero-trust-workload-identity-manager
zero_trust_workload_identity_manager_bundle_containerfile_name = Containerfile.zero-trust-workload-identity-manager.bundle

spiffe_spire_submodule_dir = spiffe-spire

spiffe_spire_controller_manager_submodule_dir = spiffe-spire-controller-manager
spiffe_spire_controller_manager_containerfile_name = Containerfile.spiffe-spire-controller-manager


spiffe_spire_server_containerfile_name = Containerfile.spire-server
spiffe_spire_agent_containerfile_name = Containerfile.spire-agent
spiffe_spire_oidc_discovery_provider_containerfile_name = Containerfile.spire-oidc-discovery-provider


spiffe_spiffe_csi_submodule_dir = spiffe-spiffe-csi
spiffe_spiffe_csi_containerfile_name = Containerfile.spiffe-spiffe-csi

spiffe_spiffe_helper_submodule_dir = spiffe-spiffe-helper
spiffe_spiffe_helper_containerfile_name = Containerfile.spiffe-spiffe-helper


commit_sha = $(strip $(shell git rev-parse HEAD))
source_url = $(strip $(shell git remote get-url origin))
release_version = v$(strip $(shell git branch --show-current | cut -d'-' -f2))

## current local branch name which will be used for updating submodules.
LOCAL_BRANCH_NAME ?= $(strip $(shell git branch --show-current))

## current branch name of the spiffe-spire submodule.
SPIFFE_SPIRE_BRANCH ?= $(LOCAL_BRANCH_NAME)

## current branch name of the spiffe-spire-controller-manager submodule.
SPIFFE_SPIRE_CONTROLLER_MANAGER_BRANCH ?= $(LOCAL_BRANCH_NAME)

## current branch name of the spiffe-spiffe-csi submodule.
SPIFFE_SPIFFE_CSI_BRANCH ?= $(LOCAL_BRANCH_NAME)


## current branch name of the zero-trust-workload-identity-manager submodule
ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_BRANCH ?= $(LOCAL_BRANCH_NAME)

## container build tool to use for creating images.
CONTAINER_ENGINE ?= docker

## image name for zero-trust-workload-identity-manager.
ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_IMAGE ?= zero-trust-workload-identity-manager

## image name for zero-trust-workload-identity-manager-bundle.
ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_BUNDLE_IMAGE ?= zero-trust-workload-identity-manager-bundle

## image name for spiffe-spire.
SPIFFE_SPIRE_IMAGE ?= spiffe-spire

## image name for spiffe-spire-controller-manager.
SPIFFE_SPIRE_CONTROLLER_MANAGER_IMAGE ?= spiffe-spire-controller-manager


SPIFFE_SPIRE_SERVER_IMAGE ?= spire-server

SPIFFE_SPIRE_AGENT_IMAGE ?= spire-agent

SPIFFE_SPIRE_OIDC_DISCOVERY_PROVIDER_IMAGE ?= spire-oidc-discovery-provider

## image name for spiffe-spiffe-csi.
SPIFFE_SPIFFE_CSI_IMAGE ?= spiffe-spiffe-csi

## image name for spiffe-spiffe-helper
SPIFFE_SPIFFE_HELPER_IMAGE ?= spiffe-spiffe-helper


## image version to tag the created images with.
IMAGE_VERSION ?= 1.0.0

SPIFFE_SPIRE_IMAGE_VERSION ?= v1.13.3
SPIFFE_CSI_IMAGE_VERSION ?= v0.2.8
SPIFFE_SPIRE_CONTROLLER_MANAGER_IMAGE_VERSION ?= v0.6.3
SPIFFE_SPIFFE_HELPER_IMAGE_VERSION ?= v0.10.0

## args to pass during image build
IMAGE_BUILD_ARGS ?= --build-arg RELEASE_VERSION=$(release_version) --build-arg COMMIT_SHA=$(commit_sha) --build-arg SOURCE_URL=$(source_url)

## tailored command to build images.
IMAGE_BUILD_CMD = $(CONTAINER_ENGINE) build $(IMAGE_BUILD_ARGS)

.DEFAULT_GOAL := help
## usage summary.
.PHONY: help
help:
	@ echo
	@ echo '  Usage:'
	@ echo ''
	@ echo '    make <target> [flags...]'
	@ echo ''
	@ echo '  Targets:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?:/{ print "   ", $$1, comment }' $(MAKEFILE_LIST) | column -t -s ':' | sort
	@ echo ''
	@ echo '  Flags:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?\?=/{ print "   ", $$1, $$2, comment }' $(MAKEFILE_LIST) | column -t -s '?=' | sort
	@ echo ''

## execute all required targets.
.PHONY: all
all: verify

## checkout submodules branch to match the parent branch.
.PHONY: switch-submodules-branch
switch-submodules-branch:
	cd $(spiffe_spire_submodule_dir); git checkout $(SPIFFE_SPIRE_BRANCH); cd - > /dev/null
	cd $(spiffe_spire_controller_manager_submodule_dir); git checkout $(SPIFFE_SPIRE_CONTROLLER_MANAGER_BRANCH); cd - > /dev/null
	cd $(spiffe_spiffe_csi_submodule_dir); git checkout $(SPIFFE_SPIFFE_CSI_BRANCH); cd - > /dev/null
	cd $(zero_trust_workload_identity_manager_submodule_dir); git checkout $(ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_BRANCH); cd - > /dev/null
	# update with local cache.
	git submodule update

## update submodules revision to match the revision of the origin repository.
.PHONY: update-submodules
update-submodules:
	git submodule update --remote $(spiffe_spire_submodule_dir)
	git submodule update --remote $(spiffe_spire_controller_manager_submodule_dir)
	git submodule update --remote $(spiffe_spiffe_csi_submodule_dir)
	git submodule update --remote $(spiffe_spiffe_helper_submodule_dir)
	git submodule update --remote $(zero_trust_workload_identity_manager_submodule_dir)

## build all the images - operator, operand and operator-bundle.
.PHONY: build-images
build-images: build-operand-images build-operator-image build-bundle-image

## build operator image.
.PHONY: build-operator-image
build-operator-image:
	$(IMAGE_BUILD_CMD) -f $(zero_trust_workload_identity_manager_containerfile_name) -t $(ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_IMAGE):$(IMAGE_VERSION) .

## build spiffe-csi image.
.PHONY: build-spiffe-csi-image
build-spiffe-csi-image:
	$(IMAGE_BUILD_CMD) -f $(spiffe_spiffe_csi_containerfile_name) -t $(SPIFFE_SPIFFE_CSI_IMAGE):$(SPIFFE_CSI_IMAGE_VERSION) .

## build spiffe-helper image.
.PHONY: build-spiffe-helpfer-image
build-spiffe-helpfer-image:
	$(IMAGE_BUILD_CMD) -f $(spiffe_spiffe_helper_containerfile_name) -t $(SPIFFE_SPIFFE_HELPER_IMAGE):$(SPIFFE_SPIFFE_HELPER_IMAGE_VERSION) .

## build all operand images
.PHONY: build-operand-images
build-operand-images: build-spiffe-csi-image build-spiffe-helpfer-image build-spire-agent-image build-spire-controller-manager-image build-spire-server-image build-spire-oidc-discovery-provider-image

## build operator bundle image.
.PHONY: build-bundle-image
build-bundle-image:
	$(IMAGE_BUILD_CMD) -f $(zero_trust_workload_identity_manager_bundle_containerfile_name) -t $(ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_BUNDLE_IMAGE):$(IMAGE_VERSION) .

## build operand spire-controller-manager image.
.PHONY: build-spire-controller-manager-image
build-spire-controller-manager-image:
	$(IMAGE_BUILD_CMD) -f $(spiffe_spire_controller_manager_containerfile_name) -t $(SPIFFE_SPIRE_CONTROLLER_MANAGER_IMAGE):$(SPIFFE_SPIRE_CONTROLLER_MANAGER_IMAGE_VERSION) .

## build operand spire-controller-manager image.
.PHONY: build-spire-server-image
build-spire-server-image:
	$(IMAGE_BUILD_CMD) -f $(spiffe_spire_server_containerfile_name) -t $(SPIFFE_SPIRE_SERVER_IMAGE):$(SPIFFE_SPIRE_IMAGE_VERSION) .

.PHONY: build-spire-agent-image
build-spire-agent-image:
	$(IMAGE_BUILD_CMD) -f $(spiffe_spire_agent_containerfile_name) -t $(SPIFFE_SPIRE_AGENT_IMAGE):$(SPIFFE_SPIRE_IMAGE_VERSION) .

.PHONY: build-spire-oidc-discovery-provider-image
build-spire-oidc-discovery-provider-image:
	$(IMAGE_BUILD_CMD) -f $(spiffe_spire_oidc_discovery_provider_containerfile_name) -t $(SPIFFE_SPIRE_OIDC_DISCOVERY_PROVIDER_IMAGE):$(SPIFFE_SPIRE_IMAGE_VERSION) .

## check shell scripts.
.PHONY: verify-shell-scripts
verify-shell-scripts:
	./hack/shell-scripts-linter.sh

## check containerfiles.
.PHONY: verify-containerfiles
verify-containerfiles:
	./hack/containerfile-linter.sh

## verify the changes are working as expected.
.PHONY: verify
verify: verify-shell-scripts verify-containerfiles validate-renovate-config

## update all required contents.
.PHONY: update
update: update-submodules

## clean up temp dirs, images.
.PHONY: clean
clean:
	$(CONTAINER_ENGINE) rmi \
		$(ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_IMAGE):$(IMAGE_VERSION) \
		$(SPIFFE_SPIRE_SERVER_IMAGE):$(SPIFFE_SPIRE_IMAGE_VERSION) \
		$(SPIFFE_SPIRE_AGENT_IMAGE):$(SPIFFE_SPIRE_IMAGE_VERSION) \
		$(SPIFFE_SPIRE_OIDC_DISCOVERY_PROVIDER_IMAGE):$(SPIFFE_SPIRE_IMAGE_VERSION) \
		$(SPIFFE_SPIRE_CONTROLLER_MANAGER_IMAGE):$(IMAGE_VERSION) \
		$(SPIFFE_SPIFFE_CSI_IMAGE):$(SPIFFE_CSI_IMAGE_VERSION) \
		$(SPIFFE_SPIFFE_HELPER_IMAGE):$(SPIFFE_SPIFFE_HELPER_IMAGE_VERSION) \
		$(ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_BUNDLE_IMAGE):$(IMAGE_VERSION)



## validate renovate config.
.PHONY: validate-renovate-config
validate-renovate-config:
	./hack/renovate-config-validator.sh
