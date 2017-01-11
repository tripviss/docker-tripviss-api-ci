FROM php:7.1-alpine

# persistent / runtime deps
RUN apk add --no-cache --virtual .persistent-deps \
		ca-certificates \
		curl \
		git \
		gmp \
		icu \
		zlib

ENV APCU_VERSION 5.1.7

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		gmp-dev \
		icu-dev \
		zlib-dev \
	&& docker-php-ext-install \
		bcmath \
		gmp \
		intl \
		mbstring \
		zip \
	&& pecl install \
		apcu-$APCU_VERSION \
		ds \
	&& docker-php-ext-enable --ini-name 05-opcache.ini \
		opcache \
	&& docker-php-ext-enable --ini-name 20-apcu.ini \
		apcu \
	&& docker-php-ext-enable \
		ds \
	&& apk del .build-deps

RUN curl -fSL https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer

ENV COMPOSER_HOME /root/.composer
ENV PATH $PATH:$COMPOSER_HOME/vendor/bin

COPY composer.json /root/.composer
COPY php.ini /usr/local/etc/php/

RUN composer global update --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative \
	&& composer clear-cache
