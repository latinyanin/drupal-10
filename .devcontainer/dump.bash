#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)

printf "\n${GREEN}${bold}Cleare cache.\n\n${NC}"
drush cr

printf "\n${GREEN}${bold}Dump DB.\n\n${NC}"
rm -f /code/current_dump_db.sql.gz
drush sql:dump --gzip --result-file=/code/current_dump_db.sql --extra-dump=--no-tablespaces
