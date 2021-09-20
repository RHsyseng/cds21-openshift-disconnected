#!/bin/bash
CLUSTER=ipv6-cluster

read -p "Are you sure? [y/n]: " DELETE

if [[ ${DELETE} == "y" ]]
then
  kcli delete vm ${CLUSTER}-master0 ${CLUSTER}-master1 ${CLUSTER}-master2 ${CLUSTER}-worker0 ${CLUSTER}-worker1 ${CLUSTER}-worker2 -y
  BOOTSTRAP=$(kcli list vm | grep "ipv6-.*bootstrap" | awk -F "|" '{print $2}' | tr -d " " )
  if [[ ${BOOTSTRAP} != "" ]]
  then
    kcli delete vm ${BOOTSTRAP} -y
  fi
fi

rm -rf ${CLUSTER}/

> /opt/dnsmasq-ipv6/hosts.leases

systemctl restart dnsmasq-ipv6

