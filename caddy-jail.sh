#!/bin/sh
# Build an iocage jail under FreeNAS 11.3-12.0 using the current release of Caddy
# https://github.com/basilhendroff/freenas-iocage-caddyv2

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

#####
#
# General configuration
#
#####

# Initialize defaults
JAIL_IP=""
JAIL_INTERFACES=""
DEFAULT_GW_IP=""
INTERFACE="vnet0"
VNET="on"
JAIL_NAME="caddy"

JAILS_MOUNT=$(zfs get -H -o value mountpoint $(iocage get -p)/iocage)

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")
. "${SCRIPTPATH}"/caddy-config
INCLUDES_PATH="${SCRIPTPATH}"/includes

RELEASE=$(freebsd-version | sed "s/STABLE/RELEASE/g" | sed "s/-p[0-9]*//")

#####
#
# Jail Creation
#
#####

# List packages to be auto-installed after jail creation
cat <<__EOF__ >/tmp/pkg.json
	{
  "pkgs":[
  "nano"
  ]
}
__EOF__

# Create the jail and install previously listed packages
#if ! iocage create --name "${JAIL_NAME}" -p /tmp/pkg.json -r "${RELEASE}" interfaces="${JAIL_INTERFACES}" ip4_addr="${INTERFACE}|${IP}/${NETMASK}" defaultrouter="${DEFAULT_GW_IP}" boot="on" host_hostname="${JAIL_NAME}" vnet="${VNET}"
#then
#	echo "Failed to create jail"
#	exit 1
#fi
rm /tmp/pkg.json
