# freenas-iocage-caddy
Script to install Caddy V2 in a FreeNAS jail

Create the jail and install Caddy `iocage create --name="caddyv2" -r 11.3-RELEASE ip4_addr="vnet0|192.168.0.100/24" defaultrouter="192.168.0.1" boot="on" host_hostname="caddyv2" vnet="on"`
