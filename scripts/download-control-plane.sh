#!/bin/bash

set -eu

concourse_stemcell_version=$(om interpolate --config ./versions.yml --path /concourse_stemcell_version)
concourse_version=$(om interpolate --config ./versions.yml --path /concourse_version)

mkdir -p ./downloads

pushd ./downloads > /dev/null
  pivnet login --api-token "$PIVNET_TOKEN"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "concourse-bosh-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "concourse-bosh-deployment-*.tgz"
  # pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "garden-runc-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "postgres-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "credhub-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "uaa-release-*.tgz"
  # pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "bosh-dns-aliases-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "bpm-release-*.tgz"
  pivnet download-product-files -p stemcells-ubuntu-xenial -r "${concourse_stemcell_version}" -g "bosh-stemcell-*-vsphere-*.tgz"
  pivnet logout
popd > /dev/null

