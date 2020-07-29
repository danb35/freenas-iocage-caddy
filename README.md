# freenas-iocage-caddy
This script will create an iocage jail on FreeNAS 11.3 or TrueNAS CORE 12.0 with the latest Caddy 2.x release.

## Status
This script will work with FreeNAS 11.3, and it should also work with TrueNAS CORE 12.0. Due to the EOL status of FreeBSD 11.2, it is unlikely to work reliably with earlier releases of FreeNAS.

## Usage

### Prerequisites

*[In this implementation, I've kept Caddyfile outside the jail in /caddy/config. I wasn't sure whether it might be interesting (or possible) to say keep the certificates outside the jail as well. I'll leave this you to ponder.]*

Although not required, it's recommended to create a Dataset named `nextcloud` on your main storage pool. If this is not present, a directory `/nextcloud` will be created in `$POOL_PATH`, and subdirectory `config` will be created there.

### Installation

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
