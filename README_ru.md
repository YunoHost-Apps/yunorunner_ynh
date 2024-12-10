<!--
Важно: этот README был автоматически сгенерирован <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>
Он НЕ ДОЛЖЕН редактироваться вручную.
-->

# YunoRunner для YunoHost

[![Уровень интеграции](https://apps.yunohost.org/badge/integration/yunorunner)](https://ci-apps.yunohost.org/ci/apps/yunorunner/)
![Состояние работы](https://apps.yunohost.org/badge/state/yunorunner)
![Состояние сопровождения](https://apps.yunohost.org/badge/maintained/yunorunner)

[![Установите YunoRunner с YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=yunorunner)

*[Прочтите этот README на других языках.](./ALL_README.md)*

> *Этот пакет позволяет Вам установить YunoRunner быстро и просто на YunoHost-сервер.*  
> *Если у Вас нет YunoHost, пожалуйста, посмотрите [инструкцию](https://yunohost.org/install), чтобы узнать, как установить его.*

## Обзор

Yunorunner is a CI server for YunoHost apps.

It is based on Incus / LXC and uses [package_check](https://github.com/YunoHost/package_check).


**Поставляемая версия:** 2023.04.05~ynh5

## Снимки экрана

![Снимок экрана YunoRunner](./doc/screenshots/screenshot.png)

## Документация и ресурсы

- Репозиторий кода главной ветки приложения: <https://github.com/YunoHost/yunorunner>
- Магазин YunoHost: <https://apps.yunohost.org/app/yunorunner>
- Сообщите об ошибке: <https://github.com/YunoHost-Apps/yunorunner_ynh/issues>

## Информация для разработчиков

Пришлите Ваш запрос на слияние в [ветку `testing`](https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing).

Чтобы попробовать ветку `testing`, пожалуйста, сделайте что-то вроде этого:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing --debug
или
sudo yunohost app upgrade yunorunner -u https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing --debug
```

**Больше информации о пакетировании приложений:** <https://yunohost.org/packaging_apps>
