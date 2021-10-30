CONTAINER_PROJECT_DIR=/var/www/demo

setup:
	make build
	make serve
	make composer-install

build:
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) docker-compose build --build-arg USERNAME=$(shell whoami) --build-arg USER_ID=$(shell id -u) --force-rm

serve:
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) docker-compose up -d

stop:
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) docker-compose down --remove-orphans

composer-install:
	docker-compose exec php-fpm composer install
	make yarn-install
	make yarn-encore-prod

composer-update:
	docker-compose exec php-fpm composer update

yarn-install:
	docker-compose exec php-fpm yarn install

yarn-encore-dev:
	docker-compose exec php-fpm yarn dev

yarn-encore-prod:
	docker-compose exec php-fpm yarn build

run-tests:
	docker-compose exec php-fpm ./bin/phpunit