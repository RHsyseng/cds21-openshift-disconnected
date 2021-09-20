#!/bin/bash

if [[ -d /opt/sushy-tools ]]
then
  echo "Sushy tools folder detected (/opt/sushy-tools), aborting installation"
  exit 1
fi

dnf install -y libvirt-devel gcc python3-devel

python3 -m venv /opt/sushy-tools

source /opt/sushy-tools/bin/activate

pip3 install sushy-tools libvirt-python

openssl req -newkey rsa:2048 -x509 -sha256 -days 3650 -nodes -out /opt/sushy-tools/sushy.cert -subj "/C=US/ST=TX/L=Austin/O=EcoSystems Engineering/CN=sushytools" -keyout /opt/sushy-tools/sushy.key

cat <<EOF > /opt/sushy-tools/sushy-emulator.conf
# Listen on all local IP interfaces
SUSHY_EMULATOR_LISTEN_IP = u'::'

# Bind to TCP port 8080
SUSHY_EMULATOR_LISTEN_PORT = 8080

# Serve this SSL certificate to the clients
# SUSHY_EMULATOR_SSL_CERT = u'sushy.cert'
SUSHY_EMULATOR_SSL_CERT = u'/opt/sushy-tools/sushy.cert'

# If SSL certificate is being served, this is its RSA private key
# SUSHY_EMULATOR_SSL_KEY = u'sushy.key'
SUSHY_EMULATOR_SSL_KEY = u'/opt/sushy-tools/sushy.key'

# The OpenStack cloud ID to use. This option enables OpenStack driver.
SUSHY_EMULATOR_OS_CLOUD = None

# The libvirt URI to use. This option enables libvirt driver.
SUSHY_EMULATOR_LIBVIRT_URI = u'qemu:///system'

# Workaround for BZ by @alosadagrande - 20.05.2021
# https://bugzilla.redhat.com/show_bug.cgi?id=1957387
SUSHY_EMULATOR_IGNORE_BOOT_DEVICE = True

# The map of firmware loaders dependant on the boot mode and
# system architecture
SUSHY_EMULATOR_BOOT_LOADER_MAP = {
    u'UEFI': {
        u'x86_64': u'/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd',
        u'aarch64': u'/usr/share/AAVMF/AAVMF_CODE.fd'
    },
    u'Legacy': {
        u'x86_64': None,
        u'aarch64': None
    }
}

# This map contains statically configured Redfish Chassis linked
# up with the Systems and Managers enclosed into this Chassis.
#
# The first chassis in the list will contain all other resources.
#
# If this map is not present in the configuration, a single default
# Chassis is configured automatically to enclose all available Systems
# and Managers.
SUSHY_EMULATOR_CHASSIS = [
    {
        u'Id': u'Chassis',
        u'Name': u'Chassis',
        u'UUID': u'48295861-2522-3561-6729-621118518810'
    }
]

# This map contains statically configured Redfish IndicatorLED
# resource state ('Lit', 'Off', 'Blinking') keyed by UUIDs of
# System and Chassis resources.
#
# If this map is not present in the configuration, each
# System and Chassis will have their IndicatorLED 'Lit' by default.
#
# Redfish client can change IndicatorLED state. The new state
# is volatile, i.e. it's maintained in process memory.
SUSHY_EMULATOR_INDICATOR_LEDS = {
#    u'48295861-2522-3561-6729-621118518810': u'Blinking'
}

# This map contains statically configured virtual media resources.
# These devices ('Cd', 'Floppy', 'USBStick') will be exposed by the
# Manager(s) and possibly used by the System(s) if system emulation
# backend supports boot image configuration.
#
# If this map is not present in the configuration, the following configuration
# is used:
SUSHY_EMULATOR_VMEDIA_DEVICES = {
    u'Cd': {
        u'Name': 'Virtual CD',
        u'MediaTypes': [
            u'CD',
            u'DVD'
        ]
    }
}

# This map contains statically configured Redfish Storage resource linked
# up with the Systems resource, keyed by the UUIDs of the Systems.
SUSHY_EMULATOR_STORAGE = {
    "da69abcc-dae0-4913-9a7b-d344043097c0": [
        {
            "Id": "1",
            "Name": "Local Storage Controller",
            "StorageControllers": [
                {
                    "MemberId": "0",
                    "Name": "Contoso Integrated RAID",
                    "SpeedGbps": 12
                }
            ],
            "Drives": [
                "32ADF365C6C1B7BD"
            ]
        }
    ]
}

# This map contains statically configured Redfish Drives resource. The Drive
# objects are keyed in a composite fashion using a tuple of the form
# (System_UUID, Storage_ID) referring to the UUID of the System and Id of the
# Storage resource, respectively, to which the drive belongs.
SUSHY_EMULATOR_DRIVES = {
    ("da69abcc-dae0-4913-9a7b-d344043097c0", "1"): [
        {
            "Id": "32ADF365C6C1B7BD",
            "Name": "Drive Sample",
            "CapacityBytes": 899527000000,
            "Protocol": "SAS"
        }
    ]
}

# This map contains dynamically configured Redfish Volume resource backed
# by the libvirt virtualization backend of the dynamic Redfish emulator.
# The Volume objects are keyed in a composite fashion using a tuple of the
# form (System_UUID, Storage_ID) referring to the UUID of the System and ID
# of the Storage resource, respectively, to which the Volume belongs.
#
# Only the volumes specified in the map or created via a POST request are
# allowed to be emulated upon by the emulator. Volumes other than these can
# neither be listed nor deleted.
#
# The Volumes from map missing in the libvirt backend will be created
# dynamically in the pool name specified (provided the pool exists in the
# backend). If the pool name is not specified, the volume will be created
# automatically in pool named 'default'.
SUSHY_EMULATOR_VOLUMES = {
    ('da69abcc-dae0-4913-9a7b-d344043097c0', '1'): [
        {
            "libvirtPoolName": "sushyPool",
            "libvirtVolName": "testVol",
            "Id": "1",
            "Name": "Sample Volume 1",
            "VolumeType": "Mirrored",
            "CapacityBytes": 23748
        },
        {
            "libvirtPoolName": "sushyPool",
            "libvirtVolName": "testVol1",
            "Id": "2",
            "Name": "Sample Volume 2",
            "VolumeType": "StripedWithParity",
            "CapacityBytes": 48395
        }
    ]
}
EOF

cat <<EOF > /etc/systemd/system/sushy-tools.service
[Unit]
Description=Sushy Tools (Redfish Emulator for Libvirt)
After=network.target syslog.target

[Service]
Type=simple
TimeoutStartSec=5m
#User=<your-user>
WorkingDirectory=/opt/sushy-tools
ExecStart=/opt/sushy-tools/bin/python3 /opt/sushy-tools/bin/sushy-emulator --config /opt/sushy-tools/sushy-emulator.conf
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now sushy-tools

curl https://127.0.0.1:8080/redfish/v1/Systems/
