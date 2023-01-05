FROM php:8.1-fpm

ARG USERNAME
ARG USER_ID
ARG GROUP_ID
ARG WORKING_DIR

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
RUN curl -sS https://get.symfony.com/cli/installer | bash \
  && mv /root/.symfony5/bin/symfony /usr/bin/symfony

# add PHP config
COPY ./docker/php-fpm/php.ini /usr/local/etc/php/php.ini

# create system group
RUN groupadd -f \
    --system \
    --gid $GROUP_ID \
    $USERNAME

# create system user
RUN useradd --groups www-data \
  --system \
  --create-home \
  --home-dir /home/$USERNAME \
  --uid $USER_ID \
  --gid $GROUP_ID \
  $USERNAME

# !!! Don't do this in production !!! promote user to sudoer with password "docker"
RUN usermod -aG sudo $USERNAME && echo "$USERNAME:docker" | chpasswd

RUN mkdir $WORKING_DIR \
  && chown $USERNAME:www-data $WORKING_DIR && chmod g+s $WORKING_DIR

RUN mkdir /home/$USERNAME/.symfony \
  && chown $USERNAME:$USERNAME /home/$USERNAME/.symfony \
  && chmod 755 /home/$USERNAME/.symfony

WORKDIR $WORKING_DIR

USER $USERNAME

CMD ["symfony", "serve", "--port=8000", "--no-tls", "--no-interaction"]
