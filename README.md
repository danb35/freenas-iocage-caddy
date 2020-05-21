# freenas-iocage-caddy
Script to install Caddy V2 in a FreeNAS jail

 ```
# Set up the jail
 iocage create --name="caddyv2" -r 11.3-RELEASE ip4_addr="vnet0|10.1.1.45/24" defaultrouter="10.1.1.1" boot="on" host_hostname="caddyv2" vnet="on"
 iocage console caddyv2
 pkg install nano ca_root_nss

# Install the rc.d script
 mkdir -p /usr/local/etc/rc.d && cd /usr/local/etc/rc.d
 nano caddy` and paste in the text from includes/caddy
 chmod +x caddy

# Create the Caddyfile
 mkdir -p /usr/local/www && cd /usr/local/www
 touch Caddyfile
 
# Install the Caddy V2 port
  fetch https://github.com/caddyserver/caddy/releases/download/v2.0.0/caddy_2.0.0_freebsd_amd64.tar.gz
  tar -xzvf caddy_2.0.0_freebsd_amd64.tar.gz
  rm caddy_2.0.0_freebsd_amd64.tar.gz
 ```
