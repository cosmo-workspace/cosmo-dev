IMAGE ?= ghcr.io/cosmo-workspace/dev-code-server
VERSION ?= v0.0.1

TAG ?= $(VERSION)-$(CODE_SERVER_BASE_TAG)
CODE_SERVER_BASE_TAG ?= 4.10.0
GOLANG_VERSION ?= 1.19.4
NODE_VERSION ?= 18.12.1
PYTHON_VERSION ?= 3.11.1
DOCKER_VERSION ?= 20.10.21

print-%  : ; @echo $*=$($*)

.PHONY: build
build: 
	DOCKER_BUILDKIT=1 docker build . -t $(IMAGE):$(TAG) \
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
