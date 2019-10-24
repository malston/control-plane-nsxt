#!/bin/bash

set -eux


echo "Obtain bosh credentials"

export OM_opsman_host_name=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /opsman_host_name)
export OM_opsman_user=$OPSMAN_USER
export OM_opsman_password=$OPSMAN_PASSWORD
export OM_opsman_decryption_passphrase=$OPSMAN_DECRYPTION_PASSPHRASE

om interpolate --config ./templates/env.yml \
  --vars-env OM > /tmp/env.yml

eval "$(om --env /tmp/env.yml bosh-env)"

private_key=${PWD}/control-plane/state/${ENVIRONMENT_NAME}/sshkey
export BOSH_ALL_PROXY="ssh+socks5://ubuntu@${OM_opsman_host_name}:22?private-key=${private_key}"
bosh login

# echo "Upload Stemcells & Releases..."
# pushd ./downloads > /dev/null
#   bosh upload-stemcell bosh-stemcell-*.tgz
#   bosh upload-release concourse-bosh-release-*.tgz
#   bosh upload-release bosh-dns-aliases-release-*.tgz
#   bosh upload-release bpm-release-*.tgz
#   bosh upload-release credhub-release-*.tgz
#   bosh upload-release postgres-release-*.tgz
#   bosh upload-release garden-runc-release-*.tgz
#   bosh upload-release uaa-release-*.tgz
# popd > /dev/null

export CP_ca_cert=$(om --env /tmp/env.yml certificate-authorities --format json | jq -r '.[0] | select(.active==true) | .cert_pem' )

bosh deploy --non-interactive -d control-plane ./control-plane/manifests/concourse/4.2.4/control-plane.yml \
    --vars-file=./control-plane/vars/${ENVIRONMENT_NAME}/control-plane.yml \
    --vars-env CP
