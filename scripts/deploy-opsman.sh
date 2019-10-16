#! /bin/bash

set -eux

STATE_DIRECTORY=./control-plane/state/${ENVIRONMENT_NAME}

touch ${STATE_DIRECTORY}/state.yml

bosh interpolate ./templates/opsman.yml \
  --vars-env OM \
  --vars-file ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml \
  > /tmp/opsman.yml

if [ ! -f ${STATE_DIRECTORY}/sshkey ]; then
      ssh-keygen -b 2048 -t rsa -f ${STATE_DIRECTORY}/sshkey -q -N ""
fi
export SSH_PUBLIC_KEY=$(cat ${STATE_DIRECTORY}/sshkey.pub)
rp=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /vsphere_resource_pool)
dc=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /vsphere_datacenter)
cluster=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /vsphere_cluster)

export DATASTORE=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /vsphere_datastore)
export NETWORK=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /network_name)
export VSPHERE_HOST=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /vsphere_host_name)
export OPSMAN_PRIVATE_IP=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /opsman_private_ip)
export OPSMAN_HOST_NAME=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /opsman_host_name)
export OPSMAN_NETMASK=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /opsman_netmask)
export OPSMAN_GATEWAY=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /gateway)
export NTP=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /ntp)
export DNS=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /dns)
export OPSMAN_VM_NAME=$(bosh int ./control-plane/vars/${ENVIRONMENT_NAME}/opsman.yml --path /opsman_vm_name)
if [ -z "$rp" ]
  then
    export OM_opsman_resource_pool="/${dc}/host/${cluster}"
else
    export OM_opsman_resource_pool="/${dc}/host/${cluster}/Resources/${rp}"
fi

export GOVC_INSECURE=1
export GOVC_URL=${VSPHERE_HOST}/sdk
export GOVC_USERNAME=$VSPHERE_USER
export GOVC_PASSWORD=$VSPHERE_PASSWORD
export GOVC_DATASTORE=$DATASTORE
export GOVC_NETWORK=$NETWORK
export GOVC_RESOURCE_POOL=$OM_opsman_resource_pool

govc import.spec ./downloads/ops-manager-vsphere-*.ova \
   | jq --arg network "${NETWORK}" -r '.NetworkMapping[0].Network=$network' \
   | jq --arg ip "${OPSMAN_PRIVATE_IP}" -r '(.PropertyMapping[] | select(.Key=="ip0").Value) |=$ip' \
   | jq --arg netmask "${OPSMAN_NETMASK}" -r '(.PropertyMapping[] | select(.Key=="netmask0").Value) |=$netmask' \
   | jq --arg gateway "${OPSMAN_GATEWAY}" -r '(.PropertyMapping[] | select(.Key=="gateway").Value) |=$gateway' \
   | jq --arg dns "${DNS}" -r '(.PropertyMapping[] | select(.Key=="DNS").Value) |=$dns' \
   | jq --arg ntp "${NTP}" -r '(.PropertyMapping[] | select(.Key=="ntp_servers").Value) |=$ntp' \
   | jq --arg ssh "${SSH_PUBLIC_KEY}" -r '(.PropertyMapping[] | select(.Key=="public_ssh_key").Value) |=$ssh' \
   | jq --arg hostname "${OPSMAN_HOST_NAME}" -r '(.PropertyMapping[] | select(.Key=="custom_hostname").Value) |=$hostname' \
   | jq --arg name "${OPSMAN_VM_NAME}" -r '.Name=$name' \
   | jq '.PowerOn=true' \
   > /tmp/opsman_ova.json

govc import.ova --options=/tmp/opsman_ova.json \
   ./downloads/ops-manager-vsphere-*.ova \

