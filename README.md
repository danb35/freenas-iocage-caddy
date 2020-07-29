# freenas-iocage-caddy
This script will create an iocage jail on FreeNAS 11.3 or TrueNAS CORE 12.0 with the latest Caddy 2.x release.

## Status
This script will work with FreeNAS 11.3, and it should also work with TrueNAS CORE 12.0. Due to the EOL status of FreeBSD 11.2, it is unlikely to work reliably with earlier releases of FreeNAS.

## Usage

### Prerequisites

:pushpin: *In this implementation, I've kept Caddyfile outside the jail in /caddy. I wasn't sure whether it might be interesting or useful to, say, keep the certificates outside the jail as well. I'll leave this for you to ponder.*

Although not required, it's recommended to create a Dataset named `nextcloud` on your main storage pool. If this is not present, a directory `/nextcloud` will be created in `$POOL_PATH`.

### Installation

Download the repository to a convenient directory on your FreeNAS system by changing to that directory and running git clone https://github.com/danb35/freenas-iocage-caddy. :pushpin: *For the moment, git clone https://github.com/basilhendroff/freenas-iocage-caddy.* Then change into the new freenas-iocage-caddy directory and create a file called caddy-config with your favorite text editor. In its minimal form, it would look like this:

```
JAIL_IP="192.168.1.199"
DEFAULT_GW_IP="192.168.1.1"
POOL_PATH="/mnt/tank"
HOST_NAME="YOUR_FQDN"
```

Many of the options are self-explanatory, and all should be adjusted to suit your needs, but only a few are mandatory. The mandatory options are:

- JAIL_IP is the IP address for your jail. You can optionally add the netmask in CIDR notation (e.g., 192.168.1.199/24). If not specified, the netmask defaults to 24 bits. Values of less than 8 bits or more than 30 bits are invalid.
- DEFAULT_GW_IP is the address for your default gateway
- POOL_PATH is the path for your data pool.
- HOST_NAME is the fully-qualified domain name you want to assign to your installation. If you are planning to get a Let's Encrypt certificate (recommended), you must own (or at least control) this domain, because Let's Encrypt will test that control. If you're using a self-signed cert, or not getting a cert at all, it's only important that this hostname resolve to your jail inside your network.

In addition, there are some other options which have sensible defaults, but can be adjusted if needed. These are:

- JAIL_NAME: The name of the jail, defaults to "caddy"
- CONFIG_PATH: This is the path to your Caddyfile, defaults to $POOL_PATH/caddy.
- INTERFACE: The network interface to use for the jail. Defaults to vnet0.
- VNET: Whether to use the iocage virtual network stack. Defaults to on.
- DNS_PLUGIN: DNS_PLUGIN contains the name of the DNS validation plugin you'll use with Caddy to validate domain control. Visit the Caddy download page to see the DNS authentication plugins currently available. To build Caddy with your desired plugin, use the last part of the "Package" on that page as DNS_PLUGIN in your nextcloud-config file. E.g., if the package name is github.com/caddy-dns/cloudflare, you'd set DNS_PLUGIN=cloudflare. From that page, there are also links to the documentation for each plugin, which will describe what credentials are needed.

Also, HOST_NAME needs to resolve to your jail from inside your network. You'll probably need to configure this on your router. If you're unable to do so, you can edit the hosts file on your client computers to achieve this result.

### Execution



### Test

## The Caddyfile

### Prerequisites (Let's Encrypt)

### No TLS

### TLS with HTTP validation

### TLS with DNS validation

## Limitations

## To Do

## Support and Discussion
