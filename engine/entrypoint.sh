#!/bin/bash
echo "Start entrypoint..."
set -e

# remove write permission for (g)roup and (o)ther (required by cron)
chmod -R go-w /etc/cron.d

# update default values of PAM environment variables (used by CRON scripts)
env | while read -r LINE; do
    IFS="=" read VAR VAL <<< ${LINE}
    sed --in-place "/^${VAR}[[:blank:]=]/d" /etc/security/pam_env.conf || true
    echo "${VAR} DEFAULT=\"${VAL}\"" >> /etc/security/pam_env.conf
done

# Start cron
service cron start
crontab -uroot /etc/cron.d/crontab

# Install phpunit in dev environnement with xdebug to run unit test and have code coverage options
if [ "$ENV" == "dev" ]; then
    apt-get install -yqq wget
    wget https://phar.phpunit.de/phpunit-6.1.phar
    chmod +x phpunit-6.1.phar
    mv phpunit-6.1.phar /usr/local/bin/phpunit
fi

echo "Done!"

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"
