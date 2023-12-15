#!/bin/bash

set -Eeuo pipefail # fail script if any commands fail (-e), any variables are unset when used (-u), any within pipeline comamnd fails (-o pipefail) and also call error trap as part of fail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd ${SCRIPT_DIR}

source bash_lib/common_init
source bash_lib/fn_docker_cmds
source bash_lib/fn_install_cmds

if [ ! $(ls -1 ${ENVDIR} | grep -v "\.log$" | wc -l) == 0 ] # if zero non-log files, then ENV exists
then
    echo "Are you SURE that you want to destroy and setup environment ${ENV} (pick 1 or 2)?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes) break;;
            No) error_exit "User cancelled";;
        esac
    done
fi

# INITIAL SETUP
setup_base_dirs
setup_ssl

# If any samples URL specified for this ENV, download it (if not already)
get_software "${SAMPLES_ZIP:-}" "${SAMPLES_ZIP_URL:-}"

# Grab images from Registry
docker pull ${ORDS_IMAGE}
docker pull ${DB_IMAGE}

# CLEANUP ANY EXISTING OLD ENVIRONMENT
remove_docker_containers

# setup vm_shares directory for this ENV
install_vm_shares

# NOW START DOCKER SETUP
docker_create_network

docker_initiate_db
docker_await_db_ready

# perform standard db init - set db directories, open acls etc.
#install_exec_sql_in_pdb @scripts/db_init.sql

docker_initiate_ords
docker_await_ords_ready

# OPTIONAL CUSTOMISATION
if [ -f "custom_${ENV}" ]
then
    source custom_${ENV}
fi

logit "Finished"
