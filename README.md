# YunoRunner for YunoHost

[![Integration level](https://dash.yunohost.org/integration/yunorunner.svg)](https://dash.yunohost.org/appci/app/yunorunner)  
[![Install yunorunner with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=yunorunner)

> *This package allow you to install YunoRunner quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview
YunoRunner is our own CI runner for YunoHost Apps

**Shipped version:** Work in progress...

## Screenshots

![](https://user-images.githubusercontent.com/30271971/52810447-e06b5600-3092-11e9-9853-fb46e46fda65.PNG)

## Demo

* [Official demo](https://ci-apps.yunohost.org)

## YunoHost specific features

#### Supported architectures

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/ci/logs/yunorunner%20%28Community%29.svg)](https://ci-apps.yunohost.org/ci/apps/yunorunner/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/yunorunner%20%28Community%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/yunorunner/)
* Jessie x86-64b - [![Build Status](https://ci-stretch.nohost.me/ci/logs/yunorunner%20%28Community%29.svg)](https://ci-stretch.nohost.me/ci/apps/yunorunner/)

## Limitations

* You need to install [CI_package_check](https://github.com/YunoHost/CI_package_check) before YunoRunner and modify the systemd script to add the path of the script analyseCI.sh.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/yunorunner_ynh_core/issues
 * App website: https://github.com/YunoHost/yunorunner
 * YunoHost website: https://yunohost.org/

---

Developers info
----------------

**Only if you want to use a testing branch for coding, instead of merging directly into master.**
Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/yunorunner_ynh_core/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/yunorunner_ynh_core/issues/tree/testing --debug
or
sudo yunohost app upgrade yunorunner -u https://github.com/YunoHost-Apps/yunorunner_ynh_core/tree/testing --debug
```
