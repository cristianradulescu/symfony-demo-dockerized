CONTAINER_PROJECT_DIR=/var/www/demo
DOCKER_COMPOSE=CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) docker-compose
PHP=$(DOCKER_COMPOSE) exec php-fpm

.PHONY: setup
setup:
	make build
	make serve
	make composer-install

build: stop
	$(DOCKER_COMPOSE) build \
		--build-arg USERNAME=$(shell whoami) \
		--build-arg USER_ID=$(shell id -u) \
		--build-arg GROUP_ID=$(shell id -g) \
		--build-arg WORKING_DIR=$(CONTAINER_PROJECT_DIR) \
		--force-rm

serve:
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) down --remove-orphans

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