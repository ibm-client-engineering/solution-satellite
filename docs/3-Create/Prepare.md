---
id: solution-prepare
sidebar_position: 1
title: Prepare
---

## Pre-Requisites

### IBM Cloud
* IBM Cloud environment with access to IBM Satellite
* Have the necessary permissions to create IAM API keys, ssh keys with full access to Satellite, ICD services, VPC infrastructure,VPC block storage and access to increased quota limits
* Terraform installation
* API Key, SSH Key, COS bucket

#### Create API Key within Satellite Environment
1. Navigate to Satellite environement on <a href="https://cloud.ibm.com/" target="_blank">IBM Cloud Console</a>
2. Select 'Manage' -> 'Access (IAM)' -> 'API Keys'
3. Create a new API key and save/download key (will be used later)

#### Create SSH key
1. Within the side bar options navigate to 'VPC Infrastructure' -> 'SSH Keys'
2. Select appropriate location and regions for the satellite location
3. Populate 'name' and select the appropriate resource group
4. Select 'RSA'
5. Save the private and public keys and 'Create' (This will be used)

#### Create COS Bucket
1. Go to satellite environement in IBM Cloud Console
2. Click "Resources" in the side menu and click "Create Resource"
3. Search "Object Storage" and select:
    * Infrastructure: "IBM Cloud"
    * Pricing Plan: "Standard"
4. Populate COS name and appropriate resource group in which satellite location is being built in and "Create"

### AWS
* Have the correct IBM Cloud permissions to create locations
* Get AWS account access with the required permissions

## How to build Satellite Locations

### IBM Cloud

#### Export API Key

Navigate to the working directory and run:
```sh
export TF_VAR_ibmcloud_api_key=<API key>
```
The script expects the API key in `TF_VAR_ibmcloud_api_key`

#### Create .tfvars file
Create a file named `<location name>.tfvars` (substitute your desired location name and ssh key) in the root directory of the repo (same directory as `install-icd.sh` script).

The following values are required:
```terraform
location_name     = "<location name>"
is_location_exist = false
managed_from      = "wdc"
manage_iam_policy = false
region            = "us-east"
image             = "ibm-redhat-8-6-minimal-amd64-3"
existing_ssh_key  = "<ssh key name>"

control_plane_hosts = { "name" : "cp", "count" : 3, "type" : "bx2-8x32" }
customer_hosts      = { "name" : "customer", "count" : 3, "type" : "bx2-32x128" }
internal_hosts      = { "name" : "internal", "count" : 3, "type" : "bx2-8x32" }
openshift_hosts     = { "name" : "openshift", "count" : 3, "type" : "bx2-16x64" }
```

- `location_name`: name of the location
- `is_location_exist`: if the location already exists before running this script, set this value to `true`
- `managed_from`: needs to be an IBM Cloud region that is supported by IBM Cloud Databases on Satellite
- `manage_iam_policy`: if the necessary IAM policies for the databases-for-* services already exist before running this script, set this value to `false`
- `region`: the IBM Cloud region in which to deploy all VPC VSI, networks, etc. - should ideally correspond to the region picked in `managed_from`
- `existing_ssh_key`: VPC SSH Key name - this needs to exist in `region`

#### Execute Terraform scripts to build Locations

Login into IBM Cloud CLI
```sh
ibmcloud login -sso
```
Target appropriate resource group
```sh
ibmcloud target -g [resource group]
```
When running for the first time, execute (in the repo root):
```sh
terraform init
```
```sh
terraform plan -var-file=./[tvar input file].tfvars -out=./statefiles/[state file]
```
```sh
terraform apply "./statefiles/[state file]"
```
#### Assign hosts to the control plane
1. Navigate to Satellite environement on <a href="https://cloud.ibm.com/" target="_blank">IBM Cloud Console</a>
2. Within the sidebar go to 'Satellite' -> 'Locations' -> select [location_name]
3. Within 'Getting started' -> 'Set up control plane' and 'Assign Hosts' (control_plane hosts) to the control plane

#### Create Red Hat OpenShift Service
1. Navigate to Satellite environement on <a href="https://cloud.ibm.com/" target="_blank">IBM Cloud Console</a>
2. Click 'Create Service' -> 'Red Hat Openshift on IBM Cloud'
3. Choose 'Custom Cluster', 'Satellite' (Infrastructure)
4. Select appropraite resource group and desired satellite [location_name]
5. Select configuration to match the available hosts you want to use
6. 'Enable cluster admin access for Satellite Config' - keep all other areas to default option
7. Name cluster and 'Create'


### AWS
:::tip

Prior to building out Satellite locations on AWS, you need to use a resource group that provides full access for buidling out AWS locations on IBM Cloud Satellite

:::




