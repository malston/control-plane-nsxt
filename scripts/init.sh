#!/bin/bash

set -eou pipefail

git submodule update --init --recursive
sudo apt install zip -y

function install_terraform {
  version="${TERRAFORM_VERSION:-0.11.12}"
  os="${OS:-linux}"
  arch="${ARCH:-${arch}}"
  file="terraform.zip"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip
  unzip $file
  chmod +x terraform
  sudo mv terraform /usr/local/bin/terraform
  rm $file
  type terraform
}

function install_pivnet_cli {
  version="${PIVNET_VERSION:-0.0.67}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  file="pivnet"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/pivotal-cf/pivnet-cli/releases/download/v${version}/pivnet-${os}-${arch}-${version}
  chmod +x $file
  sudo mv $file /usr/local/bin/pivnet
  type pivnet
}

function install_jq {
  version="${JQ_VERSION:-1.6}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  if [[ "${os}" == "darwin" ]]; then
    os="osx-${arch}"
  fi
  if [[ "${os}" == "linux" ]]; then
    os="${os}64"
  fi
  file="jq"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file "https://github.com/stedolan/jq/releases/download/jq-${version}/jq-${os}"
  chmod +x $file
  sudo mv $file /usr/local/bin/jq
  type jq
}

function install_om {
  version="${OM_VERSION:-4.1.0}"
  os="${OS:-linux}"
  file="om"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/pivotal-cf/om/releases/download/${version}/om-${os}-${version}
  chmod +x $file
  sudo mv $file /usr/local/bin/om
  type om
}

function install_credhub {
  version="${CREDHUB_VERSION:-2.6.0}"
  os="${OS:-linux}"
  file="credhub.tgz"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${version}/credhub-${os}-${version}.tgz
  tar -xvf $file
  rm $file
  chmod +x credhub
  sudo mv credhub /usr/local/bin/credhub
  type credhub
}

function install_pks_cli {
  version="${PKS_VERSION:-1.5.1}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"

  pivnet login --api-token $PIVNET_TOKEN

  pivnet download-product-files -p pivotal-container-service -r ${version} -g "pks-${os}-${arch}*"
  pivnet download-product-files -p pivotal-container-service -r ${version} -g "kubectl-${os}-${arch}*"

  chmod +x pks*
  sudo mv pks-$os-* /usr/local/bin/pks
  type pks
  chmod +x kubectl-$os-*
  sudo mv kubectl* /usr/local/bin/kubectl
  type kubectl
}

function install_govc {
  version="${GOVC_VERSION:-v0.20.0}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  file="govc"
  URL_TO_BINARY="https://github.com/vmware/govmomi/releases/download/${version}/govc_${os}_${arch}.gz"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget $URL_TO_BINARY
  gunzip govc_${os}_${arch}.gz
  chmod +x govc_${os}_${arch}
  sudo mv govc_${os}_${arch} /usr/local/bin/$file
  type $file
}

function install_helm_cli {
  version="${HELM_CLI_VERSION:-v2.13.1}"
  os="${OS:-linux}"
  arch="${ARCH:-${arch}}"
  file="helm.tar.gz"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://storage.googleapis.com/kubernetes-helm/helm-${version}-${os}-${arch}.tar.gz
  tar -zxvf $file --strip=1 -C /tmp
  chmod +x /tmp/helm
  chmod +x /tmp/tiller
  sudo mv /tmp/helm /usr/local/bin/helm
  sudo mv /tmp/tiller /usr/local/bin/tiller
  rm $file
  type helm
  type tiller
}

function install_bosh_cli {
  version="${BOSH_VERSION:-5.5.1}"
  os="${OS:-linux}"
  arch="${ARCH:-amd64}"
  file="bosh"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://github.com/cloudfoundry/bosh-cli/releases/download/v${version}/bosh-cli-${version}-${os}-${arch}
  chmod +x $file
  sudo mv $file /usr/local/bin/bosh
  type bosh
}

function install_pks_cleanup {
  file="pks_cleanup_linux"
  trap "{ rm -f $file ; exit 255; }" EXIT
  wget -O $file https://storage.googleapis.com/pks-releases/pks_cleanup_linux
  sudo chmod +x pks_cleanup_linux
  sudo mv pks_cleanup_linux /usr/local/bin/pks_cleanup
}

echo "Enter your Operating System (linux, darwin, windows): "
read -r OS

echo "Enter your OS Architecture (amd64, 386): "
read -r ARCH

install_terraform
install_pivnet_cli
install_jq
install_om
install_credhub
install_pks_cli
install_govc
install_helm_cli
install_bosh_cli
install_pks_cleanup

