# IPv6 Disconnected Baremetal cluster using IPI installer on VMs

This folder contains the required scripts to run a disconnected IPv6 deployment on VMs using the IPI installer.

There are two folders:

* pre-req-scripts - Has the required scripts that should run before deploying the cluster
* deploy-scripts - Has the required scripts that should run when deploying the cluster


## Pre-req-scripts

* 00_create_kcli_networks.sh - Create a virtual IPv6 network on libvirt (without DHCP) 
* 01_deploy_sushy_tools.sh - Deploys the sushy-tools BMC emulator in order to provide redfish emulation for VMs 
* 02_deploy_local_registry.sh - Deploys a local container registry that will be used to mirror OCP releases
* 03_deploy_dnsmasq.sh - Deploys a DNSMasq that will have the required DNS records and DHCP reservations
* 04_deploy_radvd.sh - Deploys RADVD required for sending RA to our virtual ipv6 network
* 05_httpd_server.sh - Deploys a local web server that will be used to mirror RHCOS images
* 06_chrony_server.sh - Deploys a local chronyd server that will be used by nodes to get their time set via NTP

## Deploy-scripts

* 00_mirror_ocp_release.sh - Mirrors a given OCP release into our local registry
* 01_extract_bm_installer_from_release.sh - Extracts the baremetal installer binary from the mirrored release
* 02_mirror_rhcos_images.sh - Mirrors the RHCOS images used by the disconnected release into our local httpd server
* 03_create_empty_vms.sh - Creates empty VMs that will be provisioned by the installer using redfish virtualmedia
* 04_prepare-install-config.sh - Creates the install-config.yaml with the required data
* 05_run_installation.sh - Runs the deployment
* clean.sh - Cleans the deployment

