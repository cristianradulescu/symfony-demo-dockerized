CONTAINER_PROJECT_DIR=/var/www/demo

DOCKER_COMPOSE=$(shell which docker-compose) -f docker-compose.yml

# Jenkins env var
CI=$(shell echo $${CI:-"false"})
ifeq (${CI},true)
	DOCKER_COMPOSE=$(shell which docker-compose) -f docker-compose-ci.yml
endif

PHP=${DOCKER_COMPOSE} exec -T php-fpm

.PHONY: setup
setup:
	make build
	make serve
	make composer-install
	make run-tests

build: stop
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) docker build --build-arg USERNAME=$(shell whoami) --build-arg USER_ID=$(shell id -u) --force-rm -t sfdemo-dockerized:base .
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) ${DOCKER_COMPOSE} build --build-arg USERNAME=$(shell whoami) --force-rm

serve:
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) ${DOCKER_COMPOSE} up -d

stop:
	CONTAINER_PROJECT_DIR=$(CONTAINER_PROJECT_DIR) ${DOCKER_COMPOSE} down --remove-orphans

composer-install: serve
	$(PHP) composer install
	$(PHP) ./vendor/bin/simple-phpunit install
	make yarn-install
	make yarn-encore-prod

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

start-jenkins-node:
	${DOCKER_COMPOSE} exec jenkins-node ./bin/jenkins_start-agent.sh