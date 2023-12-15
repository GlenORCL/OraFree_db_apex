#!/bin/bash

set -Eeuo pipefail # fail script if any commands fail (-e), any variables are unset when used (-u), any within pipeline comamnd fails (-o pipefail) and also call error trap as part of fail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd ${SCRIPT_DIR}

source bash_lib/common_init
source bash_lib/fn_docker_cmds

docker_stop_env
