IMAGE ?= ghcr.io/cosmo/code-server
VERSION ?= 0.0.1

CODE_SERVER_BASE_TAG ?= 4.10.0
GOLANG_VERSION ?= 1.19.4
NODE_VERSION ?= 18.12.1
PYTHON_VERSION ?= 3.11.1
DOCKER_VERSION ?= 20.10.21

.PHONY: show-versions
show-versions:
	@echo "tag=$(CODE_SERVER_BASE_TAG)-$(VERSION)"
	@echo "code-server-basetag=$(CODE_SERVER_BASE_TAG)"
	@echo "go-version=$(GOLANG_VERSION)"
	@echo "node-version=$(NODE_VERSION)"
	@echo "python-version=$(PYTHON_VERSION)"
	@echo "docker-version=$(DOCKER_VERSION)"

.PHONY: build
build: 
	DOCKER_BUILDKIT=1 docker build . -t $(IMAGE):$(CODE_SERVER_BASE_TAG)-$(VERSION) \
		--build-arg CODE_SERVER_BASE_TAG=$(CODE_SERVER_BASE_TAG) \
		--build-arg GOLANG_VERSION=$(GOLANG_VERSION) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg DOCKER_VERSION=$(DOCKER_VERSION)

.PHONY: template
template: configmap
	@helm template code-server charts/code-server/ --debug

.PHONY: configmap
configmap:
	@bash scripts/genconfigmap.sh

.PHONY: install
install:
	helm upgrade --install -n code-server --create-namespace  code-server charts/code-server/
