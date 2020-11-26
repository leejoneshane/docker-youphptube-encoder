FROM php:7-apache

ENV DOMAIN your.domain
ENV DOMAIN_PROTOCOL http
ENV SITE_TITLE your_site_title
ENV ADMIN_PASSWORD password
ENV ADMIN_EMAIL webmaster@your.domain
ENV DB_HOST localhost
ENV DB_USER root
ENV DB_PASSWORD password
ENV SALT your.salt
ENV LANG en

ADD configuration.php /root/
ADD entrypoint.sh /usr/local/bin/
ADD gencerts.sh /usr/local/bin/
WORKDIR /var/www/html

RUN apt-get update \
    && apt-get install -y wget git zip default-libmysqlclient-dev libbz2-dev libmemcached-dev libsasl2-dev libfreetype6-dev libicu-dev libjpeg-dev libmemcachedutil2 libpng-dev libxml2-dev mariadb-client ffmpeg libimage-exiftool-perl python curl python-pip libzip-dev libonig-dev \
    && docker-php-ext-configure gd --with-freetype=/usr/include --with-jpeg=/usr/include \
    && docker-php-ext-install -j$(nproc) bcmath bz2 calendar exif gd gettext iconv intl mbstring mysqli opcache pdo_mysql zip \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /root/.cache \
    && a2enmod rewrite \
    && pip install -U youtube-dl \
    && sed -ri \
           -e 's!^(max_execution_time = )(.*)$!\1 72000!g' \
           -e 's!^(post_max_size = )(.*)$!\1 10G!g' \
           -e 's!^(upload_max_filesize = )(.*)$!\1 10G!g' \
           -e 's!^(memory_limit = )(.*)$!\1 10G!g' \
           "/usr/local/etc/php/php.ini" \
       \
    && git clone https://github.com/WWBN/AVideo-Encoder.git \
    && mv AVideo-Encoder/* . \
    && mv AVideo-Encoder/.[!.]* . \
    && rm -rf AVideo-Encoder \
    && chmod a+rx /usr/local/bin/entrypoint.sh \
    && chmod a+rx /usr/local/bin/gencerts.sh \
    && chown -R www-data:www-data /var/www/html

VOLUME ["/var/www/html"]
EXPOSE 80 443
CMD ["entrypoint.sh"]
