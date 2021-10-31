FROM php:8-fpm
# sfdemo-dockerized:base

ARG USER_ID
ARG USERNAME

ENV TZ=Europe/Bucharest

RUN apt-get update && apt-get upgrade -y \
  && apt-get install -y gcc libc-dev make libzip-dev wget curl unzip libicu-dev git sudo nodejs npm python \
  && npm install -g yarn \
  && docker-php-ext-install zip \
  && docker-php-ext-install intl \
  && pecl install xdebug && docker-php-ext-enable xdebug \
  && apt-get autoremove -y && apt-get clean -y

# add Composer and Symfony binaries
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY --from=symfonycorp/cli:latest /symfony /usr/bin/symfony
COPY ./docker/php-fpm/php.ini /usr/local/etc/php/php.ini

# create system user
RUN useradd --groups www-data \
  --system \
  --create-home \
  --home-dir /home/$USERNAME \
  --uid $USER_ID \
  $USERNAME

# promote user to sudoer with password "docker"
RUN usermod -aG sudo $USERNAME && echo "$USERNAME:docker" | chpasswd

RUN mkdir /var/www/demo \
  && chown $USERNAME:www-data /var/www/demo && chmod g+s /var/www/demo

RUN mkdir /home/$USERNAME/.symfony \
  && chown $USERNAME:$USERNAME /home/$USERNAME/.symfony \
  && chmod 755 /home/$USERNAME/.symfony \
  && /usr/bin/symfony self-update -y

WORKDIR /var/www/demo