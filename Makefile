GIT_TAG=v1.1.6-slack1

all: up

build:
	GIT_TAG=$(GIT_TAG) docker-compose build

up:
	touch postpone.flag
	GIT_TAG=$(GIT_TAG) docker-compose up

down:
	GIT_TAG=$(GIT_TAG) docker-compose down -v

cut-over:
	rm -f postpone.flag

clean: down cut-over
