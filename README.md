# YunoRunner for YunoHost

[![Integration level](https://dash.yunohost.org/integration/APP.svg)](https://dash.yunohost.org/appci/app/yunorunner)  
[![Install YunoRunner with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=yunorunner)

> *This package allow you to install YunoRunner quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview
YunoRunner is our own CI runner for YunoHost Apps

**Shipped version:** Work in progress...

#### Supported architectures

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/jenkins/job/APP%20(Community)/badge/icon)](https://ci-apps.yunohost.org/jenkins/job/yunorunner%20(Community)/)
* ARMv8-A - [![Build Status](https://ci-apps.yunohost.org/jenkins/job/APP%20(Community)%20(%7EARM%7E)/badge/icon)](https://ci-apps.yunohost.org/jenkins/job/yunorunner%20(Community)%20(%7EARM%7E)/)
* Jessie x86-64b - [![Build Status](https://ci-stretch.nohost.me/jenkins/job/leed%20(Community)/badge/icon)](https://ci-stretch.nohost.me/jenkins/job/yunorunner%20(Community)/)

## Limitations

* You need to install [CI_package_check](https://github.com/YunoHost/CI_package_check) before YunoRunner and modify the systemd script to add the path of the script analyseCI.sh.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/yunorunner_ynh/issues
 * YunoHost website: https://yunohost.org/
