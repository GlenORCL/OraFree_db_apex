#!/bin/bash

set -Eeuo pipefail # fail script if any commands fail (-e), any variables are unset when used (-u), any within pipeline comamnd fails (-o pipefail) and also call error trap as part of fail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd ${SCRIPT_DIR}

HELP=$'ORCLENV.sh <commands>
             start [env] - starts the oracle environment
             stop [env] - stops the oracle environment
             destroy_and_setup [env] - destroys and sets up the oracle environment
             default ENV - changes/sets the default environment to ENV (normally this is DEV)
             '

if [ "$#" == "0" ]
then
    echo "${HELP}"
    exit 1
fi

case $1 in
   start) 
        shift
        echo "Starting oracle environment"
        source bash_lib/common_init
        source bash_lib/fn_docker_cmds
        docker_start_env
        ;;
   stop)
        shift
        echo "Stopping oracle environment"
        source bash_lib/common_init
        source bash_lib/fn_docker_cmds
        docker_stop_env
        ;;
   destroy_and_setup) 
        shift
        echo "Destroying and setting up oracle environment"
        source bash_lib/common_init
        if [ ! $(ls -1 ${ENVDIR} | grep -v "\.log$" | wc -l) == 0 ] # if other than zero non-log files, then ENV exists
        then
            echo "Are you SURE that you want to destroy and setup environment ${ENV} (pick 1 or 2)?"
            select yn in "Yes" "No"; do
                case $yn in
                    Yes) break;;
                    No) error_exit "User cancelled";;
                esac
            done
        fi
        source bash_lib/fn_docker_cmds
        source bash_lib/fn_install_cmds
        docker_destroy_and_setup
        ;;
   default)
        shift
        if [ "$#" == "0"]
        then
            echo "You MUST specify a default environment"
            exit 1
        fi
        NEW_ENV=$1
        if [ -f "config_${NEW_ENV}.env" ]
        then
            echo "Setting environment default to ${NEW_ENV}"
            echo "${NEW_ENV}" >! config.default
        else
            echo "config_${NEW_ENV}.env does not exist - not changing default"
            exit 1
        fi
        ;;
   *)
        echo "${HELP}"
        ;;
esac

