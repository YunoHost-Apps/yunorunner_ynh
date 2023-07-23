#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
pkg_dependencies="python3-venv python3-dev python3-pip sqlite3 wkhtmltopdf optipng"

yunorunner_repository="https://github.com/YunoHost/yunorunner"

yunorunner_release="52ef23a2cb37cb4fe13debca58eb589bb2f4d927"

#=================================================
# PERSONAL HELPERS
#=================================================

function tweak_yunohost() {

    # Idk why this is needed but wokay I guess >_>
    echo -e "\n127.0.0.1 $domain	#CI_APP" >> /etc/hosts

    ynh_print_info "Disabling unecessary services to save up RAM..."
    for SERVICE in mysql php7.4-fpm metronome rspamd dovecot postfix redis-server postsrsd yunohost-api avahi-daemon
    do
        systemctl stop $SERVICE
        systemctl disable $SERVICE --quiet
    done

    yunohost app makedefault -d "$domain" $app

}

function setup_lxd() {
    if ! yunohost app list --output-as json --quiet | jq -e '.apps[] | select(.id == "lxd")' >/dev/null
    then
        ynh_script_progression --message="Installing LXD... (this make take a long time!"
        yunohost app install --force https://github.com/YunoHost-Apps/lxd_ynh
    fi

    mkdir .lxd
    pushd .lxd

    ynh_print_info "Configuring lxd..."

    if [ "$cluster" == "cluster" ]
    then
        local free_space=$(df --output=avail / | sed 1d)
        local btrfs_size=$(( $free_space * 90 / 100 / 1024 / 1024 ))
        local lxc_network=$((1 + $RANDOM % 254))

        yunohost firewall allow TCP 8443
        cat >./preseed.conf <<EOF
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
        cat ./preseed.conf | lxd init --preseed
        rm ./preseed.conf
        lxc config set core.https_address [::]
    else
        lxd init --auto #--storage-backend=dir
    fi

    popd

    # ci_user will be the one launching job, gives it permission to run lxd commands
    usermod -a -G lxd $app

    ynh_exec_as $app lxc remote add yunohost https://devbaseimgs.yunohost.org --public --accept-certificate
}

function add_cron_jobs() {
    ynh_script_progression --message="Configuring the cron jobs.."

    # Cron tasks
    cat >>  "/etc/cron.d/yunorunner" << EOF
# self-upgrade every night
0 3 * * * root "$final_path/maintenance/self_upgrade.sh" >> "$final_path/maintenance/self_upgrade.log" 2>&1
EOF
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================

ynh_maintenance_mode_ON () {
	# Load value of $path_url and $domain from the config if their not set
	if [ -z $path_url ]; then
		path_url=$(ynh_app_setting_get $app path)
	fi
	if [ -z $domain ]; then
		domain=$(ynh_app_setting_get $app domain)
	fi

	# Create an html to serve as maintenance notice
	echo "<!DOCTYPE html>
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
</html>" > "/var/www/html/maintenance.$app.html"

	# Create a new nginx config file to redirect all access to the app to the maintenance notice instead.
	echo "# All request to the app will be redirected to ${path_url}_maintenance and fall on the maintenance notice
rewrite ^${path_url}/(.*)$ ${path_url}_maintenance/? redirect;
# Use another location, to not be in conflict with the original config file
location ${path_url}_maintenance/ {
alias /var/www/html/ ;

try_files maintenance.$app.html =503;

# Include SSOWAT user panel.
include conf.d/yunohost_panel.conf.inc;
}" > "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf"

	# The current config file will redirect all requests to the root of the app.
	# To keep the full path, we can use the following rewrite rule:
	# 	rewrite ^${path_url}/(.*)$ ${path_url}_maintenance/\$1? redirect;
	# The difference will be in the $1 at the end, which keep the following queries.
	# But, if it works perfectly for a html request, there's an issue with any php files.
	# This files are treated as simple files, and will be downloaded by the browser.
	# Would be really be nice to be able to fix that issue. So that, when the page is reloaded after the maintenance, the user will be redirected to the real page he was.

	systemctl reload nginx
}

ynh_maintenance_mode_OFF () {
	# Load value of $path_url and $domain from the config if their not set
	if [ -z $path_url ]; then
		path_url=$(ynh_app_setting_get $app path)
	fi
	if [ -z $domain ]; then
		domain=$(ynh_app_setting_get $app domain)
	fi

	# Rewrite the nginx config file to redirect from ${path_url}_maintenance to the real url of the app.
	echo "rewrite ^${path_url}_maintenance/(.*)$ ${path_url}/\$1 redirect;" > "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf"
	systemctl reload nginx

	# Sleep 4 seconds to let the browser reload the pages and redirect the user to the app.
	sleep 4

	# Then remove the temporary files used for the maintenance.
	rm "/var/www/html/maintenance.$app.html"
	rm "/etc/nginx/conf.d/$domain.d/maintenance.$app.conf"

	systemctl reload nginx
}
