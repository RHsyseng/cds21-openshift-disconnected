#!/bin/bash

if [[ -d /opt/registry/ ]]
then
  echo "/opt/registry folder detected, aborting installation"
  exit 1
fi

sudo dnf -y install podman httpd-tools
sudo mkdir -p /opt/registry/{auth,certs,data,conf}

host_fqdn=$(hostname --long)
cert_c="US"              # Country Name (C, 2 letter code)
cert_s="Massachusetts"   # Certificate State (S)
cert_l="Westford"        # Certificate Locality (L)
cert_o="RedHat"          # Certificate Organization (O)
cert_ou="MGMT"           # Certificate Organizational Unit (OU)
cert_cn="${host_fqdn}"   # Certificate Common Name (CN)
sudo openssl req \
    -newkey rsa:4096 \
    -nodes \
    -sha256 \
    -keyout /opt/registry/certs/domain.key \
    -x509 \
    -days 3650 \
    -out /opt/registry/certs/domain.crt \
    -addext "subjectAltName = DNS:${host_fqdn}" \
    -subj "/C=${cert_c}/ST=${cert_s}/L=${cert_l}/O=${cert_o}/OU=${cert_ou}/CN=${cert_cn}"

sudo htpasswd -bBc /opt/registry/auth/htpasswd kni kni

cat <<EOF | sudo tee /opt/registry/conf/config.yml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
compatibility:
  schema1:
    enabled: true
EOF


cat <<EOF | sudo tee /etc/systemd/system/podman-registry.service
[Unit]
Description=Podman container - Docker Registry
After=network.target

[Service]
Type=simple
WorkingDirectory=/root
TimeoutStartSec=300
ExecStartPre=-/usr/bin/podman rm -f registry
ExecStart=/usr/bin/podman run --name registry --hostname registry --net host -e REGISTRY_AUTH=htpasswd -e REGISTRY_AUTH_HTPASSWD_REALM=basic-realm -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -e REGISTRY_HTTP_SECRET=redhat -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry -v /opt/registry/auth:/auth:Z -v /opt/registry/certs:/certs:z -v /opt/registry/data:/registry:z -v /opt/registry/conf/config.yml:/etc/docker/registry/config.yml:z quay.io/mavazque/registry:2.7.1
ExecStop=-/usr/bin/podman rm -f image-registry
Restart=always
RestartSec=30s
StartLimitInterval=60s
StartLimitBurst=99

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable podman-registry --now

sudo cp /opt/registry/certs/domain.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust

sleep 10
curl -u kni:kni https://$(hostname):5000/v2/_catalog

