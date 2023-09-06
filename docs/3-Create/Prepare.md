---
id: solution-prepare
sidebar_position: 1
title: Prepare
---

## Pre-Requisites

### IBM Cloud
* IBM Cloud environment with access to IBM Satellite
* Have the necessary permissions to create IAM API keys, SSH keys with full access to Satellite, ICD services, VPC infrastructure, VPC block storage, and access to increased quota limits
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
* AWS access key ID and AWS secret access key

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

:::tip

Make sure to assign a host to each zone within the satellite location.

:::

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

1. Within IBM Console, navigate to 'Locations' and 'Create location+'
2. Click 'AWS Quick Start'
3. Enter credentials and click 'Fetch options from AWS'
4. Within Satellite Location edit the config and update name and target appropriate resource group
5. Create location

#### Adding AWS Hosts to Satellite (if necessary)
1. From the Satellite console, select the location where you want to add AWS hosts.
2. Retrieve the host registration script that you must run on your hosts to make them visible to your IBM Cloud Satellite location.
    * From the Hosts tab, click Attach host.
    * Optional: Enter any host labels that are used later to automatically assign) hosts to Satellite-enabled IBM Cloud services in the location. Labels must be provided as key-value pairs, and must match the request from the service. For example, you might have host labels such as `env=prod` or `service=database`. By default, your hosts get a `cpu`, `os`, and `memory` label, but you might want to add more to control the auto assignment, such as `env=prod` or `service=database`.
    * Enter a file name for your script or use the name that is generated for you.
    * Click Download script to generate the host script and download the script to your local machine. Note that the token in the script is an API key, which should be treated and protected as sensitive information.
3. RHEL only Open the registration script. After the `API_URL` line, add a section to pull the required RHEL       packages with the subscription manager.
    ```sh
    # Enable AWS RHEL package updates
    yum update -y
    yum-config-manager --enable '*'
    yum repolist all
    yum install container-selinux -y
    echo "repos enabled"
    ```
4. From the AWS EC2 dashboard, go to Instances > Launch Templates.
5. Click Create Launch template and enter the template details as follows.
    * Enter a name for your launch template.
    * In the Amazon machine image (AMI) section, make sure to select a supported Red Hat Enterprise Linux 7 or 8 operating system that you can find by entering the AMI ID. You can match AMI IDs and the proper Red Hat Enterprise Linux version by referring to the <a href="https://access.redhat.com/solutions/15356" target="_blank">Red Hat Enterprise Linux AMI Available on Amazon Web Services documentation</a>.
    * From the Instance type section, select one of the <a href="https://cloud.ibm.com/docs/satellite?topic=satellite-aws#aws-instance-types" target="_blank">supported AWS instance types</a>.
    * From the Key pair (login) section, select the .pem key that you want to use to log in to your machines later. If you do not have a .pem key, create one.
    * In the Network settings, select Virtual Private Cloud (VPC) and an existing subnet and security group. If you do not have a subnet or security group that you want to use, create one.
    * In the Storage (volumes) section, expand the default root volume and update the size of the boot volume to a minimum of 100 GB. Add a second disk with at least 100 GB capacity.
    * Expand the Advanced details and go to the User Data field.
    * Enter the host registration script that you modified earlier. If you are adding an RHCOS host, add the ignition script.
    * Click Create launch template.
6. From the Launch Templates dashboard, find the template that you created.
7. From the Actions menu, select Launch instance from template.
8. Enter the number of instances that you want to create and click Launch instance from template.
9. Wait for the instance to launch. During the launch of your instance, the registration script runs automatically. This process takes a few minutes to complete.
10. Monitor the progress of the registration script.
    * From the EC2 Instances dashboard, retrieve the public IP address of your instance.
    * Log in to your instance.
    ```sh
    ssh -i <key>.pem ec2-user@<public_IP_address>
    ```
        * Review the status of the registration script.
    ```sh
    journalctl -f -u ibm-host-attach
    ```
11. Check that your hosts are shown in the Hosts tab of your Satellite console. All hosts show a Health status of `Ready` when a connection to the machine can be established, and a Status of `Unassigned` as the hosts are not yet assigned to your Satellite location control plane or a Red Hat OpenShift on IBM Cloud cluster.
12. Assign your AWS hosts to the Satellite control plane or a Red Hat OpenShift on IBM Cloud cluster.

#### Create Red Hat OpenShift Service
1. Navigate to Satellite environement on <a href="https://cloud.ibm.com/" target="_blank">IBM Cloud Console</a>
2. Click 'Create Service' -> 'Red Hat Openshift on IBM Cloud'
3. Choose 'Custom Cluster', 'Satellite' (Infrastructure)
4. Select appropraite resource group and desired satellite [location_name]
5. Select configuration to match the available hosts you want to use
6. 'Enable cluster admin access for Satellite Config' - keep all other areas to default option
7. Name cluster and 'Create'
