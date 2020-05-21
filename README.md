# freenas-iocage-caddy
Script to install Caddy V2 in a FreeNAS jail

Create the jail and install Caddy `iocage create --name="caddyv2" -r 11.3-RELEASE ip4_addr="vnet0|10.1.1.45/24" defaultrouter="10.1.1.1" boot="on" host_hostname="caddyv2" vnet="on"`

 ```
 iocage console caddyv2
 mkdir -p /usr/local/etc/rc.d
 cd /usr/local/etc/rc.d
 pkg install nano
 nano caddy` and paste in the text from includes/caddy
 ```
