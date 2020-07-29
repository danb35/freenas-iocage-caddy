# freenas-iocage-caddy
This script will create an iocage jail on FreeNAS 11.3 or TrueNAS CORE 12.0 with the latest Caddy 2.x release.

## Status
This script will work with FreeNAS 11.3, and it should also work with TrueNAS CORE 12.0. Due to the EOL status of FreeBSD 11.2, it is unlikely to work reliably with earlier releases of FreeNAS.

## Usage

### Prerequisites

:pushpin: *In this implementation, I've kept Caddyfile outside the jail in /caddy. I wasn't sure whether it might be interesting or useful to, say, keep the certificates outside the jail as well. I'll leave this you to ponder.*

Although not required, it's recommended to create a Dataset named `nextcloud` on your main storage pool. If this is not present, a directory `/nextcloud` will be created in `$POOL_PATH`.

### Installation

Download the repository to a convenient directory on your FreeNAS system by changing to that directory and running git clone https://github.com/danb35/freenas-iocage-caddy *[For the moment, git clone https://github.com/basilhendroff/freenas-iocage-caddy]*. Then change into the new freenas-iocage-caddy directory and create a file called caddy-config with your favorite text editor. In its minimal form, it would look like this:

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
- DNS_CERT indicate use of DNS validation for Let's Encrypt. If used, it must be set to 1.
- DNS_PLUGIN: If DNS_CERT is set, DNS_PLUGIN must contain the name of the DNS validation plugin you'll use with Caddy to validate domain control. At this time, the only valid value is cloudflare.
- DNS_TOKEN: If DNS_CERT is set, this must be set to a properly-scoped Cloudflare API Token. You will need to create an API token through Cloudflare's dashboard, which must have "Zone / Zone / Read" and "Zone / DNS / Edit" permissions on the zone (i.e., the domain) you're using for your installation. See [this documentation](https://github.com/libdns/cloudflare) for further details.

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
