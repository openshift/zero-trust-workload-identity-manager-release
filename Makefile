## local variables.

zero_trust_workload_identity_manager_submodule_dir = zero-trust-workload-identity-manager
zero_trust_workload_identity_manager_containerfile_name = Containerfile.zero-trust-workload-identity-manager
zero_trust_workload_identity_manager_bundle_containerfile_name = Containerfile.zero-trust-workload-identity-manager.bundle

spiffe_spire_submodule_dir = spiffe-spire
spiffe_spire_containerfile_name = Containerfile.spiffe-spire

spiffe_spire_controller_manager_submodule_dir = spiffe-spire-controller-manager
spiffe_spire_controller_manager_containerfile_name = Containerfile.spiffe-spire-controller-manager

spiffe_spiffe_helper_submodule_dir = spiffe-spiffe-helper
spiffe_spiffe_helper_containerfile_name = Containerfile.spiffe-spiffe-helper

spiffe_spiffe_csi_submodule_dir = spiffe-spiffe-csi
spiffe_spiffe_csi_containerfile_name = Containerfile.spiffe-spiffe-csi

spiffe_go_spiffe_submodule_dir = spiffe-go-spiffe
spiffe_go_spiffe_containerfile_name = Containerfile.spiffe-go-spiffe



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

## current branch name of the spiffe-spiffe-helper submodule.
SPIFFE_SPIFFE_HELPER_BRANCH ?= $(LOCAL_BRANCH_NAME)

## current branch name of the spiffe-go-spiffe submodule.
SPIFFE_GO_SPIFFE_BRANCH ?= $(LOCAL_BRANCH_NAME)

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

## image name for spiffe-spiffe-csi.
SPIFFE_SPIFFE_CSI_IMAGE ?= spiffe-spiffe-csi

## image name for spiffe-spiffe-helper.
SPIFFE_SPIFFE_HELPER_IMAGE ?= spiffe-spiffe-helper

## image name for spiffe-go-spiffe.
SPIFFE_GO_SPIFFE_IMAGE ?= spiffe-go-spiffe


## image version to tag the created images with.
IMAGE_VERSION ?= $(release_version)

## image tag makes use of the branch name and
## when branch name is `main` use `latest` as the tag.
ifeq ($(release_version), main)
IMAGE_VERSION = latest
endif

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
	cd $(spiffe_spiffe_helper_submodule_dir); git checkout $(SPIFFE_SPIFFE_HELPER_BRANCH); cd - > /dev/null
	cd $(spiffe_go_spiffe_submodule_dir); git checkout $(SPIFFE_GO_SPIFFE_BRANCH); cd - > /dev/null
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
	git submodule update --remote $(spiffe_go_spiffe_submodule_dir)
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
	$(IMAGE_BUILD_CMD) -f $(spiffe_spiffe_csi_containerfile_name) -t $(SPIFFE_SPIFFE_CSI_IMAGE):$(IMAGE_VERSION) .

## build all operand images
.PHONY: build-operand-images
build-operand-images: build-spiffe-spire-image

## build operator bundle image.
.PHONY: build-bundle-image
build-bundle-image:
	$(IMAGE_BUILD_CMD) -f $(zero_trust_workload_identity_manager_bundle_containerfile_name) -t $(ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_BUNDLE_IMAGE):$(IMAGE_VERSION) .

## build operand cert-manager image.
.PHONY: build-spiffe-spire-image
build-spiffe-spire-image:
	$(IMAGE_BUILD_CMD) -f $(spiffe_spire_containerfile_name) -t $(SPIFFE_SPIRE_IMAGE):$(IMAGE_VERSION) .

## build operand cert-manager image.
.PHONY: build-spiffe-helper-image
build-spiffe-helper-image:
	$(IMAGE_BUILD_CMD) -f $(spiffe_spiffe_helper_containerfile_name) -t $(SPIFFE_SPIFFE_HELPER_IMAGE):$(IMAGE_VERSION) .

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
	podman rmi -i $(ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_IMAGE):$(IMAGE_VERSION) \
$(SPIFFE_SPIRE_IMAGE):$(IMAGE_VERSION) \
$(SPIFFE_SPIRE_CONTROLLER_MANAGER_IMAGE):$(IMAGE_VERSION) \
$(SPIFFE_SPIFFE_CSI_IMAGE):$(IMAGE_VERSION) \
$(SPIFFE_SPIFFE_HELPER_IMAGE):$(IMAGE_VERSION) \
$(SPIFFE_GO_SPIFFE_IMAGE):$(IMAGE_VERSION) \
$(ZERO_TRUST_WORKLOAD_IDENTITY_MANAGER_BUNDLE_IMAGE):$(IMAGE_VERSION)

## validate renovate config.
.PHONY: validate-renovate-config
validate-renovate-config:
	./hack/renovate-config-validator.sh
