#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

yunorunner_repository="https://github.com/YunoHost/yunorunner"

yunorunner_release="52ef23a2cb37cb4fe13debca58eb589bb2f4d927"

#=================================================
# PERSONAL HELPERS
#=================================================

tweak_yunohost() {
    # Idk why this is needed but wokay I guess >_>
    echo -e "\n127.0.0.1 $domain	#CI_APP" >> /etc/hosts

    ynh_print_info "Disabling unecessary services to save up RAM..."
    for SERVICE in mysql php7.4-fpm metronome rspamd dovecot postfix redis-server postsrsd yunohost-api avahi-daemon; do
        systemctl stop $SERVICE
        systemctl disable $SERVICE --quiet
    done

    yunohost app makedefault -d "$domain" $app
}

setup_lxd() {
    if ! yunohost app list --output-as json --quiet | jq -e '.apps[] | select(.id == "lxd")' >/dev/null; then
        ynh_script_progression --message="Installing LXD... (this make take a long time!"
        yunohost app install --force https://github.com/YunoHost-Apps/lxd_ynh
    fi

    ynh_print_info "Configuring lxd..."

    if [ "$cluster" -eq 1 ]; then
        setup_lxd
    else
        lxd init --auto # --storage-backend=dir
    fi

    # ci_user will be the one launching job, gives it permission to run lxd commands
    usermod -a -G lxd "$app"

    ynh_exec_as "$app" lxc remote add yunohost https://devbaseimgs.yunohost.org --public --accept-certificate
}

exposed_ports_if_cluster() {
    if [ "$cluster" -eq 1 ]; then
        echo "8443"
    fi
}

setup_lxd_cluster() {
    local free_space=$(df --output=avail / | sed 1d)
    local btrfs_size=$(( free_space * 90 / 100 / 1024 / 1024 ))
    local lxc_network=$((1 + RANDOM % 254))

    yunohost firewall allow TCP 8443

    tmpfile=$(mktemp --suffix=.preseed.yml)
    cat >"$tmpfile" <<EOF
config:
  cluster.https_address: $domain:8443
  core.https_address: ${domain}:8443
  core.trust_password: ${yuno_pwd}
networks:
- config:
    ipv4.address: 192.168.${lxc_network}.1/24
    ipv4.nat: "true"
    ipv6.address: none
  description: ""
  name: lxdbr0
  type: bridge
  project: default
storage_pools:
- config:
    size: ${btrfs_size}GB
    source: /var/lib/lxd/disks/local.img
  description: ""
  name: local
  driver: btrfs
profiles:
- config: {}
  description: Default LXD profile
  devices:
    lxdbr0:
      nictype: bridged
      parent: lxdbr0
      type: nic
    root:
      path: /
      pool: local
      type: disk
  name: default
projects:
- config:
    features.images: "true"
    features.networks: "true"
    features.profiles: "true"
    features.storage.volumes: "true"
  description: Default LXD project
  name: default
cluster:
  server_name: ${domain}
  enabled: true
EOF
    lxd init --preseed < "$tmpfile"
    rm "$tmpfile"

    lxc config set core.https_address "[::]"
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================

ynh_maintenance_mode_ON () {
    # Create an html to serve as maintenance notice
    cat > "/var/www/html/maintenance.$app.html" <<EOF
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="refresh" content="3">
        <title>Your app $app is currently under maintenance!</title>
        <style>
            body {
                width: 70em;
                margin: 0 auto;
            }
        </style>
    </head>
    <body>
        <h1>Your app $app is currently under maintenance!</h1>
        <p>This app has been put under maintenance by your administrator at $(date)</p>
        <p>Please wait until the maintenance operation is done. This page will be reloaded as soon as your app will be back.</p>
    </body>
</html>
EOF

    # Create a new nginx config file to redirect all access to the app to the maintenance notice instead.
    cat > "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf" <<EOF
# All request to the app will be redirected to ${path}_maintenance and fall on the maintenance notice
rewrite ^${path}/(.*)$ ${path}_maintenance/? redirect;
# Use another location, to not be in conflict with the original config file
location ${path}_maintenance/ {
    alias /var/www/html/ ;
    try_files maintenance.$app.html =503;

    # Include SSOWAT user panel.
    include conf.d/yunohost_panel.conf.inc;
}
EOF

    # The current config file will redirect all requests to the root of the app.
    # To keep the full path, we can use the following rewrite rule:
    # rewrite ^${path}/(.*)$ ${path}_maintenance/\$1? redirect;
    # The difference will be in the $1 at the end, which keep the following queries.
    # But, if it works perfectly for a html request, there's an issue with any php files.
    # This files are treated as simple files, and will be downloaded by the browser.
    # Would be really be nice to be able to fix that issue. So that, when the page is reloaded after the maintenance, the user will be redirected to the real page he was.
    systemctl reload nginx
}

ynh_maintenance_mode_OFF () {
    # Rewrite the nginx config file to redirect from ${path}_maintenance to the real url of the app.
    echo "rewrite ^${path}_maintenance/(.*)$ ${path}/\$1 redirect;" > "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf"
    systemctl reload nginx

    # Sleep 4 seconds to let the browser reload the pages and redirect the user to the app.
    sleep 4

    # Then remove the temporary files used for the maintenance.
    rm "/var/www/html/maintenance.$app.html"
    rm "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf"

    systemctl reload nginx
}
