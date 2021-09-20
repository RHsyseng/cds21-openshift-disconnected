#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BIN_PATH=${SCRIPTPATH}/bin
TEMP_PATH=${SCRIPTPATH}/temp
ASSETS_PATH=${SCRIPTPATH}/assets
LOCAL_SECRET_JSON=${ASSETS_PATH}/pull_secret.json

if [[ -z ${LOCAL_SECRET_JSON} ]]
then
  echo "You need to place the pull_secret.json file inside the ${ASSETS_PATH} folder"
  exit 1
fi

mkdir -p ${BIN_PATH} ${TEMP_PATH}

if [ ! -f ${TEMP_PATH}/oc-client.tar.gz ]
then
  curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-client-linux.tar.gz -o ./temp/oc-client.tar.gz
  tar xfz ${TEMP_PATH}/oc-client.tar.gz oc
  mv ./oc ${BIN_PATH}/
fi

UPSTREAM_REGISTRY=quay.io
PRODUCT_REPO=openshift-release-dev
RELEASE_NAME=ocp-release
OCP_RELEASE=4.8.11-x86_64
LOCAL_REGISTRY=$(hostname -f):5000

# Login into podman registry
podman login $(hostname -f):5000 -u kni -p kni --authfile ${LOCAL_SECRET_JSON}

# Mirror the release
# Potential improvement: Check tags using curl and only mirror if release has not been already mirrored
${BIN_PATH}/oc adm -a ${LOCAL_SECRET_JSON} release mirror --from=${UPSTREAM_REGISTRY}/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} --to=${LOCAL_REGISTRY}/ocp4 --to-release-image=${LOCAL_REGISTRY}/ocp4/release:${OCP_RELEASE}


