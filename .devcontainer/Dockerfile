# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.195.0/containers/php/.devcontainer/base.Dockerfile
# [Choice] PHP version (use -bullseye variants on local arm64/Apple Silicon): 8, 8.0, 7, 7.4, 7.3, 8-bullseye, 8.0-bullseye, 7-bullseye, 7.4-bullseye, 7.3-bullseye, 8-buster, 8.0-buster, 7-buster, 7.4-buster, 7.3-buster
ARG VARIANT=8-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/php:0-${VARIANT}

# Stop the xdebug message spam
RUN echo "xdebug.log=/dev/null" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y \
    apt-utils \
    bash-completion \
    default-mysql-client \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libmagickwand-dev \
    libpq-dev \
    libwebp-dev \
    libzip-dev \
    zlib1g-dev \
    libicu-dev \
    build-essential \
    curl \
    zip \
    unzip \
    libxml2-dev \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Update pecl
RUN pecl channel-update pecl.php.net

# Install pecl modules
RUN pecl install \
  imagick \
  apcu && \
  docker-php-ext-enable imagick apcu && \
  echo "apc.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

RUN docker-php-ext-configure gd \
  --with-freetype \
  --with-jpeg=/usr \
  --with-webp

RUN docker-php-ext-install -j "$(nproc)" gd mysqli pdo pdo_mysql zip

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

RUN sudo curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar" && \
  sudo chmod +x /usr/local/bin/drush

# Enable apache modules
RUN a2enmod rewrite headers

RUN echo "memory_limit=512M" >> /usr/local/etc/php/conf.d/memory_limit.ini
RUN echo "post_max_size=50M" >> /usr/local/etc/php/conf.d/post_max_size.ini
RUN echo "upload_max_filesize=50M" >> /usr/local/etc/php/conf.d/upload_max_filesize.ini

COPY ./apache.conf /etc/apache2/sites-enabled/000-default.conf
RUN echo "export APACHE_RUN_USER=vscode" >> /etc/apache2/envvars;
RUN echo "export APACHE_RUN_GROUP=vscode" >> /etc/apache2/envvars;
