#!/bin/bash

set -eu

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_dir="${__DIR}/.."

export OM_opsman_host_name=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /opsman_host_name)
export OM_opsman_user=$OPSMAN_USER
export OM_opsman_password=$OPSMAN_PASSWORD
export OM_opsman_decryption_passphrase=$OPSMAN_DECRYPTION_PASSPHRASE

om interpolate --config ./templates/env.yml \
  --vars-env OM > /tmp/env.yml

eval "$(om --env /tmp/env.yml bosh-env)"

private_key=${PWD}/control-plane/state/${ENVIRONMENT_NAME}/sshkey
export BOSH_ALL_PROXY="ssh+socks5://ubuntu@${OM_opsman_host_name}:22?private-key=${private_key}"
export CREDHUB_PROXY=$BOSH_ALL_PROXY
credhub login

export ADMIN_USERNAME=admin
export ADMIN_PASSWORD=password

credhub set \
   -n /p-bosh/concourse/local_user \
   -t user \
   -z "${ADMIN_USERNAME}" \
   -w "${ADMIN_PASSWORD}"

# terraform output -state=${base_dir}/control-plane/state/${ENVIRONMENT_NAME}/terraform.tfstate stable_config > /tmp/terraform-outputs.yml

# export CONCOURSE_URL="$(terraform output -state=${base_dir}/control-plane/state/${ENVIRONMENT_NAME}/terraform.tfstate concourse_url)"

bosh login

bosh -n -d concourse deploy "${base_dir}/downloads/concourse-bosh-deployment/cluster/concourse.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/audit.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/privileged-http.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/privileged-https.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/basic-auth.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/tls-vars.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/tls.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/uaa.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/credhub-colocated.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/offline-releases.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/backup-atc-colocated-web.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/secure-internal-postgres.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/secure-internal-postgres-bbr.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/secure-internal-postgres-uaa.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/secure-internal-postgres-credhub.yml" \
  -o "${base_dir}/downloads/concourse-bosh-deployment/cluster/operations/scale.yml" \
  -o "${base_dir}/control-plane/vars/${ENVIRONMENT_NAME}/operations.yml" \
  -l "${base_dir}/control-plane/vars/${ENVIRONMENT_NAME}/concourse.yml" \
  -l "${base_dir}/downloads/concourse-bosh-deployment/versions.yml"
