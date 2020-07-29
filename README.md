# freenas-iocage-caddy
Script to create an iocage jail on FreeNAS for the latest Caddy 2.x

This script will create an iocage jail on FreeNAS 11.3 or TrueNAS CORE 12.0 with the latest release of Caddy V2.

## Status
This script will work with FreeNAS 11.3, and it should also work with TrueNAS CORE 12.0.  Due to the EOL status of FreeBSD 11.2, it is unlikely to work reliably with earlier releases of FreeNAS.

## Usage

Many users install a variety of web applications in jails on their FreeNAS servers, and often those applications run on non-standard ports like 6789, 8181, 7878, etc. These port numbers are far from intuitive, and the applications often either don't implement HTTPS at all, or make it difficult to configure. A common recommendation to address these issues is to install a separate web server to act as a reverse proxy (allowing you to browse to simpler URLs like http://yourserver/radarr), and also to handle the TLS termination. Although popular web servers like Apache and Nginx can act as reverse proxies, configuration is complex, and neither of them handle the TLS certificates and configuration by default. This guide will cover installing Caddy in its own jail, configuring it to act as a proxy for your other applications, and optionally obtaining TLS certificates from Let's Encrypt and using them to encrypt your communications.

### Create the jail and install Caddy
You can create the jail using the FreeNAS GUI or at the command line; the following command will create it at the command line: iocage create --name="caddy" -r 11.2-RELEASE ip4_addr="vnet0|192.168.0.100/24" defaultrouter="192.168.0.1" boot="on" host_hostname="caddy" vnet="on". Adjust the IP addresses for the jail and your default gateway to match your environment. Once the jail is created, enter the jail with iocage console caddy, then install the packages with pkg install curl bash nano caddy.

### The Caddyfile
Caddy looks for its configuration in the Caddyfile. Under FreeBSD, it expects that file to be located at /usr/local/www/Caddyfile. Its syntax is fairly simple, and is fully documented in the Caddy Docs. I'll discuss a few scenarios with examples of the Caddyfile below.

### No TLS
This is the simplest possible scenario--you want Caddy to act as a reverse proxy for your other applications, but don't want it to provide TLS termination. Instead, you just want to browse to http://caddy_jail/yourapp rather than http://jail_ip:port_number. Your Caddyfile will look like this:
Code:
*:80 {
gzip
root /usr/local/www/html/
proxy /nzbget http://192.168.1.15:6789/ {
        transparent
}
proxy /tautulli http://192.168.1.23:8181 {
        transparent
        header_upstream X-Forwarded-For {remote}
}
...
}

This tells Caddy to listen on port 80 (defeating its Automatic HTTPS capabilities), look in /usr/local/www/html for its document root (so you may want to place an index.html file there with links to your web apps), and act as a transparent proxy for NZBGet and Tautulli. You can repeat the proxy blocks as many times as necessary. Some applications may need further directives, but the simple format above has been tested to work with NZBGet, Tautulli, Radarr, Sonarr, SABnzbd, and Transmission, as of this writing.

### TLS with HTTP validation
Caddy will try to obtain a trusted certificate from Let's Encrypt and use it to implement HTTPS for your web traffic. For this to work, a few conditions must be met:
You must own or control a live Internet domain (or subdomain)--I'll use sub.example.com as, well, an example.
That domain/subdomain must have published DNS records pointing to your external IP address
Ports 80 and 443 must be forwarded to your Caddy jail, and stay that way
A fourth condition isn't required in order to obtain the cert, but is pretty important when you're using it from your network:
From inside your network, sub.example.com should resolve to the Caddy jail--that is, if a user browses to http://sub.example.com, the browser will try to connect to the jail. This is something you'd need to set up either on your router, or perhaps in the hosts file on your computer if your router doesn't allow this configuration.
If all these conditions are met, only the first line of the Caddyfile needs to change compared to what's above. Rather than "*:80", it should read:
Code:
sub.example.com {


That's all that's necessary. Caddy will request, obtain, and install the cert, redirect HTTP requests to HTTPS, implement a modern, secure TLS configuration, and renew the cert as required. Keep in mind that, in order for renewals to work, ports 80 and 443 need to remain open to the Internet.

### TLS with DNS validation
You may be unable or unwilling to expose your Caddy jail to the Internet. In this case, Caddy supports DNS validation for certificate issuance. For this to work, you must meet a few conditions:
As above, you must own or control a live Internet domain--I'll again use sub.example.com as an example.
DNS for that domain must be provided by a host that either complies with RFC 2136, or has an API that Caddy supports--see the list under "DNS Providers" on the Caddy download page. Cloudflare is one DNS host who provides DNS hosting for free and has a robust API that's compatible with Caddy (I'm a satisfied customer of theirs, but otherwise unaffiliated).
And as above, sub.example.com needs to resolve to the Caddy jail on your network.
Unfortunately, the FreeBSD package for Caddy doesn't include any of the plugins needed to make DNS validation work, so we'll need to re-install it from Caddy's web site. Before doing so, run pkg lock caddy to keep future upgrades from overwriting the version we're about to download.

Then, go to the Caddy download page, set "Platform" to "FreeBSD 64-bit", and then click "Add plugins". In the menu that comes up, select the relevant DNS provider--I'll use Cloudflare for this example. Next, choose the plan as "personal", which applies if you aren't using this system for profit. Then scroll down the page and fine the line that's labeled "One-step installer script (bash)". Copy the following line (if using Cloudflare, it should be curl https://getcaddy.com | bash -s personal tls.dns.cloudflare) and paste it into the shell in your jail.

The Caddyfile needs only very minor changes compared to the first example above. Replace the first line ("*:80") with the following few lines:
Code:
your_domain_name {
tls {
        dns cloudflare
}
gzip

Finally, set the API credentials for your DNS provider: sysrc caddy_env="CLOUDFLARE_EMAIL=(cloudflare_account_email) CLOUDFLARE_API_KEY=(global_api_key)".

Note: If you aren't using Cloudflare for your DNS, you'll need to change the API credentials above, the Caddyfile, and the download command to reflect the provider you're using.

As above, you're done with the configuration.

## Enable and start Caddy
You'll need to set an email address for Caddy's use. If you're using TLS, this is the address that Let's Encrypt will send cert expiration notices to (which you shouldn't see if Caddy is working properly). If you aren't using TLS, this address isn't used at all, but the rc script still requires the variable to be set: sysrc caddy_cert_email="me@domain.com.

All the configuration's done, so you're ready to enable and start the service. Run sysrc caddy_enable="YES"; service caddy start.

### Test
Test it out! Browse to http://sub.example.com/yourapp and make sure it works. You should be redirected to HTTPS and see your app.

Limitations
Some apps are not amenable to being served over a reverse proxy, or at least with the configuration described above. Two such apps appear to be Duplicati and Urbackup. If your app doesn't work, try doing a web search for "(app name) reverse proxy" to see if (1) it's possible at all, and (2) if any special settings are required.

Support/Discussion
Questions or issues about this resource can be raised in this forum thread.

### To Do
I'd appreciate any suggestions (or, better yet, pull requests) to improve the various config files I'm using.  Most of them are adapted from the default configuration files that ship with the software in question, and have only been lightly edited to work in this application.  But if there are changes to settings or organization that could improve performance, reliability, or security, I'd like to hear about them.
