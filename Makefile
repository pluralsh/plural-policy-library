REPO ?= $(shell ./hack/git-clone-repo.sh pluralsh/gke-policy-library --branch main)

update-bundles: ## copy bundles from https://github.com/pluralsh/gke-policy-library
	cp  -rf $(REPO)/bundles ./



