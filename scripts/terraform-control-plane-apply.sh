#!/bin/bash

set -eu

terrafrom_dir=./control-plane/terraform

export TF_VAR_nsxt_username=$NSXT_USER
export TF_VAR_nsxt_password=$NSXT_PASSWORD
pushd ${terrafrom_dir} > /dev/null
  terraform init
  terraform apply -var-file=../vars/${ENVIRONMENT_NAME}/terraform.tfvars \
    -state=../state/${ENVIRONMENT_NAME}/terraform.tfstate
popd > /dev/null

