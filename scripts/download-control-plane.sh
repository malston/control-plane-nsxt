#!/bin/bash

set -eu

version=$(om interpolate --config ./versions.yml --path /concourse_version)

pushd ./downloads > /dev/null
  pivnet login --api-token $PIVNET_TOKEN
  pivnet download-product-files -p p-concourse -r ${version} -g \
  "concourse-bosh-release-*.tgz"
  pivnet download-product-files -p p-concourse -r ${version} -g \
  "garden-runc-release-*.tgz"
  pivnet logout
popd > /dev/null
