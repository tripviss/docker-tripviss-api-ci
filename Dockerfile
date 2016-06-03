FROM php:7.0-alpine

# persistent / runtime deps
RUN apk add --no-cache --virtual .persistent-deps \
        ca-certificates \
        curl \
        git \
        icu \
        zlib

ENV APCU_VERSION 5.1.4

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        icu-dev \
        zlib-dev \
    && docker-php-ext-install \
        intl \
        mbstring \
        zip \
    && pecl install \
        apcu-$APCU_VERSION \
    && docker-php-ext-enable --ini-name 05-opcache.ini \
        opcache \
    && docker-php-ext-enable --ini-name 20-apcu.ini \
        apcu \
    && apk del .build-deps

RUN curl -fSL https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

ENV COMPOSER_HOME /root/.composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin

RUN composer global require hirak/prestissimo

RUN curl -fSL https://phar.phpunit.de/phpunit.phar -o /usr/local/bin/phpunit \
    && chmod +x /usr/local/bin/phpunit

COPY php.ini /usr/local/etc/php/
