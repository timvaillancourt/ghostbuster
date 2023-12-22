all: up

build:
	docker-compose build

up:
	touch postpone.flag
	docker-compose up

down:
	docker-compose down -v

cut-over:
	rm -f postpone.flag

clean: down cut-over
