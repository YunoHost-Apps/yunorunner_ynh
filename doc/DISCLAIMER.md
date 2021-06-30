* Any known limitations, constrains or stuff not working, such as (but not limited to):
    * You need to install [CI_package_check](https://github.com/YunoHost/CI_package_check) using the build_CI.sh script before installing YunoRunner
    * When YunoRunner is installed, modify the systemd script to add the path of the script analyseCI.sh. The default systemd is configured to `/home/CI_package_check/analyseCI.sh`
