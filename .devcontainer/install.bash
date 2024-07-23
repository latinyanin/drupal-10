#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)

source /code/.devcontainer/.env

# Install node
if [ ! -z "$NODE_VERSION" ]; then
  printf "\n${YELLOW}Install node ${NODE_VERSION} version\n\n${NC}"
  bash -i -c "nvm install ${NODE_VERSION}"
fi

# get confirmation
printf "\n${YELLOW}Install an existing site configuration?\nThis will drop database and rebuild site.\n\n${NC}"
read -t 30 -N 1 -p "Continue (Y/n): " is_need_install
echo

# if answer is yes within 15 seconds start site install ...
if [ "${is_need_install,,}" == "n" ]; then
  printf "\n${GREEN}${bold}Cancel site rebuild.\n${NC}${normal}"
  exit 0
fi

# Delete all the keys of all the existing databases
docker exec -ti drupal-10_devcontainer-redis-1 redis-cli flushall

# Copy settings.php to site
sudo chmod 0755 -R web/sites/default
sudo rm -rf web/sites/default/files
cp -f .devcontainer/develop.settings.php web/sites/default/settings.php
cp -f .devcontainer/develop.services.yml web/sites/default/services.yml

# Set twig debug
if [ "${ENABLE_TWIG_DEBUG}" == 'true' ]; then
  printf "\n${GREEN}${bold}Enabled twig debug\n${NC}"
  sed -i '/^[ ]*twig.config:/,/^[ ]*renderer.config:/ { /debug:/ s/[^ ][^ ]*$/true/ }' /code/web/sites/default/services.yml
  sed -i '/^[ ]*twig.config:/,/^[ ]*renderer.config:/ { /cache:/ s/[^ ][^ ]*$/false/ }' /code/web/sites/default/services.yml
fi

# Set cache debug
if [ "${ENABLE_CACHE_DEBUG}" == 'true' ]; then
  printf "\n${GREEN}${bold}Enabled cache debug\n\n${NC}"
  sed -i '/^[ ]*renderer.config:/,/^[ ]*http.response.debug_cacheability_headers:/ { /debug:/ s/[^ ][^ ]*$/true/ }' /code/web/sites/default/services.yml
fi
mkdir -p .vscode | printf "\n${NC}${bold}.vscode exist...\n${NC}${normal}"
cp -f .devcontainer/launch.json .vscode/launch.json

printf "\n${GREEN}${bold}Run drush site:install...\n\n${NC}"
# Install new minimal drupal profile.
# drush si minimal --site-name=DEV --account-name=root --account-pass=lms-core --account-mail=hello@admin.jet.dev --db-url=mysql://$MYSQL_USER:$MYSQL_PASSWORD@db:3306/$MYSQL_DATABASE -y || { printf "\n${RED}${bold}ERROR Site install ...\n\n${NC}"; exit 1; };
# Install drupal existing config.
drush si --existing-config --site-name=DEV --account-name=admin --account-pass=admin --account-mail=hello@jet.dev -y || { printf "\n${RED}${bold}ERROR Site install ...\n\n${NC}"; exit 1; };

drush cr
