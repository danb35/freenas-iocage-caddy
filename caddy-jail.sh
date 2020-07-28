#!/bin/sh
# Build an iocage jail under FreeNAS 11.3-12.0 using the current release of Caddy
# git clone https://github.com/basilhendroff/freenas-iocage-caddyv2

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
POOL_PATH=""
JAIL_NAME="caddy"

STANDALONE_CERT=0
SELFSIGNED_CERT=0
DNS_CERT=0
NO_CERT=0

JAILS_MOUNT=$(zfs get -H -o value mountpoint $(iocage get -p)/iocage)

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "${SCRIPT}")
INCLUDES_PATH="${SCRIPTPATH}"/includes

RELEASE=$(freebsd-version | sed "s/STABLE/RELEASE/g" | sed "s/-p[0-9]*//")

# Check for nextcloud-config and set configuration
if ! [ -e "${SCRIPTPATH}"/caddy-config ]; then
  echo "${SCRIPTPATH}/caddy-config must exist."
  exit 1
fi

# Check that necessary variables were set by nextcloud-config
if [ -z "${JAIL_IP}" ]; then
  echo 'Configuration error: JAIL_IP must be set'
  exit 1
fi
if [ -z "${JAIL_INTERFACES}" ]; then
  echo 'JAIL_INTERFACES not set, defaulting to: vnet0:bridge0'
  JAIL_INTERFACES="vnet0:bridge0"
fi
if [ -z "${DEFAULT_GW_IP}" ]; then
  echo 'Configuration error: DEFAULT_GW_IP must be set'
  exit 1
fi
if [ -z "${POOL_PATH}" ]; then
  echo 'Configuration error: POOL_PATH must be set'
  exit 1
fi
if [ -z "${TIME_ZONE}" ]; then
  echo 'Configuration error: TIME_ZONE must be set'
  exit 1
fi
if [ -z "${HOST_NAME}" ]; then
  echo 'Configuration error: HOST_NAME must be set'
  exit 1
fi
if [ $STANDALONE_CERT -eq 0 ] && [ $DNS_CERT -eq 0 ] && [ $NO_CERT -eq 0 ] && [ $SELFSIGNED_CERT -eq 0 ]; then
  echo 'Configuration error: Either STANDALONE_CERT, DNS_CERT, NO_CERT,'
  echo 'or SELFSIGNED_CERT must be set to 1.'
  exit 1
fi
if [ $STANDALONE_CERT -eq 1 ] && [ $DNS_CERT -eq 1 ] ; then
  echo 'Configuration error: Only one of STANDALONE_CERT and DNS_CERT'
  echo 'may be set to 1.'
  exit 1
fi

if [ $DNS_CERT -eq 1 ] && [ -z "${DNS_PLUGIN}" ] ; then
  echo "DNS_PLUGIN must be set to a supported DNS provider."
  echo "See https://caddyserver.com/docs under the heading of \"DNS Providers\" for list."
  echo "Be sure to omit the prefix of \"tls.dns.\"."
  exit 1
fi  
#if [ $DNS_CERT -eq 1 ] && [ -z "${DNS_ENV}" ] ; then
#  echo "DNS_ENV must be set to a your DNS provider\'s authentication credentials."
#  echo "See https://caddyserver.com/docs under the heading of \"DNS Providers\" for more."
#  exit 1
#fi  

#if [ $DNS_CERT -eq 1 ] ; then
#  DL_FLAGS="tls.dns.${DNS_PLUGIN}"
#  DNS_SETTING="dns ${DNS_PLUGIN}"
#fi

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
