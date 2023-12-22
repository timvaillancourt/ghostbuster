GIT_TAG=v1.1.6-slack1

all: up

build:
	GIT_TAG=$(GIT_TAG) docker-compose build

up-mysql:
	GIT_TAG=$(GIT_TAG) docker-compose up --remove-orphans -d primary replica

up-toxiproxy:
	GIT_TAG=$(GIT_TAG) docker-compose up --remove-orphans -d toxiproxy

up: up-mysql up-toxiproxy
	touch postpone.flag
	GIT_TAG=$(GIT_TAG) docker-compose up --remove-orphans gh-ost

down:
	GIT_TAG=$(GIT_TAG) docker-compose down -v

cut-over:
	rm -vrf postpone.flag

clean: cut-over down
