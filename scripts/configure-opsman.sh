#!/bin/bash

set -eux

export NSX_HOST=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/director.yml --path /nsx_host)

export OM_opsman_host_name=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /opsman_host_name)

export OM_opsman_user=$OPSMAN_USER
export OM_opsman_password=$OPSMAN_PASSWORD
export OM_opsman_decryption_passphrase=$OPSMAN_DECRYPTION_PASSPHRASE
export OM_nsx_admin_password=$NSXT_PASSWORD
export OM_nsx_admin_user=$NSXT_USER
export OM_vsphere_password=$VSPHERE_PASSWORD
export OM_vsphere_user=$VSPHERE_USER
export OM_nsx_ca_cert=$(openssl s_client -showcerts -connect ${NSX_HOST}:443 \
    </dev/null 2> /dev/null | openssl x509 -outform PEM )

om interpolate --config ./templates/env.yml \
  --vars-env OM > /tmp/env.yml

om interpolate --config ./templates/auth.yml \
  --vars-env OM > /tmp/auth.yml

om --env /tmp/env.yml configure-authentication --config /tmp/auth.yml

echo "Configuring Ops Manager Director"
om --env /tmp/env.yml configure-director \
   --config ./templates/director.yml \
   --vars-env OM \
   --vars-file ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml \
   --vars-file ./control-plane/vars/${ENVIRONMENT_NAME}/director.yml

om --env /tmp/env.yml apply-changes --skip-deploy-products
