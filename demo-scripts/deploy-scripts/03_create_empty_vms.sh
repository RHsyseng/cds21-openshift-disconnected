#!/bin/bash
CLUSTER=ipv6-cluster
VIRT_NIC="networkipv6"

kcli create vm -P start=False -P memory=16000 -P numcpus=4 -P disks=[200,200] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:05\"}"] ${CLUSTER}-master0
kcli create vm -P start=False -P memory=16000 -P numcpus=4 -P disks=[200,200] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:06\"}"] ${CLUSTER}-master1
kcli create vm -P start=False -P memory=16000 -P numcpus=4 -P disks=[200,200] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:07\"}"] ${CLUSTER}-master2
kcli create vm -P start=False -P memory=8192 -P numcpus=4 -P disks=[200,20,20,20,20,20] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:08\"}"] ${CLUSTER}-worker0
kcli create vm -P start=False -P memory=8192 -P numcpus=4 -P disks=[200,20,20,20,20,20] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:09\"}"] ${CLUSTER}-worker1
kcli create vm -P start=False -P memory=8192 -P numcpus=4 -P disks=[200,20,20,20,20,20] -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:10\"}"] ${CLUSTER}-worker2

