ARG CODE_SERVER_BASE_TAG="latest"

FROM codercom/code-server:${CODE_SERVER_BASE_TAG}

ARG GOLANG_VERSION="1.19.4"
ARG NODE_VERSION="18.12.1"
ARG PYTHON_VERSION="3.11.1"
ARG DOCKER_VERSION="20.10.21"
ARG KUBECTL_VERSION="1.26.2"
ARG KUSTMIZE_VERSION="5.0.0"

USER 0
RUN apt-get -y update \
&&  apt-get install -y --no-install-recommends \
 		gnupg \
		wget  \
		unzip \
		xz-utils \
		vim \
		tmux \
		iputils-ping \
		iproute2 \
		dnsutils \
# for go \
&&  apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
# for python \
&&	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
		gnupg \
		dirmngr \
		git \
		mercurial \
		openssh-client \
		subversion \
		procps \
&&	apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		bzip2 \
		dpkg-dev \
		file \
		g++ \
		gcc \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgdbm-dev \
		libglib2.0-dev \
		libgmp-dev \
		libjpeg-dev \
		libkrb5-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libmaxminddb-dev \
		libncurses5-dev \
		libncursesw5-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		patch \
		unzip \
		xz-utils \
		zlib1g-dev \
		\
		$( \
			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
				echo 'default-libmysqlclient-dev'; \
			else \
				echo 'libmysqlclient-dev'; \
			fi \
		) \
&& rm -rf /var/lib/apt/lists/*

##---------------------------------------------------
## node.js
##   ref: Dockerfile of docker official image node:14
##     dockerhub: https://hub.docker.com/_/node
##     DockerFile: https://github.com/nodejs/docker-node/blob/a16a841095bcefefaf0ec43ba39f91fc788b03d4/14/buster/Dockerfile
##---------------------------------------------------
# gid/uid 1000 is alreadt used so change them to 1001
RUN groupadd --gid 1001 node \
  && useradd --uid 1001 --gid node --shell /bin/bash --create-home node

RUN set -ex \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && node --version \
  && npm --version \
  && corepack enable \
  && yarn --version \
  && pnpm --version

##---------------------------------------------------
## go
##   ref: Dockerfile of docker official image golang:1.16.4-buster
##     dockerhub: https://hub.docker.com/_/golang
##     DockerFile: https://github.com/docker-library/golang/blob/ad65a7b21b2689de3a15334a7db2917a3b9216ec/1.16/buster/Dockerfile
##---------------------------------------------------
ENV PATH /usr/local/go/bin:$PATH

RUN set -eux; \
	url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz"; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	go version

# GOPATH is set in .bash_profile
# ENV GOPATH /go
# ENV PATH $GOPATH/bin:$PATH
# RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

##---------------------------------------------------
## python
##   install pyenv
##---------------------------------------------------
ENV PYENV_ROOT /usr/local/pyenv
RUN set -e; \
    curl -s -S -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash

RUN $PYENV_ROOT/bin/pyenv install $PYTHON_VERSION

RUN $PYENV_ROOT/bin/pyenv global $PYTHON_VERSION


##---------------------------------------------------
## timezone / locale
##---------------------------------------------------
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8"

##---------------------------------------------------
## Docker CLI install
##---------------------------------------------------
RUN curl "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" -o "/tmp/docker.tgz" \
 && cd /tmp \
 && tar -xvf "docker.tgz" docker/docker \
 && cp --preserve=mode,timestamps ./docker/docker /usr/bin/ \
 && ls -l /usr/bin/docker \
 && rm -rf ./docker docker.tgz

ENV DOCKER_HOST tcp://localhost:2375

##---------------------------------------------------
## AWSCLI
##     https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/install-cliv2-linux.html
##---------------------------------------------------
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install \
 && rm -rf aws awscliv2.zip \
 && aws --version

##---------------------------------------------------
## kubectl install
##     https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
##---------------------------------------------------
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
 && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
 && kubectl version --client

##---------------------------------------------------
## kustomize install
##---------------------------------------------------
RUN cd /usr/bin \
 && curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash -s -- ${KUSTMIZE_VERSION} \
 && kustomize version

##---------------------------------------------------
## open-vsx cli
##   https://github.com/eclipse/openvsx/blob/master/cli/README.md 
##---------------------------------------------------
RUN npm install -g ovsx

# change port not to duplicate http servers like tomcat
EXPOSE 18080
USER 1000

# change home to empty directory
WORKDIR /projects

# Entrypoint
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
