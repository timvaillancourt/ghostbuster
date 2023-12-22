all: up

build:
	docker-compose build

up:
	docker-compose up

down:
	docker-compose down -v

clean: down
