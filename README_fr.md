# YunoRunner pour YunoHost

[![Niveau d'intégration](https://dash.yunohost.org/integration/yunorunner.svg)](https://dash.yunohost.org/appci/app/yunorunner) ![](https://ci-apps.yunohost.org/ci/badges/yunorunner.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/yunorunner.maintain.svg)  
[![Installer YunoRunner avec YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=yunorunner)

*[Read this readme in english.](./README.md)*
*[Lire ce readme en français.](./README_fr.md)*

> *Ce package vous permet d'installer YunoRunner rapidement et simplement sur un serveur YunoHost.
Si vous n'avez pas YunoHost, regardez [ici](https://yunohost.org/#/install) pour savoir comment l'installer et en profiter.*

## Vue d'ensemble

Runner d'intégration continue de YunoHost

**Version incluse :** 2022.01.18~ynh2



## Captures d'écran

![](./doc/screenshots/screenshot.png)

## Avertissements / informations importantes

## Limitations

* You need to install [CI_package_check](https://github.com/YunoHost/CI_package_check) using the `install.sh` script before installing YunoRunner
* When YunoRunner is installed, modify the systemd script to add the path of the script `analyseCI.sh`. The default systemd is configured to `/home/CI_package_check/analyseCI.sh`

## Documentations et ressources

* Dépôt de code officiel de l'app : https://github.com/YunoHost/yunorunner
* Documentation YunoHost pour cette app : https://yunohost.org/app_yunorunner
* Signaler un bug : https://github.com/YunoHost-Apps/yunorunner_ynh/issues

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.
```
sudo yunohost app install https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing --debug
ou
sudo yunohost app upgrade yunorunner -u https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications :** https://yunohost.org/packaging_apps