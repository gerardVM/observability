TF_COMPONENT ?= grafana
TF_DIR       ?= terraform/${TF_COMPONENT}
TRACES_DIR   ?= examples/traces

-include Makefile.local

tf-init:
	@cd ${TF_DIR} && terraform init

tf-plan: tf-init
	@cd ${TF_DIR} && terraform plan -out=${TF_COMPONENT}.out

tf-apply: tf-init
	@cd ${TF_DIR} && terraform apply ${TF_COMPONENT}.out

traces-test:
	@cd ${TRACES_DIR} && docker-compose build --no-cache
	@cd ${TRACES_DIR} && docker-compose up
