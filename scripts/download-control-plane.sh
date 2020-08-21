#!/bin/bash

set -eu

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_dir="${__DIR}/.."

concourse_stemcell_version=$(om interpolate --config ./versions.yml --path /concourse_stemcell_version)
concourse_version=$(om interpolate --config ./versions.yml --path /concourse_version)

mkdir -p "${base_dir}/downloads"

pushd "${base_dir}/downloads" > /dev/null
  pivnet login --api-token "$PIVNET_TOKEN"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "concourse-bosh-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "concourse-bosh-deployment-*.tgz"
  # # pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "garden-runc-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "postgres-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "credhub-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "uaa-release-*.tgz"
  # # pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "bosh-dns-aliases-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g "bpm-release-*.tgz"
  pivnet download-product-files -p stemcells-ubuntu-xenial -r "${concourse_stemcell_version}" -g "bosh-stemcell-*-vsphere-*.tgz"
  pivnet logout
popd > /dev/null

rm -rf "${base_dir}/downloads/concourse-bosh-deployment/"
mkdir -p "${base_dir}/downloads/concourse-bosh-deployment"
tar -zxvf ${base_dir}/downloads/concourse-bosh-deployment-*.tgz --strip=1 -C "${base_dir}/downloads/concourse-bosh-deployment"

version=$(echo "${concourse_version}" | cut -d' ' -f 1)

mkdir -p "${base_dir}/control-plane/manifests/concourse/${version}"
cp "${base_dir}/downloads/concourse-bosh-deployment/cluster/concourse.yml" "${base_dir}/control-plane/manifests/concourse/${version}/concourse.yml"
