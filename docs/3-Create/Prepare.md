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
* AWS account

## How to build Satellite Locations

### IBM Cloud


### AWS



