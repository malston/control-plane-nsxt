#!/bin/bash

set -eu

concourse_version=$(om interpolate --config ./versions.yml --path /concourse_version)
postgres_version=$(om interpolate --config ./versions.yml --path /postgres_version)
credhub_version=$(om interpolate --config ./versions.yml --path /credhub_version)
uaa_version=$(om interpolate --config ./versions.yml --path /uaa_version)
bosh_dns_aliases_version=$(om interpolate --config ./versions.yml --path /bosh_dns_aliases_version)
bpm_version=$(om interpolate --config ./versions.yml --path /bpm_version)
backup_and_restore_sdk_version=$(om interpolate --config ./versions.yml --path /backup_and_restore_sdk_version)
concourse_stemcell_version=$(om interpolate --config ./versions.yml --path /concourse_stemcell_version)
pushd ./downloads > /dev/null
  pivnet login --api-token $PIVNET_TOKEN
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g \
  "concourse-bosh-release-*.tgz"
  pivnet download-product-files -p p-concourse -r "${concourse_version}" -g \
  "garden-runc-release-*.tgz"
  pivnet download-product-files -p stemcells-ubuntu-xenial -r "${concourse_stemcell_version}" -g \
  "bosh-stemcell-*-vsphere-*.tgz"
  pivnet download-product-files -p stemcells-ubuntu-xenial -r "315.70" -g \
  "bosh-stemcell-*-vsphere-*.tgz"
  pivnet logout
exit 0
  curl -L https://bosh.io/d/github.com/cloudfoundry/postgres-release?v=${postgres_version} -o postgres-release-${postgres_version}.tgz
  curl -L https://bosh.io/d/github.com/pivotal-cf/credhub-release?v=${credhub_version} -o credhub-release-${credhub_version}.tgz
  curl -L https://bosh.io/d/github.com/cloudfoundry/uaa-release?v=${uaa_version} -o uaa-release-${uaa_version}.tgz
  curl -L https://bosh.io/d/github.com/cloudfoundry/bosh-dns-aliases-release?v=${bosh_dns_aliases_version} -o bosh_dns_aliases-release-${bosh_dns_aliases_version}.tgz
  curl -L https://bosh.io/d/github.com/cloudfoundry/bpm-release?v=${bpm_version} -o bpm-release-${bpm_version}.tgz
  curl -L https://bosh.io/d/github.com/cloudfoundry-incubator/backup-and-restore-sdk-release?v=${backup_and_restore_sdk_version} -o backup_and_restore_sdk-release-${backup_and_restore_sdk_version}.tgz
popd > /dev/null


