IMAGE ?= ghcr.io/cosmo-workspace/dev-code-server
VERSION ?= v0.0.3

TAG ?= $(VERSION)-$(CODE_SERVER_BASE_TAG)
CODE_SERVER_BASE_TAG ?= 4.91.1
GOLANG_VERSION ?= 1.22.6
NODE_VERSION ?= 18.20.4
PYTHON_VERSION ?= 3.12.5
DOCKER_VERSION ?= 27.1.1
KUBECTL_VERSION  ?= 1.30.3
KUSTMIZE_VERSION ?= 5.4.1

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
