parts = $(subst -, ,$(CIRCLE_USERNAME))
environment := $(shell echo "$(word 2,$(parts))" | tr '[:lower:]' '[:upper:]')
environments := PRODUCTION STAGING TEST

ifeq ($(filter $(environment),$(environments)),)
	export environment = DEVELOPMENT
endif

export appenv := $(shell echo "$(environment)" | tr '[:upper:]' '[:lower:]')
export TF_VAR_appenv := $(appenv)
export backend_bucket := grace-$(appenv)-config
export AWS_ACCESS_KEY_ID := $($(environment)_AWS_ACCESS_KEY_ID)
export AWS_SECRET_ACCESS_KEY := $($(environment)_AWS_SECRET_ACCESS_KEY)
export TF_VAR_master_account_id := $($(environment)_MASTER_ACCT_ID)

.PHONY: test deploy test_lambda release_lambda plan_terraform apply_terraform test_integration release_integration clean
test: test_lambda plan_terraform
deploy: test release_lambda apply_terraform release_integration
test_lambda:
	make -C handler test

release_lambda:
	make -C handler release

plan_terraform:
	make -C terraform plan

apply_terraform:
	make -C terraform apply

test_integration:
	make -C integration test

release_integration:
	make -C integration release

clean:
	make -C handler clean
	make -C integration clean
