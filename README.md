# freenas-iocage-caddy
Script to install Caddy V2 in a FreeNAS jail

Create the jail and install Caddy
`iocage create --name="caddy" -r 11.2-RELEASE ip4_addr="vnet0|192.168.0.100/24" defaultrouter="192.168.0.1" boot="on" host_hostname="caddy" vnet="on"`
