GHOST_GIT_TAG=v1.1.6-slack1
GHOST_GITHUB_ORG=slackhq
TOXIPROXY_VERSION=2.7.0

ARCH=amd64
OS=linux
ifeq ($(shell uname -o),Darwin)
	OS=darwin
endif

all: assets toxiproxy-cli up

toxiproxy-cli:
	curl -sLo toxiproxy-cli https://github.com/Shopify/toxiproxy/releases/download/v$(TOXIPROXY_VERSION)/toxiproxy-cli-$(OS)-$(ARCH)
	chmod +x toxiproxy-cli

env:
	echo "GHOST_GIT_TAG=$(GHOST_GIT_TAG)" >.env
	echo "GHOST_GITHUB_ORG=$(GHOST_GITHUB_ORG)" >>.env
	echo "TOXIPROXY_VERSION=$(TOXIPROXY_VERSION)" >>.env

build: env
	docker-compose build

up-mysql: env
	docker-compose up --remove-orphans -d primary replica

up-toxiproxy: env
	docker-compose up --remove-orphans -d toxiproxy

up: env up-mysql up-toxiproxy
	docker-compose up --remove-orphans test

down: env
	docker-compose down -v

cut-over: env
	docker-compose exec -it test rm -vf /tmp/postpone.flag

partition-replica: toxiproxy-cli
	./toxiproxy-cli toggle replica
	./toxiproxy-cli inspect replica

unpartition-replica: partition-replica

slow-primary: toxiproxy-cli
	./toxiproxy-cli toxic add -t latency -n latency -a latency=15 -a jitter=3 primary
	./toxiproxy-cli inspect primary

unslow-primary: toxiproxy-cli
	./toxiproxy-cli toxic delete -n latency primary
	./toxiproxy-cli inspect primary

docs/ghostbuster.svg: docs/ghostbuster.d2
	d2 --dark-theme 200 docs/ghostbuster.d2 docs/ghostbuster.svg

assets: docs/ghostbuster.svg

clean: down
