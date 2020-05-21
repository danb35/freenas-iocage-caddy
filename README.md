# freenas-iocage-caddyv2
The aim is to support Caddy V2 in a FreeNAS jail

### Currently supported

#### 1. rc.d script

This is an original work. The centrepiece is an rc.d script (in includes/caddy), which supports default methods such as `service caddy stop` and `service caddy status`, but also includes a modifed `service caddy start` method to support the Caddy V2 executable as well as the following extra commands:

1. `service caddy reload` - A config reload with zero downtime. More info at https://caddyserver.com/docs/command-line#caddy-reload
2. `service caddy validate` - Check for a valid Caddyfile configuration. More info at https://caddyserver.com/docs/command-line#caddy-validate

Additional commands may be added at a later stage if deemed useful. 

For other configurable script parameters, refer to the comments at the top of the rc.d script. At this stage, configurable script parameters include:

1. `caddy_enable` - Set to YES to enable caddy. The default is NO.
2. `caddy_bin_path` - location of the Caddy executable. The default is /usr/local/bin/caddy.
3. `caddy_config_path` - location of the Caddyfile. The default is /usr/local/www/Caddyfile

To change the defaults add lines to /etc/rc.conf. For example:
```
sysrc caddy_enable="YES"
sysrc caddy_bin_path="/usr/local/sbin/caddy"
```

Additional configurable script parameters may be added at a later stage if deemed useful. 

### To Do

#### 1. Build an install script

The install script will mirror the majority of steps below, which are presently executed manually.
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
  In a browser, enter <jail_IP>:2015. You should see 'Hello World' returned.  
  Restart the jail.
  Repeat the browser check
 ```
 
 #### 2. Support TLS with DNS validation
 At present, only **No TLS** and **TLS with HTTP validation** have been considered in the rc.d script.
 
 ### Known issues
 1. No support for automatic trust store installation on FreeBSD https://caddy.community/t/starting-with-caddy2-basic-caddyfile-trying-to-use-port-80/7473/7
 
 ### References
 1. Practical rc.d scripting https://www.freebsd.org/doc/en_US.ISO8859-1/articles/rc-scripting/
 2. Caddy V2 command line https://caddyserver.com/docs/command-line
 3. Caddy V2 release https://github.com/caddyserver/caddy/releases/tag/v2.0.0

