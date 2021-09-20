#!/bin/bash

dnf install chrony -y

cat <<EOF > /etc/chrony.conf
server pool.ntp.org iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
bindcmdaddress ::
allow 2620:52:0:1305::0/64
EOF

systemctl enable chronyd --now


