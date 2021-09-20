#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BIN_PATH=${SCRIPTPATH}/bin

# Mirror RHCOS images

OPENSTACK_IMAGE=$(${BIN_PATH}/openshift-baremetal-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.openstack.formats."qcow2.gz".disk.location' | tr -d '"')
OPENSTACK_IMAGE_FILE=$(basename ${OPENSTACK_IMAGE} | tr -d '"')
QEMU_IMAGE=$(${BIN_PATH}/openshift-baremetal-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.qemu.formats."qcow2.gz".disk.location' | tr -d '"')
QEMU_IMAGE_FILE=$(basename ${QEMU_IMAGE} | tr -d '"')

if [[ ! -f /opt/httpd/${OPENSTACK_IMAGE_FILE} ]]
then
  curl -Lk ${OPENSTACK_IMAGE} -o /opt/httpd/${OPENSTACK_IMAGE_FILE}
fi

if [[ ! -f /opt/httpd/${QEMU_IMAGE_FILE} ]]
then
  curl -Lk ${QEMU_IMAGE} -o /opt/httpd/${QEMU_IMAGE_FILE}
fi
