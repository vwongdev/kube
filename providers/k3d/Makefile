CLUSTER_NAME ?= default
AGENTS ?= 1
USER_WORKING_DIR ?= .

.DEFAULT_GOAL := k3d-create

# Install all dependencies
mac-deps:
	@brew install docker kubernetes-cli skaffold k3d

# Create and run k3d cluster
k3d-create: .cluster_created
k3d-destroy:
	@if [ -f ".cluster_created" ]; then \
		k3d cluster delete $(shell cat .cluster_created) && rm .cluster_created; \
	fi
.cluster_created:
	@k3d cluster create $(CLUSTER_NAME) \
		-p "8081:80@loadbalancer" \
		--servers 1 \
		--agents $(AGENTS) \
		--wait \
		&& echo $(CLUSTER_NAME) > .cluster_created

# Create and run Skaffold environment
skaffold-init: skaffold.yaml
skaffold-dev: skaffold.yaml
	@skaffold dev
skaffold.yaml:
	@skaffold init
