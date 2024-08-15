TERRAFILE_VERSION=0.8
ARM_TEMPLATE_TAG=1.1.10
RG_TAGS={"Product": "ITT mentor services"}
REGION=UK South
SERVICE_NAME=itt-mentor-services
SERVICE_SHORT=ittms
DOCKER_REPOSITORY=ghcr.io/dfe-digital/itt-mentor-services

help:
	@grep -E '^[a-zA-Z\._\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: review
review: test-cluster
	$(if ${PR_NUMBER},,$(error Missing PR_NUMBER))
	$(eval ENVIRONMENT=${PR_NUMBER})
	$(eval export TF_VAR_environment=${ENVIRONMENT})
	$(eval include global_config/review.sh)

dv_review: dev-cluster
	$(if ${PR_NUMBER},,$(error Missing PR_NUMBER))
	$(if ${CLUSTER},,$(error Missing CLUSTER))
	$(eval export TF_VAR_cluster=${CLUSTER})
	$(eval ENVIRONMENT=${PR_NUMBER})
	$(eval export TF_VAR_environment=${ENVIRONMENT})
	$(eval include global_config/dv_review.sh)

.PHONY: qa
qa: test-cluster
		$(eval ENVIRONMENT=qa)
		$(eval export TF_VAR_environment=${ENVIRONMENT})
		$(eval include global_config/qa.sh)

.PHONY: sandbox
sandbox: production-cluster
		$(eval ENVIRONMENT=sandbox)
		$(eval export TF_VAR_environment=${ENVIRONMENT})
		$(eval include global_config/sandbox.sh)

.PHONY: staging
staging: test-cluster
		$(eval ENVIRONMENT=staging)
		$(eval export TF_VAR_environment=${ENVIRONMENT})
		$(eval include global_config/staging.sh)

.PHONY: production
production: production-cluster
		$(eval ENVIRONMENT=production)
		$(eval export TF_VAR_environment=${ENVIRONMENT})
		$(eval include global_config/production.sh)

composed-variables:
	$(eval RESOURCE_GROUP_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg)
	$(eval KEYVAULT_NAMES='("${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv", "${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-inf-kv")')
	$(eval STORAGE_ACCOUNT_NAME=${AZURE_RESOURCE_PREFIX}${SERVICE_SHORT}${CONFIG_SHORT}tfsa)
	$(eval LOG_ANALYTICS_WORKSPACE_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-log)

ci:
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SKIP_AZURE_LOGIN=true)
	$(eval SKIP_CONFIRM=true)

.PHONY: ittms_domain
ittms_domain:   ## runs a script to config variables for setting up dns
	$(eval include global_config/domain.sh)
	echo "processed script"

.PHONY: set-azure-template-tag
set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.6)


bin/terrafile: ## Install terrafile to manage terraform modules
	curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile

set-azure-account:
	[ "${SKIP_AZURE_LOGIN}" != "true" ] && az account set -s ${AZURE_SUBSCRIPTION} || true

terraform-init: composed-variables bin/terrafile set-azure-account
	$(if ${DOCKER_IMAGE_TAG}, , $(eval DOCKER_IMAGE_TAG=main))

	./bin/terrafile -p terraform/application/vendor/modules -f terraform/application/config/$(CONFIG)_Terrafile
	terraform -chdir=terraform/application init -upgrade -reconfigure \
		-backend-config=resource_group_name=${RESOURCE_GROUP_NAME} \
		-backend-config=storage_account_name=${STORAGE_ACCOUNT_NAME} \
		-backend-config=key=${ENVIRONMENT}_kubernetes.tfstate

	$(eval export TF_VAR_azure_resource_prefix=${AZURE_RESOURCE_PREFIX})
	$(eval export TF_VAR_config=${CONFIG})
	$(eval export TF_VAR_config_short=${CONFIG_SHORT})
	$(eval export TF_VAR_service_name=${SERVICE_NAME})
	$(eval export TF_VAR_service_short=${SERVICE_SHORT})
	$(eval export TF_VAR_docker_image=${DOCKER_REPOSITORY}:${DOCKER_IMAGE_TAG})

terraform-plan: terraform-init
	terraform -chdir=terraform/application plan -var-file "config/${CONFIG}.tfvars.json"

terraform-apply: terraform-init
	terraform -chdir=terraform/application apply -var-file "config/${CONFIG}.tfvars.json" ${AUTO_APPROVE}

terraform-destroy: terraform-init
	terraform -chdir=terraform/application destroy -var-file "config/${CONFIG}.tfvars.json" ${AUTO_APPROVE}

set-what-if:
	$(eval WHAT_IF=--what-if)

arm-deployment: composed-variables set-azure-account
	$(if ${DISABLE_KEYVAULTS},, $(eval KV_ARG=keyVaultNames=${KEYVAULT_NAMES}))
	$(if ${ENABLE_KV_DIAGNOSTICS}, $(eval KV_DIAG_ARG=enableDiagnostics=${ENABLE_KV_DIAGNOSTICS} logAnalyticsWorkspaceName=${LOG_ANALYTICS_WORKSPACE_NAME}),)

	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "${REGION}" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_GROUP_NAME}" 'tags=${RG_TAGS}' \
		"tfStorageAccountName=${STORAGE_ACCOUNT_NAME}" "tfStorageContainerName=terraform-state" \
		${KV_ARG} \
		${KV_DIAG_ARG} \
		"enableKVPurgeProtection=${KV_PURGE_PROTECTION}" \
		${WHAT_IF}

deploy-arm-resources: arm-deployment ## Validate ARM resource deployment. Usage: make domains validate-arm-resources

validate-arm-resources: set-what-if arm-deployment ## Validate ARM resource deployment. Usage: make domains validate-arm-resources

domain-azure-resources: set-azure-account set-azure-template-tag  ## deploy container to store terraform state for all dns resources -run validate first
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}

domains-infra-init: bin/terrafile ittms_domain set-azure-account ## make domains-infra-init -  terraform init for dns core resources, eg Main FrontDoor resource
	./bin/terrafile -p terraform/domains/infrastructure/vendor/modules -f terraform/domains/infrastructure/config/zones_Terrafile

	terraform -chdir=terraform/domains/infrastructure init -reconfigure -upgrade

domains-infra-plan: domains-infra-init ## terraform plan for dns core resources
	terraform -chdir=terraform/domains/infrastructure plan -var-file config/zones.tfvars.json

domains-infra-apply: domains-infra-init ## terraform apply for dns core resources
	terraform -chdir=terraform/domains/infrastructure apply -var-file config/zones.tfvars.json ${AUTO_APPROVE}

domains-init: bin/terrafile ittms_domain composed-variables set-azure-account
	./bin/terrafile -p terraform/domains/environment_domains/vendor/modules -f terraform/domains/environment_domains/config/${ENVIRONMENT}_Terrafile

	terraform -chdir=terraform/domains/environment_domains init -upgrade -reconfigure -backend-config=key=$(or $(DOMAINS_TERRAFORM_BACKEND_KEY), ittmsdomains_${ENVIRONMENT}.tfstate)


domains-plan: domains-init  ## Terraform plan for DNS environment domains. Usage: make development domains-plan
	terraform -chdir=terraform/domains/environment_domains plan -var-file config/${ENVIRONMENT}.tfvars.json

domains-apply: domains-init ## Terraform apply for DNS environment domains. Usage: make development domains-apply
	terraform -chdir=terraform/domains/environment_domains apply -var-file config/${ENVIRONMENT}.tfvars.json ${AUTO_APPROVE}

dev-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189d01-tsc-dv-rg)
	$(eval CLUSTER_NAME=s189d01-tsc-${CLUSTER}-aks)

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

get-cluster-credentials: set-azure-account
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}
	kubelogin convert-kubeconfig -l $(if ${GITHUB_ACTIONS},spn,azurecli)

bin/konduit.sh:
	curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/main/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh

action-group-resources: set-azure-account # make production action-group-resources ACTION_GROUP_EMAIL=notificationemail@domain.com. Must be run before setting enable_monitoring=true for each subscription
	$(if $(ACTION_GROUP_EMAIL), , $(error Please specify a notification email for the action group))
	echo ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg
	az group create -l uksouth -g ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg --tags "Product=ITT mentor services" "Environment=${DEPLOY_ENV}"
	az monitor action-group create -n ${AZURE_RESOURCE_PREFIX}-itt-mentor-services -g ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg --action email ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-email ${ACTION_GROUP_EMAIL}

maintenance-image-push:
	$(if ${GITHUB_TOKEN},, $(error Provide a valid Github token with write:packages permissions as GITHUB_TOKEN variable))
	$(if ${MAINTENANCE_IMAGE_TAG},, $(eval export MAINTENANCE_IMAGE_TAG=$(shell date +%s)))
	docker build -t ghcr.io/dfe-digital/itt-mentor-services-maintenance:${MAINTENANCE_IMAGE_TAG} maintenance_page
	echo ${GITHUB_TOKEN} | docker login ghcr.io -u USERNAME --password-stdin
	docker push ghcr.io/dfe-digital/itt-mentor-services-maintenance:${MAINTENANCE_IMAGE_TAG}

maintenance-fail-over: get-cluster-credentials
	$(eval export CONFIG)
	./maintenance_page/scripts/failover.sh

enable-maintenance: maintenance-image-push maintenance-fail-over

disable-maintenance: get-cluster-credentials
	$(eval export CONFIG)
	./maintenance_page/scripts/failback.sh
