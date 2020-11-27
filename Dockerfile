FROM php:7-apache

ENV DOMAIN your.domain
ENV DOMAIN_PROTOCOL http
ENV ADMIN_PASSWORD password
ENV DB_HOST localhost
ENV DB_USER root
ENV DB_PASSWORD password

ADD install.php /root/
ADD entrypoint.sh /usr/local/bin/
WORKDIR /var/www/html

RUN apt-get update \
    && apt-get install -y wget git zip default-libmysqlclient-dev libbz2-dev libmemcached-dev libsasl2-dev libfreetype6-dev libicu-dev libjpeg-dev libmemcachedutil2 libpng-dev libxml2-dev mariadb-client ffmpeg libimage-exiftool-perl python curl python-pip libzip-dev libonig-dev \
    && docker-php-ext-configure gd --with-freetype=/usr/include --with-jpeg=/usr/include \
    && docker-php-ext-install -j$(nproc) bcmath bz2 calendar exif gd gettext iconv intl mbstring mysqli opcache pdo_mysql zip \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /root/.cache \
    && a2enmod rewrite \
    && pip install -U youtube-dl \
    && echo "post_max_size = 10G\nupload_max_filesize = 10G" > $PHP_INI_DIR/conf.d/upload.ini \
    && echo "memory_limit = -1" > $PHP_INI_DIR/conf.d/memory.ini \
    && echo "max_execution_time = 72000" > $PHP_INI_DIR/conf.d/execution_time.ini \
    && git clone https://github.com/WWBN/AVideo-Encoder.git \
    && mv AVideo-Encoder/* . \
    && mv AVideo-Encoder/.[!.]* . \
    && rm -rf AVideo-Encoder \
    && chmod a+rx /usr/local/bin/entrypoint.sh \
    && chmod a+rx /usr/local/bin/gencerts.sh \
    && chown -R www-data:www-data /var/www/html

VOLUME ["/var/www/html/videos"]
CMD ["entrypoint.sh"]
