CONTAINER_PROJECT_DIR=/var/www/demo
PHP=docker-compose exec php-fpm

.PHONY: setup
setup:
	make build
	make serve
	make composer-install

build: stop
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) docker-compose build --build-arg USERNAME=$(shell whoami) --build-arg USER_ID=$(shell id -u) --force-rm

serve:
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) docker-compose up -d

stop:
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) docker-compose down --remove-orphans

composer-install: serve
	$(PHP) composer install
	$(PHP) ./vendor/bin/simple-phpunit install
	make yarn-install
	make yarn-encore-prod
	make run-tests

composer-update: serve
	$(PHP) composer update

yarn-install: serve
	$(PHP) yarn install

yarn-encore-dev: serve
	$(PHP) yarn dev

yarn-encore-prod: serve
	$(PHP) yarn build

run-tests: serve
	$(PHP) ./bin/phpunit

run-phpcsfixer-dry: serve
	$(PHP) ./vendor/bin/php-cs-fixer fix --dry-run --diff --verbose

run-phpcsfixer-and-fix: serve
	$(PHP) ./vendor/bin/php-cs-fixer fix --diff --verbose

run-phpstan: serve
	$(PHP) ./vendor/bin/phpstan analyze --memory-limit=-1