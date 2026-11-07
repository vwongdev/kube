CLUSTER_NAME ?= default
AGENTS ?= 1
USER_WORKING_DIR ?= .
SECRET_STORE ?= $(dir $(lastword $(MAKEFILE_LIST)))secret-store.yaml

.DEFAULT_GOAL := k3d-create

# Create and run k3d cluster
k3d-create: .cluster_created
k3d-destroy:
	@if [ -f ".cluster_created" ]; then \
		k3d cluster delete $(shell cat .cluster_created) && rm .cluster_created; \
	fi
.cluster_created:
	@k3d cluster create $(CLUSTER_NAME) \
		-p "8081:80@loadbalancer" \
		--k3s-arg "--disable=traefik@server:0" \
		--servers 1 \
		--agents $(AGENTS) \
		--wait \
		&& echo $(CLUSTER_NAME) > .cluster_created

# Apply the local secret store, kept out of git, once External Secrets Operator is running
secret-store:
	@kubectl apply -f $(SECRET_STORE)

# Create and run Skaffold environment
skaffold-init: skaffold.yaml
skaffold-dev: skaffold.yaml
	@skaffold dev
skaffold.yaml:
	@skaffold init
