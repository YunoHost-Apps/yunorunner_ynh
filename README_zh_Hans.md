<!--
注意：此 README 由 <https://github.com/YunoHost/apps/tree/master/tools/readme_generator> 自动生成
请勿手动编辑。
-->

# YunoHost 上的 YunoRunner

[![集成程度](https://apps.yunohost.org/badge/integration/yunorunner)](https://ci-apps.yunohost.org/ci/apps/yunorunner/)
![工作状态](https://apps.yunohost.org/badge/state/yunorunner)
![维护状态](https://apps.yunohost.org/badge/maintained/yunorunner)

[![使用 YunoHost 安装 YunoRunner](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=yunorunner)

*[阅读此 README 的其它语言版本。](./ALL_README.md)*

> *通过此软件包，您可以在 YunoHost 服务器上快速、简单地安装 YunoRunner。*  
> *如果您还没有 YunoHost，请参阅[指南](https://yunohost.org/install)了解如何安装它。*

## 概况

Yunorunner is a CI server for YunoHost apps.

It is based on Incus / LXC and uses [package_check](https://github.com/YunoHost/package_check).


**分发版本：** 2023.04.05~ynh5

## 截图

![YunoRunner 的截图](./doc/screenshots/screenshot.png)

## 文档与资源

- 上游应用代码库： <https://github.com/YunoHost/yunorunner>
- YunoHost 商店： <https://apps.yunohost.org/app/yunorunner>
- 报告 bug： <https://github.com/YunoHost-Apps/yunorunner_ynh/issues>

## 开发者信息

请向 [`testing` 分支](https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing) 发送拉取请求。

如要尝试 `testing` 分支，请这样操作：

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing --debug
或
sudo yunohost app upgrade yunorunner -u https://github.com/YunoHost-Apps/yunorunner_ynh/tree/testing --debug
```

**有关应用打包的更多信息：** <https://yunohost.org/packaging_apps>
