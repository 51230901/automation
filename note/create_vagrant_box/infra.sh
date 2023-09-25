#
# Copyright 2020 the original author jacky.eastmoon
#
# All commad module need 3 method :
# [command]        : Command script
# [command]-args   : Command script options setting function
# [command]-help   : Command description
# Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
# But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
#
# Ref : https://www.cyberciti.biz/faq/category/bash-shell/
# Ref : https://tldp.org/LDP/abs/html/string-manipulation.html
# Ref : https://blog.longwin.com.tw/2017/04/bash-shell-script-get-self-file-name-2017/

# ------------------- shell setting -------------------

#!/bin/bash
set -e

# ------------------- declare CLI file variable -------------------

CLI_DIRECTORY=${PWD}
CLI_FILE=${BASH_SOURCE}
CLI_FILENAME=${BASH_SOURCE%.*}
CLI_FILEEXTENSION=${BASH_SOURCE##*.}

# ------------------- declare CLI variable -------------------

BREADCRUMB="cli"
COMMAND=""
COMMAND_BC_AGRS=()
COMMAND_AC_AGRS=()

# ------------------- declare variable -------------------

PROJECT_NAME=${PWD##*/}
PROJECT_ENV="dev"

# ------------------- declare function -------------------

# Command Parser
function main() {
    argv-parser ${@}
    for arg in ${COMMAND_BC_AGRS[@]}
    do
        IFS='=' read -ra ADDR <<< "${arg}"
        key=${ADDR[0]}
        value=${ADDR[1]}
        eval ${BREADCRUMB}-args ${key} ${value}
        common-args ${key} ${value}
    done
    # Execute command
    if [ ! -z ${COMMAND} ];
    then
        BREADCRUMB=${BREADCRUMB}-${COMMAND}
        if [ "$(type -t ${BREADCRUMB})" == "function" ];
        then
            main ${COMMAND_AC_AGRS[@]}
        else
            cli-help
        fi
    else
        eval ${BREADCRUMB}
    fi
}

function common-args() {
    key=${1}
    value=${2}
    case ${key} in
        "--help")
            BREADCRUMB="${BREADCRUMB}-help"
            ;;
        "-h")
            BREADCRUMB="${BREADCRUMB}-help"
            ;;
    esac
}

function argv-parser() {
    COMMAND=""
    COMMAND_BC_AGRS=()
    COMMAND_AC_AGRS=()
    is_find_cmd=0
    for arg in ${@}
    do
        if [ ${is_find_cmd} -eq 0 ]
        then
            if [[ ${arg} =~ -+[a-zA-Z1-9]* ]]
            then
                COMMAND_BC_AGRS+=(${arg})
            else
                COMMAND=${arg}
                is_find_cmd=1
            fi
        else
            COMMAND_AC_AGRS+=(${arg})
        fi
    done
}


# ------------------- Main method -------------------

function cli() {
    cli-help
}

function cli-args() {
    key=${1}
    value=${2}
    case ${key} in
        "--prod")
            PROJECT_ENV="prod"
            ;;
    esac
}

function cli-help() {
    echo "This is a docker control script with project ${PROJECT_NAME}"
    echo "If not input any command, at default will show HELP"
    echo "Options:"
    echo "    --help, -h        Show more information with CLI."
    echo ""
    echo "Command:"
    echo "    online            Execute online script on Vagrant."
    echo "    offline           Execute offline script on Docker and Vagrant."
    echo "    docker            Execute docker with target tgz package."
    echo ""
    echo "Run 'cli [COMMAND] --help' for more information on a command."
}

# ------------------- Common Command method -------------------

function common-online-vm-startup {
    [ ! -d cache/vm/online ] && mkdir -p cache/vm/online
    cp conf/vagrant/Vagrantfile cache/vm/online/Vagrantfile
    cd cache/vm/online
    sed -i 's/{VM_NAME}/virtual-environment-iwac-infra-online-s235/' Vagrantfile
    # sed -i 's/{VM_NAME}/virtual-environment-iwa-infra-online-s235/' Vagrantfile
    sed -i 's/{SHARED_DIR}/..\/..\/..\/shell\/online/' Vagrantfile
    if [ ! -z ${ONLINE_VAGRANT_DESTROY} ];
    then
        vagrant destroy -f
    fi
    vagrant up
}

function common-offline-vm-startup {
    [ ! -d cache/vm/offline ] && mkdir -p cache/vm/offline
    cp conf/vagrant/Vagrantfile cache/vm/offline/Vagrantfile
    cd cache/vm/offline
    sed -i 's/{VM_NAME}/virtual-environment-iwac-infra-offline/' Vagrantfile
    sed -i 's/{SHARED_DIR}/..\/..\/wrapper/' Vagrantfile
    if [ ! -z ${ONLINE_VAGRANT_DESTROY} ];
    then
        vagrant destroy -f
    fi
    vagrant up
}

# ------------------- Command "online" method -------------------
function cli-online {
    cli-online-help
}

function cli-online-args {
    key=${1}
    value=${2}
    case ${key} in
        "--reboot")
            ONLINE_VAGRANT_DESTROY="true"
            ;;
    esac
}

function cli-online-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Execute online script on Vagrant."
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
    echo "    --reboot          Vagrant will destroy vm first."
    echo ""
    echo "Command:"
    echo "    dev               Development with Vagrant."
    echo "    pack              Execute install.sh and Package VM with Vagrant box."
}

# ------------------- Command "online"-"dev" method -------------------
function cli-online-dev {
    common-online-vm-startup
    vagrant ssh
}

function cli-online-dev-args {
    return 0
}

function cli-online-dev-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Development with Vagrant."
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}

# ------------------- Command "online"-"pack" method -------------------
function cli-online-pack {
    common-online-vm-startup
    # iwac:
    vagrant ssh -c "cd ~/shared && source install.sh"
    # iwa:
    # vagrant ssh -c "cd ~/shared/ws && source install.sh"
    # vagrant ssh -c "cd ~/shared/iot && source install.sh"
    if [ -e virtual-environment-iwac-infra-online-s235.box ];
    # if [ -e virtual-environment-iwa-infra-online-s235.box ];
    then
        rm virtual-environment-iwac-infra-online-s235.box
        # rm virtual-environment-iwa-infra-online-s235.box
    fi
    vagrant package --base virtual-environment-iwac-infra-online-s235 --output virtual-environment-iwac-infra-online-s235.box
    # vagrant package --base virtual-environment-iwa-infra-online-s235 --output virtual-environment-iwa-infra-online-s235.box
    vagrant halt -f
}

function cli-online-pack-args {
    return 0
}

function cli-online-pack-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Execute install.sh and Package VM with Vagrant box."
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}

# ------------------- Command "offline" method -------------------
function cli-offline {
    cli-offline-help
}

function cli-offline-args {
    key=${1}
    value=${2}
    case ${key} in
        "--reboot")
            ONLINE_VAGRANT_DESTROY="true"
            ;;
    esac
}

function cli-offline-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Execute online script on Vagrant."
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
    echo "    --reboot          Vagrant will destroy vm first."
    echo ""
    echo "Command:"
    echo "    dev               Development with Docker."
    echo "    download          Execute download.sh in doecker."
    echo "    wrapper           Wrapper install shell and download cache."
    echo "    pack              Execute install.sh and Package VM with Vagrant box."
}

# ------------------- Command "offline"-"dev" method -------------------
function cli-offline-dev {
    [ ! -d cache/archives ] && mkdir -p cache/archives
    docker run -ti --rm -v ${CLI_DIRECTORY}/shell/offline:/shell -v ${CLI_DIRECTORY}/cache/archives:/shell/archives -w "/shell" ubuntu:18.04 bash
}

function cli-offline-dev-args {
    return 0
}

function cli-offline-dev-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Development with Docker."
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}

# ------------------- Command "offline"-"download" method -------------------
function cli-offline-download {
    [ ! -d cache/archives ] && mkdir -p cache/archives
    docker run --rm -v ${CLI_DIRECTORY}/shell/offline:/shell -v ${CLI_DIRECTORY}/cache/archives:/shell/archives -w "/shell" ubuntu:18.04 bash -l -c "bash download.sh"
    docker run --rm -v ${CLI_DIRECTORY}/shell/offline:/shell -v ${CLI_DIRECTORY}/cache/archives:/shell/archives -w "/shell" node:12 bash -l -c "bash download-nodejs-pack.sh"
    if [ -e ${CLI_DIRECTORY}/shell/offline/download-docker-images.sh ];
    then
        source ${CLI_DIRECTORY}/shell/offline/download-docker-images.sh ${CLI_DIRECTORY}/cache/archives/docker
    fi
}

function cli-offline-download-args {
    return 0
}

function cli-offline-download-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Execute download.sh in doecker"
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}

# ------------------- Command "offline"-"wrapper" method -------------------
function cli-offline-wrapper {
    [ ! -d cache/archives ] && mkdir -p cache/archives
    [ ! -d cache/wrapper ] && mkdir -p cache/wrapper
    docker run --rm -v ${CLI_DIRECTORY}/shell/offline:/shell -v ${CLI_DIRECTORY}/cache/archives:/shell/archives -v ${CLI_DIRECTORY}/cache/wrapper:/wrapper -w "/shell" bash -l -c "tar --exclude='download*.sh' -cvf /wrapper/installer.tar ."
}

function cli-offline-wrapper-args {
    return 0
}

function cli-offline-wrapper-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Wrapper install shell and download cache"
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}

# ------------------- Command "offline"-"pack" method -------------------
function cli-offline-pack {
    common-offline-vm-startup
    vagrant ssh -c "mkdir ~/installer && cd ~/shared && tar -xvf installer.tar -C ~/installer && cd ~/installer && sudo bash install.sh && cd .. && sudo rm -rf ~/installer"
    if [ -e virtual-environment-iwac-infra-offline.box ];
    then
        rm virtual-environment-iwac-infra-offline.box
    fi
    vagrant package --base virtual-environment-iwac-infra-offline --output virtual-environment-iwac-infra-offline.box
    vagrant halt -f
}

function cli-offline-pack-args {
    return 0
}

function cli-offline-pack-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Execute install.sh and Package VM with Vagrant box."
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}

# ------------------- Command "docker" method -------------------
function cli-docker {
    cli-docker-help
}

function cli-docker-args {
    return 0
}

function cli-docker-help {
    echo "This is a Command Line Interface with project ${PROJECT_NAME}"
    echo "Execute docker with target tgz package."
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with UP Command."
}

# ------------------- execute script -------------------

main ${@}
