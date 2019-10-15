#!/bin/bash

set -eu

version=$(om interpolate --config ./versions.yml --path /opsman_version)

pushd ./downloads > /dev/null
  pivnet login --api-token $PIVNET_TOKEN
  pivnet download-product-files -p ops-manager -r ${version} -g "ops-manager-vsphere-*.ova"
  pivnet logout
popd > /dev/null
