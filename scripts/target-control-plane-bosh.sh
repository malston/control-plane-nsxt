#!/bin/bash

set -e


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
export CREDHUB_PROXY=$BOSH_ALL_PROXY
