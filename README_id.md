<!--
N.B.: README ini dibuat secara otomatis oleh <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Ini TIDAK boleh diedit dengan tangan.
-->

# YunoRunner untuk YunoHost

[![Tingkat integrasi](https://dash.yunohost.org/integration/yunorunner.svg)](https://ci-apps.yunohost.org/ci/apps/yunorunner/) ![Status kerja](https://ci-apps.yunohost.org/ci/badges/yunorunner.status.svg) ![Status pemeliharaan](https://ci-apps.yunohost.org/ci/badges/yunorunner.maintain.svg)

[![Pasang YunoRunner dengan YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=yunorunner)

*[Baca README ini dengan bahasa yang lain.](./ALL_README.md)*

> *Paket ini memperbolehkan Anda untuk memasang YunoRunner secara cepat dan mudah pada server YunoHost.*  
> *Bila Anda tidak mempunyai YunoHost, silakan berkonsultasi dengan [panduan](https://yunohost.org/install) untuk mempelajari bagaimana untuk memasangnya.*

## Ringkasan

Yunorunner is a CI server for YunoHost apps.

It is based on Incus / LXC and uses [package_check](https://github.com/YunoHost/package_check).


**Versi terkirim:** 2023.04.05~ynh4

## Tangkapan Layar

![Tangkapan Layar pada YunoRunner](./doc/screenshots/screenshot.png)

## Dokumentasi dan sumber daya

- Depot kode aplikasi hulu: <https://github.com/YunoHost/yunorunner>
- Gudang YunoHost: <https://apps.yunohost.org/app/yunorunner>
- Laporkan bug: <https://github.com/YunoHost-Apps/yunorunner_ynh/issues>

## Info developer

Silakan kirim pull request ke [`testing` branch](https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing).

Untuk mencoba branch `testing`, silakan dilanjutkan seperti:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing --debug
atau
sudo yunohost app upgrade yunorunner -u https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing --debug
```

**Info lebih lanjut mengenai pemaketan aplikasi:** <https://yunohost.org/packaging_apps>
