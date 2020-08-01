# freenas-iocage-caddy
This script will create an iocage jail on FreeNAS 11.3 or TrueNAS CORE 12.0 with the latest Caddy 2.x release.

## Status
This script will work with FreeNAS 11.3, and it should also work with TrueNAS CORE 12.0. Due to the EOL status of FreeBSD 11.2, it is unlikely to work reliably with earlier releases of FreeNAS.

## Usage
Many users install a variety of web applications in jails on their FreeNAS servers, and often those applications run on non-standard ports like 6789, 8181, 7878, etc. These port numbers are far from intuitive, and the applications often either don't implement HTTPS at all, or make it difficult to configure. A common recommendation to address these issues is to install a separate web server to act as a reverse proxy (allowing you to browse to simpler URLs like http://yourserver/radarr), and also to handle the TLS termination. Although popular web servers like Apache and Nginx can act as reverse proxies, configuration is complex, and neither of them handle the TLS certificates and configuration by default. This guide will cover installing Caddy in its own jail, configuring it to act as a proxy for your other applications, and optionally obtaining TLS certificates from Let's Encrypt and using them to encrypt your communications.

### Prerequisites

:pushpin: *In this implementation, I've kept Caddyfile outside the jail in /caddy. I wasn't sure whether it might be interesting or useful to, say, keep the certificates outside the jail as well. I'll leave this for you to ponder.*

Although not required, it's recommended to create a Dataset named `caddy` on your main storage pool. If this is not present, a directory `/caddy` will be created in `$POOL_PATH`.

### Installation

Download the repository to a convenient directory on your FreeNAS system by changing to that directory and running git clone https://github.com/danb35/freenas-iocage-caddy. Then change into the new freenas-iocage-caddy directory and create a file called caddy-config with your favorite text editor. In its minimal form, it would look like this:

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
- INTERFACE: The network interface to use for the jail. Defaults to `vnet0`.
- VNET: Whether to use the iocage virtual network stack. Defaults to `on`.
- DNS_PLUGIN: This contains the name of the DNS validation plugin you'll use with Caddy to validate domain control. Visit the [Caddy download page](https://caddyserver.com/download) to see the DNS authentication plugins currently available. To build Caddy with your desired plugin, use the last part of the "Package" on that page as DNS_PLUGIN in your `caddy-config` file. E.g., if the package name is `github.com/caddy-dns/cloudflare`, you'd set `DNS_PLUGIN=cloudflare`. From that page, there are also links to the documentation for each plugin, which will describe what credentials are needed.

Also, HOST_NAME needs to resolve to your jail from inside your network. You'll probably need to configure this on your router. If you're unable to do so, you can edit the hosts file on your client computers to achieve this result.

### Execution

Once you've downloaded the script and prepared the configuration file, run this script (`./caddy-jail.sh`). The script will run for several minutes. When it finishes, your jail will be created and Caddy will be installed.

### Test

To test your installation, enter your Caddy jail IP address and port 2020 e.g. `192.168.1.199:2020` in a browser. If the installation was successful, the message *Hello, world!* should be displayed. 

## The Caddyfile
Caddy looks for its configuration in the Caddyfile. Its syntax is fairly simple, and is fully documented in the [Caddy Docs](https://caddyserver.com/docs/). I'll discuss a few scenarios with examples of the Caddyfile below.

### Prerequisites (Let's Encrypt)
Caddy works best when your installation is able to obtain a certificate from Let's Encrypt. When you use it this way, Caddy is able to handle all of the TLS-related configuration for you, obtain and renew certificates automatically, etc. In order for this to happen, you must meet the two requirements below:

First, you must own or control a real Internet domain name. This script obtains a TLS encryption certificate from Let's Encrypt, who will only issue for public domain names. Thus, domains like cloud.local, mycloud.lan, or nextcloud.home won't work. Domains can be very inexpensive, and in some cases, they can be free. Freenom, for example, provides domains for free if you jump through the right hoops. EasyDNS is a fine domain registrar for paid domains, costing roughly US$15 per year (which varies slightly with the top-level domain).

Second, one of these two conditions must be met in order for Let's Encrypt to validate your control over the domain name:

You must be able and willing to open ports 80 and 443 from the entire Internet to the jail, and leave them open.
DNS hosting for the domain name needs to be with a provider that Caddy supports. 

For example, Cloudflare provides DNS hosting at no cost, and it's well-supported by Caddy. Cloudflare also provides Dynamic DNS service, if your desired Dynamic DNS client supports their API. If it doesn't, DNS-O-Matic is a Dynamic DNS provider that will interface with many DNS hosts including Cloudflare, has a much simpler API that's more widely supported, and is also free of charge.

Due to abuse, Cloudflare has removed the ability to use its API with free domains when using Cloudflare's free plan. For this to work, you'll need to pay either for Cloudflare or for a domain (and the latter is likely less expensive). If you want to use a Freenom domain, you'll need to be able and willing to open ports 80 and 443 to your jail, so you can get your certificate without using DNS validation.

If you aren't able or willing to obtain a certificate from Let's Encrypt, Caddy can be configured with a self-signed certificate, or with no certificate (and thus no HTTPS) at all.
### No TLS
:pushpin: *Blah...*
:pushpin: *Does something need to be said about using self-signed certs with Caddy?* 

### TLS with HTTP validation
:pushpin: *Blah, blah...*

### TLS with DNS validation
:pushpin: *Blah, blah, blah...*

### Test
:pushpin: *Probably a good idea to make reference here to validate and reload commands e.g.*

You can validate your Caddyfile changes with `service caddy validate`. To commit the changes gracefully and with zero downtime, use `service caddy reload` instead of `service caddy restart`. 

## Limitations
:pushpin: *Is this still required? This may no longer be true with Caddy V2. Probably better to leave this section out altogether, at least for the moment.*

Some apps are not amenable to being served over a reverse proxy, or at least with the configuration described above. Two such apps appear to be Duplicati and Urbackup. If your app doesn't work, try doing a web search for "(app name) reverse proxy" to see if (1) it's possible at all, and (2) if any special settings are required.

## To Do
I'd appreciate any suggestions (or, better yet, pull requests) to improve the various config files I'm using. If there are changes to settings or organization that could improve performance, reliability, or security, I'd like to hear about them.

## Support and Discussion

:pushpin: *To avoid blurring the lines. it might be an idea to make it clear that support is limited to getting the script working. For help developing and debugging Caddyfile code blocks, Caddy users should refer to the [Caddy forum](https://caddy.community/) for expert advice. The discussion area could also be used for showcasing working code blocks (with a link to a Caddy forum thread for reference where appropriate). This will be of value to other FreeNAS community members.*  

Questions or issues about this resource can be raised in this forum thread.
