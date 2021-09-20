CLUSTER=mgmt-hub
rm -rf $CLUSTER
mkdir -p $CLUSTER/openshift
cp install-config_hub.yaml $CLUSTER/install-config.yaml
openshift-baremetal-install --dir $CLUSTER --log-level debug create manifests
cp ICSP/* $CLUSTER/openshift/
cp ICSP/99*chrony* $CLUSTER/openshift/

openshift-baremetal-install --dir $CLUSTER --log-level debug create cluster
