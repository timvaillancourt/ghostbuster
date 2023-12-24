GHOST_GIT_TAG=v1.1.6-slack1
GHOST_GITHUB_ORG=slackhq

all: assets up

env:
	echo "GHOST_GIT_TAG=$(GHOST_GIT_TAG)" >.env
	echo "GHOST_GITHUB_ORG=$(GHOST_GITHUB_ORG)" >>.env

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
	docker-compose exec -it test rm -vf /postpone.flag

partition-replica:
	curl -sX POST -d '{"enabled":false}' "http://localhost:8474/proxies/replica" | jq .

docs/ghostbuster.svg: docs/ghostbuster.d2
	d2 --dark-theme 200 docs/ghostbuster.d2 docs/ghostbuster.svg

assets: docs/ghostbuster.svg

clean: down
