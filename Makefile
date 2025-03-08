# Copyright 2025 dah4k
# SPDX-License-Identifier: EPL-2.0

DOCKER      ?= docker
REGISTRY    ?= local
IMAGES      ?= pulumi-devcontainer
TAGS        ?= $(addprefix $(REGISTRY)/,$(IMAGES))
_ANSI_NORM  := \033[0m
_ANSI_CYAN  := \033[36m

.PHONY: help usage
help usage:
	@grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?##"}; {printf "$(_ANSI_CYAN)%-20s$(_ANSI_NORM) %s\n", $$1, $$2}'

.PHONY: all
all: $(TAGS) ## Build all container images

$(REGISTRY)/%: Dockerfile.%
	$(DOCKER) build --tag $@ --file $< .

.PHONY: test
test: $(REGISTRY)/pulumi-devcontainer ## Test runtime container image
	$(DOCKER) run --interactive --tty --rm --name=pulumi-devcontainer $<

.PHONY: clean
clean: ## Remove all container images
	$(DOCKER) stop pulumi-devcontainer || true
	$(DOCKER) image remove --force $(TAGS)

.PHONY: distclean
distclean: clean ## Prune all container images
	$(DOCKER) image prune --force
	$(DOCKER) system prune --force
