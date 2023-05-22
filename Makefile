IMAGE ?= ghcr.io/cosmo-workspace/dev-code-server
VERSION ?= v0.0.1

TAG ?= $(VERSION)-$(CODE_SERVER_BASE_TAG)
CODE_SERVER_BASE_TAG ?= 4.13.0
GOLANG_VERSION ?= 1.19.4
NODE_VERSION ?= 18.12.1
PYTHON_VERSION ?= 3.11.1
DOCKER_VERSION ?= 20.10.21
KUBECTL_VERSION  ?= 1.26.2
KUSTMIZE_VERSION ?= 5.0.0

print-%  : ; @echo $*=$($*)

.PHONY: build
build: 
	DOCKER_BUILDKIT=1 docker build . -t $(IMAGE):$(TAG) \
		--build-arg CODE_SERVER_BASE_TAG=$(CODE_SERVER_BASE_TAG) \
		--build-arg GOLANG_VERSION=$(GOLANG_VERSION) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg DOCKER_VERSION=$(DOCKER_VERSION) \
		--build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) \
		--build-arg KUSTMIZE_VERSION=$(KUSTMIZE_VERSION)

.PHONY: template
template: configmap
	@helm template code-server charts/charts/dev-code-server/ --debug

.PHONY: configmap
configmap:
	@bash scripts/genconfigmap.sh
