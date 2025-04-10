# OpenShift Zero Trust Workload Identity Manager Release Tooling

This repository holds release specific content for zero-trust-workload-identity-manager mainly the Containerfiles which comply with the
requirements for releasing builds through konflux. Repository also holds tekton configuration code added by konflux bots
and `zero-trust-workload-identity-manager` and operands (`spiffe-spire`, `spiffe-spire-controller-manager`, `spiffe-spiffe-helper`, `spiffe-spiffe-csi` and `spiffe-go-spiffe`) repositories are added as git submodules.

## Getting started

Use below command to clone the project since it has submodules configured. By default, when we clone a project with
submodules configured, the directories of the submodules are created but will not be initialized with content. With
below command, it will automatically initialize and update each submodule in the repository, including nested submodules
if any of the submodules in the repository have submodules themselves.
```console
git clone --recurse-submodules https://github.com/openshift/zero-trust-workload-identity-manager-release.git
```

OR

```console
git clone --recurse-submodules `fork_repository_web_url`
```

## Repository structure

Repository contains below repositories added as git submodules which was created to keep release specific content
outside the main code repository for better management.
- [zero-trust-workload-identity-manager](https://github.com/openshift/zero-trust-workload-identity-manager)
- [spiffe-spire](https://github.com/openshift/spiffe-spire)
- [spiffe-spire-controller-manager](https://github.com/openshift/spiffe-spire-controller-manager)
- [spiffe-spiffe-csi](https://github.com/openshift/spiffe-spiffe-csi)
- [spiffe-spiffe-helper](https://github.com/openshift/spiffe-spiffe-helper)
- [spiffe-go-spiffe](https://github.com/openshift/spiffe-go-spiffe)

In each release branch the git submodules are configured with equivalent release branch in their respective origin
repositories. And when switching the parent repository between different branches, the submodule branches will not be
automatically switched and requires using below command for the same.
```console
make switch-submodules-branch
```

## Updating submodules

Use below command to update submodules to the revision same as their origin repository using below command.
```console
make update-submodules
```

## Other commands

Use the command below to get usage summary and interact with the repository.
```console
make help
```