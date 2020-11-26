#!/bin/sh
set -euo pipefail

php /root/install.php

chown -R www-data:www-data /var/www/html

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
