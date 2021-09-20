#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BIN_PATH=${SCRIPTPATH}/bin
ASSETS_PATH=${SCRIPTPATH}/assets
CLUSTER_NAME=ipv6-cluster
CLUSTER_PATH=${SCRIPTPATH}/${CLUSTER_NAME}

if [[ -z ${ASSETS_PATH}/install-config.yaml ]]
then
  echo "You need to place the install-config.yaml file inside the ${ASSETS_PATH} folder"
  exit 1
fi

rm -rf ${CLUSTER_PATH}
mkdir -p ${CLUSTER_PATH}/openshift
cp ${ASSETS_PATH}/install-config.yaml ${CLUSTER_PATH}/install-config.yaml

${BIN_PATH}/openshift-baremetal-install --dir ${CLUSTER_PATH} --log-level debug create manifests

cp ${ASSETS_PATH}/MC/* ${CLUSTER_PATH}/openshift/

${BIN_PATH}/openshift-baremetal-install --dir ${CLUSTER_PATH} --log-level debug create cluster
