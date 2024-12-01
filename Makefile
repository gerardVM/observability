TF_COMPONENT ?= grafana
TF_DIR       ?= terraform/${TF_COMPONENT}
TRACES_DIR   ?= examples/traces

export KMS_KEY ?= arn:aws:kms:eu-west-3:877759700856:key/b3ac1035-b1f6-424a-bfe9-a6ec592e7487

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

encrypt-config:	
	@scripts/encrypt.sh setups/owners/alerting/evaluations yaml
	@scripts/encrypt.sh setups/owners/dashboards json
	@sops -e --kms ${KMS_KEY} --input-type yaml terraform/grafana/config.yaml > terraform/grafana/config.enc.yaml
	@sops -e --kms ${KMS_KEY} --input-type yaml setups/owners/alerting/contacts.yaml > setups/owners/alerting/contacts.enc.yaml

decrypt-configs:
	@scripts/decrypt.sh setups/owners/alerting/evaluations yaml
	@scripts/decrypt.sh setups/owners/dashboards json
	@sops -d terraform/grafana/config.enc.yaml > terraform/grafana/config.yaml && rm terraform/grafana/config.enc.yaml
	@sops -d setups/owners/alerting/contacts.enc.yaml > setups/owners/alerting/contacts.yaml && rm setups/owners/alerting/contacts.enc.yaml