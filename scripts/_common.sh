#!/bin/bash

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

# Internal helper design to allow helpers to use getopts to manage their arguments
#
# example: function my_helper()
# {
#     declare -Ar args_array=( [a]=arg1= [b]=arg2= [c]=arg3 )
#     local arg1
#     local arg2
#     local arg3
#     ynh_handle_getopts_args "$@"
#
#     [...]
# }
# my_helper --arg1 "val1" -b val2 -c
#
# usage: ynh_handle_getopts_args "$@"
# | arg: $@    - Simply "$@" to tranfert all the positionnal arguments to the function
#
# This helper need an array, named "args_array" with all the arguments used by the helper
# 	that want to use ynh_handle_getopts_args
# Be carreful, this array has to be an associative array, as the following example:
# declare -Ar args_array=( [a]=arg1 [b]=arg2= [c]=arg3 )
# Let's explain this array:
# a, b and c are short options, -a, -b and -c
# arg1, arg2 and arg3 are the long options associated to the previous short ones. --arg1, --arg2 and --arg3
# For each option, a short and long version has to be defined.
# Let's see something more significant
# declare -Ar args_array=( [u]=user [f]=finalpath= [d]=database )
#
# NB: Because we're using 'declare' without -g, the array will be declared as a local variable.
#
# Please keep in mind that the long option will be used as a variable to store the values for this option.
# For the previous example, that means that $finalpath will be fill with the value given as argument for this option.
#
# Also, in the previous example, finalpath has a '=' at the end. That means this option need a value.
# So, the helper has to be call with --finalpath /final/path, --finalpath=/final/path or -f /final/path, the variable $finalpath will get the value /final/path
# If there's many values for an option, -f /final /path, the value will be separated by a ';' $finalpath=/final;/path
# For an option without value, like --user in the example, the helper can be called only with --user or -u. $user will then get the value 1.
#
# To keep a retrocompatibility, a package can still call a helper, using getopts, with positional arguments.
# The "legacy mode" will manage the positional arguments and fill the variable in the same order than they are given in $args_array.
# e.g. for `my_helper "val1" val2`, arg1 will be filled with val1, and arg2 with val2.
ynh_handle_getopts_args () {
	# Manage arguments only if there's some provided
	set +x
	if [ $# -ne 0 ]
	then
		# Store arguments in an array to keep each argument separated
		local arguments=("$@")

		# For each option in the array, reduce to short options for getopts (e.g. for [u]=user, --user will be -u)
		# And built parameters string for getopts
		# ${!args_array[@]} is the list of all keys in the array (A key is 'u' in [u]=user, user is a value)
		local getopts_parameters=""
		local key=""
		for key in "${!args_array[@]}"
		do
			# Concatenate each keys of the array to build the string of arguments for getopts
			# Will looks like 'abcd' for -a -b -c -d
			# If the value of a key finish by =, it's an option with additionnal values. (e.g. --user bob or -u bob)
			# Check the last character of the value associate to the key
			if [ "${args_array[$key]: -1}" = "=" ]
			then
				# For an option with additionnal values, add a ':' after the letter for getopts.
				getopts_parameters="${getopts_parameters}${key}:"
			else
				getopts_parameters="${getopts_parameters}${key}"
			fi
			# Check each argument given to the function
			local arg=""
			# ${#arguments[@]} is the size of the array
			for arg in `seq 0 $(( ${#arguments[@]} - 1 ))`
			do
				# And replace long option (value of the key) by the short option, the key itself
				# (e.g. for [u]=user, --user will be -u)
				# Replace long option with =
				arguments[arg]="${arguments[arg]//--${args_array[$key]}/-${key} }"
				# And long option without =
				arguments[arg]="${arguments[arg]//--${args_array[$key]%=}/-${key}}"
			done
		done

		# Read and parse all the arguments
		# Use a function here, to use standart arguments $@ and be able to use shift.
		parse_arg () {
			# Read all arguments, until no arguments are left
			while [ $# -ne 0 ]
			do
				# Initialize the index of getopts
				OPTIND=1
				# Parse with getopts only if the argument begin by -, that means the argument is an option
				# getopts will fill $parameter with the letter of the option it has read.
				local parameter=""
				getopts ":$getopts_parameters" parameter || true

				if [ "$parameter" = "?" ]
				then
					ynh_die "Invalid argument: -${OPTARG:-}"
				elif [ "$parameter" = ":" ]
				then
					ynh_die "-$OPTARG parameter requires an argument."
				else
					local shift_value=1
					# Use the long option, corresponding to the short option read by getopts, as a variable
					# (e.g. for [u]=user, 'user' will be used as a variable)
					# Also, remove '=' at the end of the long option
					# The variable name will be stored in 'option_var'
					local option_var="${args_array[$parameter]%=}"
					# If this option doesn't take values
					# if there's a '=' at the end of the long option name, this option takes values
					if [ "${args_array[$parameter]: -1}" != "=" ]
					then
						# 'eval ${option_var}' will use the content of 'option_var'
						eval ${option_var}=1
					else
						# Read all other arguments to find multiple value for this option.
						# Load args in a array
						local all_args=("$@")

						# If the first argument is longer than 2 characters,
						# There's a value attached to the option, in the same array cell
						if [ ${#all_args[0]} -gt 2 ]; then
							# Remove the option and the space, so keep only the value itself.
							all_args[0]="${all_args[0]#-${parameter} }"
							# Reduce the value of shift, because the option has been removed manually
							shift_value=$(( shift_value - 1 ))
						fi

						# Then read the array value per value
						for i in `seq 0 $(( ${#all_args[@]} - 1 ))`
						do
							# If this argument is an option, end here.
							if [ "${all_args[$i]:0:1}" == "-" ] || [ -z "${all_args[$i]}" ]
							then
								# Ignore the first value of the array, which is the option itself
								if [ "$i" -ne 0 ]; then
									break
								fi
							else
								# Declare the content of option_var as a variable.
								eval ${option_var}=""
								# Else, add this value to this option
								# Each value will be separated by ';'
								if [ -n "${!option_var}" ]
								then
									# If there's already another value for this option, add a ; before adding the new value
									eval ${option_var}+="\;"
								fi
								eval ${option_var}+=\"${all_args[$i]}\"
								shift_value=$(( shift_value + 1 ))
							fi
						done
					fi
				fi

				# Shift the parameter and its argument(s)
				shift $shift_value
			done
		}

		# LEGACY MODE
		# Check if there's getopts arguments
		if [ "${arguments[0]:0:1}" != "-" ]
		then
			# If not, enter in legacy mode and manage the arguments as positionnal ones.
			echo "! Helper used in legacy mode !"
			for i in `seq 0 $(( ${#arguments[@]} -1 ))`
			do
				# Use getopts_parameters as a list of key of the array args_array
				# Remove all ':' in getopts_parameters
				getopts_parameters=${getopts_parameters//:}
				# Get the key from getopts_parameters, by using the key according to the position of the argument.
				key=${getopts_parameters:$i:1}
				# Use the long option, corresponding to the key, as a variable
				# (e.g. for [u]=user, 'user' will be used as a variable)
				# Also, remove '=' at the end of the long option
				# The variable name will be stored in 'option_var'
				local option_var="${args_array[$key]%=}"

				# Store each value given as argument in the corresponding variable
				# The values will be stored in the same order than $args_array
				eval ${option_var}+=\"${arguments[$i]}\"
			done
		else
			# END LEGACY MODE
			# Call parse_arg and pass the modified list of args as an array of arguments.
			parse_arg "${arguments[@]}"
		fi
	fi
	set -x
}

#=================================================

# Read the value of a key in a ynh manifest file
#
# usage: ynh_read_manifest manifest key
# | arg: manifest - Path of the manifest to read
# | arg: key - Name of the key to find
ynh_read_manifest () {
	manifest="$1"
	key="$2"
	python3 -c "import sys, json;print(json.load(open('$manifest', encoding='utf-8'))['$key'])"
}

# Read the upstream version from the manifest
# The version number in the manifest is defined by <upstreamversion>~ynh<packageversion>
# For example : 4.3-2~ynh3
# This include the number before ~ynh
# In the last example it return 4.3-2
#
# usage: ynh_app_upstream_version
ynh_app_upstream_version () {
    manifest_path="../manifest.json"
    if [ ! -e "$manifest_path" ]; then
        manifest_path="../settings/manifest.json"	# Into the restore script, the manifest is not at the same place
    fi
    version_key=$(ynh_read_manifest "$manifest_path" "version")
    echo "${version_key/~ynh*/}"
}


# Read package version from the manifest
# The version number in the manifest is defined by <upstreamversion>~ynh<packageversion>
# For example : 4.3-2~ynh3
# This include the number after ~ynh
# In the last example it return 3
#
# usage: ynh_app_package_version
ynh_app_package_version () {
    manifest_path="../manifest.json"
    if [ ! -e "$manifest_path" ]; then
        manifest_path="../settings/manifest.json"	# Into the restore script, the manifest is not at the same place
    fi
    version_key=$(ynh_read_manifest "$manifest_path" "version")
    echo "${version_key/*~ynh/}"
}

# Checks the app version to upgrade with the existing app version and returns:
# - UPGRADE_APP if the upstream app version has changed
# - UPGRADE_PACKAGE if only the YunoHost package has changed
#
## It stops the current script without error if the package is up-to-date
#
# This helper should be used to avoid an upgrade of an app, or the upstream part
# of it, when it's not needed
#
# To force an upgrade, even if the package is up to date,
# you have to set the variable YNH_FORCE_UPGRADE before.
# example: sudo YNH_FORCE_UPGRADE=1 yunohost app upgrade MyApp

# usage: ynh_check_app_version_changed
ynh_check_app_version_changed () {
  local force_upgrade=${YNH_FORCE_UPGRADE:-0}
  local package_check=${PACKAGE_CHECK_EXEC:-0}

  # By default, upstream app version has changed
  local return_value="UPGRADE_APP"

  local current_version=$(ynh_read_manifest "/etc/yunohost/apps/$YNH_APP_INSTANCE_NAME/manifest.json" "version" || echo 1.0)
  local current_upstream_version="${current_version/~ynh*/}"
  local update_version=$(ynh_read_manifest "../manifest.json" "version" || echo 1.0)
  local update_upstream_version="${update_version/~ynh*/}"

  if [ "$current_version" == "$update_version" ] ; then
      # Complete versions are the same
      if [ "$force_upgrade" != "0" ]
      then
        echo "Upgrade forced by YNH_FORCE_UPGRADE." >&2
        unset YNH_FORCE_UPGRADE
      elif [ "$package_check" != "0" ]
      then
        echo "Upgrade forced for package check." >&2
      else
        ynh_die "Up-to-date, nothing to do" 0
      fi
  elif [ "$current_upstream_version" == "$update_upstream_version" ] ; then
    # Upstream versions are the same, only YunoHost package versions differ
    return_value="UPGRADE_PACKAGE"
  fi
  echo $return_value
}

#=================================================

# Reload (or other actions) a service and print a log in case of failure.
#
# usage: ynh_system_reload service_name [action]
# | arg: -n, --service_name= - Name of the service to reload
# | arg: -a, --action= - Action to perform with systemctl. Default: reload
ynh_system_reload () {
        # Declare an array to define the options of this helper.
        declare -Ar args_array=( [n]=service_name= [a]=action= )
        local service_name
        local action
        # Manage arguments with getopts
        ynh_handle_getopts_args "$@"
        local action=${action:-reload}

        # Reload, restart or start and print the log if the service fail to start or reload
        systemctl $action $service_name || ( journalctl --lines=20 -u $service_name >&2 && false)
}

#=================================================

# Delete a file checksum from the app settings
#
# $app should be defined when calling this helper
#
# usage: ynh_remove_file_checksum file
# | arg: file - The file for which the checksum will be deleted
ynh_delete_file_checksum () {
	local checksum_setting_name=checksum_${1//[\/ ]/_}	# Replace all '/' and ' ' by '_'
	ynh_app_setting_delete $app $checksum_setting_name
}

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
