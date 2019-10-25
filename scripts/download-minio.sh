#!/bin/bash

set -eux

minio_version=$(om interpolate --config ./versions.yml --path /minio_version)

pushd ./downloads > /dev/null
  echo "downloading version $minio_version"
  curl -L https://bosh.io/d/github.com/minio/minio-boshrelease?v=${minio_version} --output minio-boshrelease-${minio_version}.tgz
popd > /dev/null

