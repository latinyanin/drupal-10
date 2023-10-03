#!/bin/bash

RED='\033[0;31m';
YELLOW='\033[0;33m'
GREEN='\033[0;32m';
NC='\033[0m';
bold=$(tput bold)
normal=$(tput sgr0)

source /code/.devcontainer/.env;
# Vnstall Node
source /usr/local/share/nvm/nvm.sh;
if [ ! -z "$NODE_VERSION" ]
then
printf "\n${YELLOW}Install node lts.\n\n${NC}"
nvm install $NODE_VERSION
fi

# get confirmation
printf "\n${YELLOW}Install an existing site configuration?\nThis will drop database and rebuild site.\n\n${NC}"
read -t 30 -N 1 -p "Continue (Y/n): " answer
echo

# if answer is yes within 15 seconds start site install ...
if [ "${answer,,}" == "n" ]
then
    printf "\n${GREEN}${bold}Cancel site rebuild.\n${NC}${normal}"
    exit 0;
fi

# Copy settings.php to site
sudo chmod 0755 web/sites/default
sudo rm -rf web/sites/default/settings.php web/sites/default/settings.local.php web/sites/default/services.yml web/sites/default/files
cp .devcontainer/develop.settings.php web/sites/default/settings.php
cp .devcontainer/services.yml web/sites/default/services.yml
if [ "${ENABLE_TWIG_DEBUG}" == 'true' ]
then
    sed -i 's/ debug: false/ debug: true/' /code/web/sites/default/services.yml
    sed -i 's/ cache: true/ cache: false/' /code/web/sites/default/services.yml
fi
mkdir -p .vscode | printf "\n${NC}${bold}.vscode exist...\n${NC}${normal}"
cp -f .devcontainer/launch.json .vscode/launch.json

printf "\n${GREEN}${bold}Run drush site:install...\n\n${NC}"
# Install new minimal drupal profile.
# drush si minimal --site-name=Logbook --account-name=admin --account-pass=admin --account-mail=hello@admin.jet.dev --db-url=mysql://$MYSQL_USER:$MYSQL_PASSWORD@db:3306/$MYSQL_DATABASE -y || { printf "\n${RED}${bold}ERROR Site install ...\n\n${NC}"; exit 1; };

# Delete all the keys of all the existing databases
docker exec -ti drupal-9_devcontainer-redis-1 redis-cli flushall

# Install drupal existing config.
drush si --existing-config --site-name=DEV --account-name=root --account-pass=lgbk --account-mail=hello@jet.dev -y || { printf "\n${RED}${bold}ERROR Site install ...\n\n${NC}"; exit 1; }
drush cr

# Add root system_administrator role
# drush user-add-role "system_administrator" roo
