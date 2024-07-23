#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)

cp /code/current_dump_db.sql.gz /code/restore_dump_db.sql.gz
printf "\n${YELLOW}${bold}Drop DB.\n\n${NC}"
drush sql:drop -y
docker exec -ti lms-core_devcontainer-redis-1 redis-cli flushall

printf "\n${GREEN}${bold}Import DB.\n\n${NC}"
drush sqlq --file=/code/restore_dump_db.sql.gz --file-delete
