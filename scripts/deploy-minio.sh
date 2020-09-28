#!/bin/bash

set -eux

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_dir="${__DIR}/.."

export OM_opsman_host_name=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /opsman_host_name)
export OM_opsman_user=$OPSMAN_USER
export OM_opsman_password=$OPSMAN_PASSWORD
export OM_opsman_decryption_passphrase=$OPSMAN_DECRYPTION_PASSPHRASE

om interpolate --config ./templates/env.yml \
  --vars-env OM > /tmp/env.yml

eval "$(om --env /tmp/env.yml bosh-env)"

minio_version=$(om interpolate --config ./versions.yml --path /minio_version)

private_key=${PWD}/control-plane/state/${ENVIRONMENT_NAME}/sshkey
export BOSH_ALL_PROXY="ssh+socks5://ubuntu@${OM_opsman_host_name}:22?private-key=${private_key}"
bosh login

echo "Upload Stemcells & Releases..."
pushd ./downloads > /dev/null
  bosh upload-release minio-boshrelease-*.tgz
popd > /dev/null

bosh deploy --non-interactive -d minio ./control-plane/manifests/minio/minio.yml \
    --vars-file=./control-plane/vars/${ENVIRONMENT_NAME}/minio.yml \
    -v version=${minio_version}
