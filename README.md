# Deploy Control Plane onto NSX-T

This repo contains scripts and terraform configurations to deploy a control
plane, Ops Manager and Concourse to NSX-T. It assumes that NSX-T has been installed
and configured with a T0 Router.

## Setup Variables

```sh
cat > .envrc <<EOF
export JB_USER=ubuntu
export JB_PASSWORD=<password>
export JB_HOSTNAME=jumpbox.example.com
export PIVNET_TOKEN=<pivnet_token>
export VSPHERE_PASSWORD=<password>
export VSPHERE_USER=administrator@vsphere.local
export OPSMAN_SSH_PASSWORD=<password>
export OPSMAN_USER=admin
export OPSMAN_PASSWORD=<password>
export OPSMAN_DECRYPTION_PASSPHRASE=<password>
export NSXT_USER=admin
export NSXT_PASSWORD=<password>
export ENVIRONMENT_NAME=sandbox
EOF
```

Run the following source command to set the environment variables into your shell or install [direnv](https://direnv.net/) to do this automatically.

```sh
source .envrc
```

## Control Plane

- Run `./scripts/init.sh` to install required tools
- Create a Resource pool called `control-plane` in the `Cluster` cluster
- Create a `VM and Template` `folder` under `Datacenter` called
  `control-plane-vms`
- Update `./versions.yml` to use latest versions
- Update `./control-plane/vars/$ENVIRONMENT_NAME/terraform.tfvars`
- run `./scripts/terraform-control-plane-apply.sh` - this will create the
  infrastructure required in NSX-T for a control-plane, mainly the T1 router.
- Update `opsman.yml` and `director.yml` in the control-plane vars directory.
- Run `./scripts/download-opsman.sh`
- Run `./scripts/deploy-opsman.sh`
- Verify that Ops Manager is online and accessible.
- Run `./scripts/configure-opsman.sh`
- Run `./scripts/download-control-plane.sh` to download releases control plane from pivnet
- Finally run `./scripts/deploy-control-plane.sh` to deploy the control plane.
