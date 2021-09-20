#!/bin/bash

if [[ -d /opt/httpd ]]
then
  echo "/opt/httpd folder detected, aborting..."
  exit 1
fi

mkdir -p /opt/httpd

cat <<EOF > /etc/systemd/system/podman-httpd.service
[Unit]
Description=Podman container - Apache
After=network.target

[Service]
Type=simple
WorkingDirectory=/root
TimeoutStartSec=300
ExecStartPre=-/usr/bin/podman rm -f httpd
ExecStart=/usr/bin/podman run --name httpd --hostname httpd --network=host -e  APACHE_HTTP_PORT_NUMBER=9000 -v /opt/httpd:/app:Z quay.io/bitnami/apache:latest
ExecStop=-/usr/bin/podman rm -f httpd
Restart=always
RestartSec=30s
StartLimitInterval=60s
StartLimitBurst=99

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable podman-httpd --now
