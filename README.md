# YunoRunner for YunoHost

[![Integration level](https://dash.yunohost.org/integration/yunorunner.svg)](https://dash.yunohost.org/appci/app/yunorunner) ![](https://ci-apps.yunohost.org/ci/badges/yunorunner.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/yunorunner.maintain.svg)  
[![Install YunoRunner with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=yunorunner)

> *This package allows you to install YunoRunner quickly and simply on a YunoHost server.  
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Overview
YunoRunner is our own CI runner for YunoHost Apps

**Shipped version:** 2021-03-05

## Screenshots

![](https://user-images.githubusercontent.com/30271971/52810447-e06b5600-3092-11e9-9853-fb46e46fda65.PNG)

## Demo

* [Official demo](https://ci-apps.yunohost.org)

## YunoHost specific features

#### Supported architectures

* x86-64 - [![Build Status](https://ci-apps.yunohost.org/ci/logs/yunorunner.svg)](https://ci-apps.yunohost.org/ci/apps/yunorunner/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/yunorunner.svg)](https://ci-apps-arm.yunohost.org/ci/apps/yunorunner/)

## Limitations

* You need to install [CI_package_check](https://github.com/YunoHost/CI_package_check) using the build_CI.sh script before installing YunoRunner
* When YunoRunner is installed, modify the systemd script to add the path of the script analyseCI.sh. The default systemd is configured to `/home/CI_package_check/analyseCI.sh`

## Links

 * Report a bug: https://github.com/YunoHost-Apps/yunorunner_ynh_core/issues
 * App website: https://github.com/YunoHost/yunorunner
 * Upstream app repository: https://github.com/YunoHost/yunorunner
 * YunoHost website: https://yunohost.org/

---

## Developer info

Please send your pull request to the [testing branch](https://github.com/YunoHost-Apps/yunorunner_ynh_core/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/yunorunner_ynh_core/tree/testing --debug
or
sudo yunohost app upgrade yunorunner -u https://github.com/YunoHost-Apps/yunorunner_ynh_core/tree/testing --debug
```
