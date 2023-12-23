GHOST_GIT_TAG=v1.1.6-slack1

all: up

build:
	GHOST_GIT_TAG=$(GHOST_GIT_TAG) docker-compose build

up-mysql:
	GHOST_GIT_TAG=$(GHOST_GIT_TAG) docker-compose up --remove-orphans -d primary replica

up-toxiproxy:
	GHOST_GIT_TAG=$(GHOST_GIT_TAG) docker-compose up --remove-orphans -d toxiproxy

up: up-mysql up-toxiproxy
	GHOST_GIT_TAG=$(GHOST_GIT_TAG) docker-compose up --remove-orphans test

down:
	GHOST_GIT_TAG=$(GHOST_GIT_TAG) docker-compose down -v

cut-over:
	GHOST_GIT_TAG=$(GHOST_GIT_TAG) docker-compose exec -it gh-ost rm -vf /postpone.flag

partition-replica:
	curl -sX POST -d '{"enabled":false}' "http://localhost:8474/proxies/replica" | jq .

ghostbuster.svg: ghostbuster.d2
	d2 --dark-theme 200 ghostbuster.d2 ghostbuster.svg

assets: ghostbuster.svg

clean: down
