# Work in progress, not for production use.

# freenas-iocage-caddy
This script will create an iocage jail on FreeNAS 11.3 or TrueNAS CORE 12.0 with the latest Caddy 2.x release.

## Status
This script will work with FreeNAS 11.3, and it should also work with TrueNAS CORE 12.0. Due to the EOL status of FreeBSD 11.2, it is unlikely to work reliably with earlier releases of FreeNAS.

## Usage
Many users install a variety of web applications in jails on their FreeNAS servers, and often those applications run on non-standard ports like 6789, 8181, 7878, etc. These port numbers are far from intuitive, and the applications often either don't implement HTTPS at all, or make it difficult to configure. A common recommendation to address these issues is to install a separate web server to act as a reverse proxy (allowing you to browse to simpler URLs like http://yourserver/radarr), and also to handle the TLS termination. Although popular web servers like Apache and Nginx can act as reverse proxies, configuration is complex, and neither of them handle the TLS certificates and configuration by default. This guide will cover installing Caddy in its own jail, configuring it to act as a proxy for your other applications, and optionally obtaining TLS certificates from Let's Encrypt and using them to encrypt your communications.

The Caddy installation performed by this script is pretty bare-bones, and can be adapted by the user for a variety of different uses.  The primary purposes envisioned by this guide are:

* Serve static HTML web pages (using PHP will require installing additional packages in the jail)
* Acting as a reverse proxy, as described above
  * Optionally providing TLS termination for your apps

This author's purpose for the reverse proxy is entirely on his own LAN, not anything that would be exposed to the Internet.  If you're wanting to expose a reverse proxy to the Internet as a way of making services on your LAN accessible from the Internet, this installation will do that as well (just forward ports 80 and 443 to this jail).  However, it'd be worth investigating whether your router has a similar capability (as both [pfSense](https://www.pfsense.org/) and [OPNsense](https://opnsense.org/) do).  If so, implementing the proxy on your router may be the better way to go.

### Prerequisites

Although not required, it's recommended to create a Dataset named `apps` with a sub-dataset named `caddy` on your main storage pool.  Many other jail guides also store their configuration and data in subdirectories of `pool/apps/` If this dataset is not present, a directory `/apps/caddy` will be created in `$POOL_PATH`.

### Installation

Download the repository to a convenient directory on your FreeNAS system by changing to that directory and running `git clone https://github.com/danb35/freenas-iocage-caddy`. Then change into the new freenas-iocage-caddy directory and create a file called caddy-config with your favorite text editor. In its minimal form, it would look like this:

```
JAIL_IP="192.168.1.199"
DEFAULT_GW_IP="192.168.1.1"
POOL_PATH="/mnt/tank"
```

Many of the options are self-explanatory, and all should be adjusted to suit your needs, but only a few are mandatory. The mandatory options are:

- JAIL_IP is the IP address for your jail. You can optionally add the netmask in CIDR notation (e.g., 192.168.1.199/24). If not specified, the netmask defaults to 24 bits. Values of less than 8 bits or more than 30 bits are invalid.
- DEFAULT_GW_IP is the address for your default gateway
- POOL_PATH is the path for your data pool.

In addition, there are some other options which have sensible defaults, but can be adjusted if needed. These are:

- JAIL_NAME: The name of the jail, defaults to "caddy"
- CONFIG_PATH: This is the path to your Caddyfile, defaults to $POOL_PATH/apps/caddy.
- INTERFACE: The network interface to use for the jail. Defaults to `vnet0`.
- VNET: Whether to use the iocage virtual network stack. Defaults to `on`.
- DNS_PLUGIN: This contains the name of the DNS validation plugin you'll use with Caddy to validate domain control. Visit the [Caddy download page](https://caddyserver.com/download) to see the DNS authentication plugins currently available. To build Caddy with your desired plugin, use the last part of the "Package" on that page as DNS_PLUGIN in your `caddy-config` file. E.g., if the package name is `github.com/caddy-dns/cloudflare`, you'd set `DNS_PLUGIN=cloudflare`. From that page, there are also links to the documentation for each plugin, which will describe what credentials are needed.

$CONFIG_PATH is mounted inside the jail at `/usr/local/www`.  The Caddyfile goes there, but that's also where your web pages will go, if you're serving any web content directly from this jail--that would ordinarily go in `/usr/local/www/html` inside the jail, or $CONFIG_PATH/html on your FreeNAS system.

Also, if you're going to be using TLS with this Caddy installation, HOST_NAME needs to resolve to your jail from inside your network. You'll probably need to configure this on your router. If you're unable to do so, you can edit the hosts file on your client computers to achieve this result.

### Execution

Once you've downloaded the script and prepared the configuration file, run this script (`./caddy-jail.sh`). The script will run for several minutes. When it finishes, your jail will be created and Caddy will be installed.

### Test

To test your installation, enter your Caddy jail IP address and port 2020 e.g. `192.168.1.199:2020` in a browser. If the installation was successful, the message *Hello, world!* should be displayed. 

## The Caddyfile
Caddy looks for its configuration in the Caddyfile. Its syntax is fairly simple, and is fully documented in the [Caddy Docs](https://caddyserver.com/docs/).  It's saved outside the jail in `$POOL_PATH/apps/caddy/`, so you can edit it without entering the jail.  This script installs a very basic Caddyfile which only prints "Hello, world!"; to actually act as a reverse proxy or web server, you'll need to create your own Caddyfile.  I'll discuss a few scenarios with examples of the Caddyfile below.

For a more extensively-annotated Caddyfile, see `Caddyfile.example` at `/usr/local/www/Caddyfile.example` in your jail.

### Prerequisites (Let's Encrypt)
Caddy works best when your installation is able to obtain a certificate from Let's Encrypt. When you use it this way, Caddy is able to handle all of the TLS-related configuration for you, obtain and renew certificates automatically, etc. In order for this to happen, you must meet the two requirements below:

First, you must own or control a real Internet domain name. This script obtains a TLS encryption certificate from Let's Encrypt, who will only issue for public domain names. Thus, domains like cloud.local, mycloud.lan, or nextcloud.home won't work. Domains can be very inexpensive, and in some cases, they can be free. Freenom, for example, provides domains for free if you jump through the right hoops. EasyDNS is a fine domain registrar for paid domains, costing roughly US$15 per year (which varies slightly with the top-level domain).

Second, one of these two conditions must be met in order for Let's Encrypt to validate your control over the domain name:

* You must be able and willing to open ports 80 and 443 from the entire Internet to the jail, and leave them open.
* DNS hosting for the domain name needs to be with a provider that Caddy supports. 

For example, Cloudflare provides DNS hosting at no cost, and it's well-supported by Caddy. Cloudflare also provides Dynamic DNS service, if your desired Dynamic DNS client supports their API. If it doesn't, DNS-O-Matic is a Dynamic DNS provider that will interface with many DNS hosts including Cloudflare, has a much simpler API that's more widely supported, and is also free of charge.

Due to abuse, Cloudflare has removed the ability to use its API with free domains when using Cloudflare's free plan. For this to work, you'll need to pay either for Cloudflare or for a domain (and the latter is likely less expensive). If you want to use a Freenom domain, you'll need to be able and willing to open ports 80 and 443 to your jail, so you can get your certificate without using DNS validation.

If you aren't able or willing to obtain a certificate from Let's Encrypt, Caddy can be configured with a self-signed certificate, or with no certificate (and thus no HTTPS) at all.

### No TLS
This is the simplest case of a Caddyfile.  To serve static HTML pages, the basic case can look like this:
```
*:80 {
	root * /usr/local/www/html
	file_server
}
```
This Caddyfile will serve HTML pages out of `/usr/local/www/html` over HTTP.  Nice and easy.  But suppose you want it to act as a reverse proxy?  Almost as easy:
```
*:80 {
	root * /usr/local/www/html
	file_server
	reverse_proxy /sonarr* 192.168.1.12:8989
	reverse_proxy /radarr* 192.168.1.12:9898
}
```
This will still serve static pages out of `/usr/local/www/html` over HTTP (so maybe you want to put a nice landing page there), but any requests for `/sonarr` or `/radarr` will be proxied to those respective ports on the host you specify.

### TLS with HTTP validation
This case is nearly as simple.  You'd use this if you're going expose this jail to the Internet, with ports 80 and 443 forwarded to the jail.  The Caddyfile for the static web server will look like this:
```
{
	acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
	email somebody@your_email.com
}

sub.domain.com {
	root * /usr/local/www/html
	file_server
}
```
As before, this will serve HTML pages out of `/usr/local/www/html`.  But unlike the previous example, this Caddyfile will obtain a certificate from Let's Encrypt, renew it automatically, configure TLS, and redirect HTTP to HTTPS.  

The top block here is optional, but recommended.  The first directive tells Caddy to use the Let's Encrypt staging server.  Certificates issued by this server won't be trusted by your browser, but you're much less likely to exceed the [rate limits](https://letsencrypt.org/docs/rate-limits/).  Once you're sure your system is working properly, you can comment it out.  The second directive is an email address Let's Encrypt can use to notify you of certificate expiration or other major events.  If things are working properly, you'll very rarely get an email from them.

In the second block, there are two changes:

* Your FQDN is specified here.  As noted above, you need to own this domain, and public DNS records must point it to your server.
* No port number is specified.  This allows Caddy to serve this hostname over both HTTP and HTTPS.

To implement the reverse proxy, add those lines (as shown above) to the second block.

### TLS with DNS validation
This gets a little more complicated.  DNS validation will let you obtain a certificate without your jail being accessible from the Internet.  This will require that your Caddy installation be compiled with an appropriate DNS validation plugin--to see the available options, visit the [Caddy download page](https://caddyserver.com/download), and specify it in the config file when you run the script.  The Caddyfile will look something like this:
```
{
	acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
	email somebody@your_email.com
}

sub.domain.com {
	tls {
		dns cloudflare long_api_token
	}
	root * /usr/local/www/html
	file_server
}
```
Compared to the last example, the only change is the `tls{}` block.  In that block, `dns` is a required keyword, `cloudflare` is the name of the plugin being used, and `long_api_token` is a Cloudflare API token with appropriate permissions.  The reverse proxy is added as above.

Authentication credentials vary for each supported DNS host.  The Caddy download page links to the individual plugins, which document the required credentials and how to specify them.  You'll need to make adjustments for your own situation.

### Test

You can validate your Caddyfile changes with `service caddy validate`. To commit the changes gracefully and with zero downtime, use `service caddy reload` instead of `service caddy restart`. 

## Limitations
:pushpin: *Is this still required? This may no longer be true with Caddy V2. Probably better to leave this section out altogether, at least for the moment.*

Some apps are not amenable to being served over a reverse proxy, or at least with the configuration described above. Two such apps appear to be Duplicati and Urbackup. If your app doesn't work, try doing a web search for "(app name) reverse proxy" to see if (1) it's possible at all, and (2) if any special settings are required.

## Support and Discussion

Questions or issues about this resource can be raised in [this forum thread](https://www.ixsystems.com/community/threads/reverse-proxy-using-caddy-with-optional-automatic-tls.75978/).  Be aware that any Caddyfile examples in that thread prior to August 2020 will be incorrect, as Caddy v1 used a significantly different Caddyfile syntax.

Though we'll try to help on that thread, once Caddy's up and running, the [Caddy forum](https://caddy.community/) is likely to be a better resource for its configuration, particularly with applications whose reverse proxy settings prove to be difficult.  Once you have something working, though, please post back in the iXSystems forum.
