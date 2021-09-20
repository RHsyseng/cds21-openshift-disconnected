#!/bin/bash

if [[ $(sysctl net.ipv6.conf.all.accept_ra | awk -F "= " '{print $2}') != 2 ]]
then
  sysctl -w net.ipv6.conf.all.accept_ra=2
fi

if [[ $(kcli list networks | grep -c networkipv6) != 1 ]]
then
  kcli create network -c "2620:52:0:1305::0/64" --domain ipv6.virtual.cluster.lab --nodhcp networkipv6
fi
