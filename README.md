# freenas-iocage-caddy
The aim is to develop a script to install Caddy V2 in a FreeNAS jail

### Currently supported

The centrepiece is a rc.d script, which supports default methods such as `service caddy stop` and `service caddy status`, but also includes a modifed `service caddy start` method to support the Caddy V2 executable as well as the following extra commands:

1. `service caddy reload` - A config reload with zero downtime. More info at https://caddyserver.com/docs/command-line#caddy-reload
2. `service caddy validate` - Check for a valid Caddyfile configuration. More info at https://caddyserver.com/docs/command-line#caddy-validate

Additional commands may be added at a later stage if deemed useful. 

For other configurable script parameters, refer to the comments at the top of the rc.d script. At this stage, configurable script parameters include:

1. `caddy_enable` - Set to enable caddy. The default is disabled.
2. `caddy_bin_path` - location of the Caddy executable. The default is /usr/local/bin/caddy.
3. `caddy_config_path` - location of the Caddyfile. The default is /usr/local/www/Caddyfile

To change the defaults add lines to /etc/rc.conf. For example:
```
sysrc caddy_enable="YES"
sysrc caddy_bin_path="/usr/local/sbin/caddy"
```

Additional configurable script parameters may be added at a later stage if deemed useful. 

### To Do

#### Build the install script

The script will mirror the steps below, that are presently manually executed.
 ```
# Set up the jail
 iocage create --name="caddyv2" -r 11.3-RELEASE ip4_addr="vnet0|10.1.1.45/24" defaultrouter="10.1.1.1" boot="on" host_hostname="caddyv2" vnet="on"
 iocage console caddyv2
 pkg install nano ca_root_nss

# Install the rc.d script
 mkdir -p /usr/local/etc/rc.d && cd /usr/local/etc/rc.d
 nano caddy # Paste in the text from includes/caddy
 chmod +x caddy

# Create the Caddyfile
 mkdir -p /usr/local/www && cd /usr/local/www
 nano Caddyfile # Paste in the 'Hello World' text from includes/Caddyfile

# Install the Caddy V2 executable
  fetch https://github.com/caddyserver/caddy/releases/download/v2.0.0/caddy_2.0.0_freebsd_amd64.tar.gz
  tar -xzvf caddy_2.0.0_freebsd_amd64.tar.gz
  rm caddy_2.0.0_freebsd_amd64.tar.gz

# Start and test the Caddy installation
  sysrc caddy_enable="YES"
  service caddy start
  In a browser, enter jail_IP:2015. You should see 'Hello World' returned.  
  Restart the jail.
  Repeat the browser check
 ```
