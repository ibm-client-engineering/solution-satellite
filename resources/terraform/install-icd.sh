#!/bin/bash
set -e

if [[ -z $TF_VAR_ibmcloud_api_key ]]; then
	echo "Environment variable 'TF_VAR_ibmcloud_api_key' not set"
	exit 1
fi


ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -q

resource_group_id=$(ibmcloud resource group ITZPOC-I-1271  --id)

terraform init
terraform plan -var-file=./satellite-ibmcloud.tfvars -out=./statefiles/satellite-ic.tfstate
terraform apply "./statefiles/satellite-ic.tfstate"

