#!/bin/bash

if [[ -d /opt/dnsmasq-ipv6 ]]
then
  echo "/opt/dnsmasq-ipv6 folder detected, aborting..."
  exit 1
fi

dnf install dnsmasq -y

mkdir -p /opt/dnsmasq-ipv6/

HOSTNAME=$(hostname -f)

cat <<EOF > /opt/dnsmasq-ipv6/dnsmasq.conf
strict-order
bind-dynamic
bogus-priv
dhcp-authoritative
# DHCP Range NetworkIPv6
dhcp-range=networkipv6,2620:52:0:1305::11,2620:52:0:1305::20,64
dhcp-option=networkipv6,option6:dns-server,2620:52:0:1305::1

resolv-file=/opt/dnsmasq-ipv6/upstream-resolv.conf
except-interface=lo
dhcp-lease-max=81
log-dhcp

domain=ipv6.virtual.cluster.lab,2620:52:0:1305::0/64,local

# static host-records
address=/apps.ipv6.virtual.cluster.lab/2620:52:0:1305::2
host-record=api.ipv6.virtual.cluster.lab,2620:52:0:1305::3
host-record=openshift-master-0.ipv6.virtual.cluster.lab,2620:52:0:1305::5
ptr-record=5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-master-0.ipv6.virtual.cluster.lab"
host-record=openshift-master-1.ipv6.virtual.cluster.lab,2620:52:0:1305::6
ptr-record=6.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-master-1.ipv6.virtual.cluster.lab"
host-record=openshift-master-2.ipv6.virtual.cluster.lab,2620:52:0:1305::7
ptr-record=7.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-master-2.ipv6.virtual.cluster.lab"
host-record=openshift-worker-0.ipv6.virtual.cluster.lab,2620:52:0:1305::8
ptr-record=8.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-worker-0.ipv6.virtual.cluster.lab"
host-record=openshift-worker-1.ipv6.virtual.cluster.lab,2620:52:0:1305::9
ptr-record=9.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-worker-1.ipv6.virtual.cluster.lab"
host-record=openshift-worker-2.ipv6.virtual.cluster.lab,2620:52:0:1305::10
ptr-record=0.1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-worker-2.ipv6.virtual.cluster.lab"

# DHCP Reservations
dhcp-hostsfile=/opt/dnsmasq-ipv6/hosts.hostsfile
dhcp-leasefile=/opt/dnsmasq-ipv6/hosts.leases

# Registry
host-record=${HOSTNAME},2620:52:0:1305::1
EOF

cat <<EOF > /opt/dnsmasq-ipv6/hosts.hostsfile
de:ad:be:ff:00:05,openshift-master-0,[2620:52:0:1305::5]
de:ad:be:ff:00:06,openshift-master-1,[2620:52:0:1305::6]
de:ad:be:ff:00:07,openshift-master-2,[2620:52:0:1305::7]
de:ad:be:ff:00:08,openshift-worker-0,[2620:52:0:1305::8]
de:ad:be:ff:00:09,openshift-worker-1,[2620:52:0:1305::9]
de:ad:be:ff:00:10,openshift-worker-2,[2620:52:0:1305::10]
EOF

cat <<EOF > /opt/dnsmasq-ipv6/upstream-resolv.conf
nameserver 10.19.143.247
EOF


cat <<EOF > /etc/systemd/system/dnsmasq-ipv6.service
[Unit]
Description=DNS server for Openshift 4 Virt clusters.
After=network.target
[Service]
User=root
Group=root
ExecStart=/usr/sbin/dnsmasq -k --conf-file=/opt/dnsmasq-ipv6/dnsmasq.conf
[Install]
WantedBy=multi-user.target
EOF

touch /opt/dnsmasq-ipv6/hosts.leases

systemctl daemon-reload

systemctl enable dnsmasq-ipv6 --now
