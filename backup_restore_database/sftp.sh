#!/bin/bash
set -e

# ------------------- declare variable -------------------
ROOT_DIR=${PWD}
CLI_COMMAND=${1}
SOURCE_DIR=${2}
REMOTE_DIR=${3}
SFTP_SERVER=ist-upload@172.22.0.172
SFTP_PASSWORD='1234qwer!@#$'

# ------------------- declare function -------------------

# ------------------- execute script -------------------

# Install requirements package
sshpass -h &> .check.tmp
if [[ $(cat .check.tmp) =~ .*"command not found" ]];
then
    rm .check.tmp
    echo "sshpass command is not found, install first."
else
    rm .check.tmp
    # Mark sure running package version vagrant and script
    if [[ ${CLI_COMMAND} == "d" ]];
    then
    sshpass -p ${SFTP_PASSWORD} sftp  -oStrictHostKeyChecking=no ${SFTP_SERVER} << EOF
get -r ${SOURCE_DIR} ${REMOTE_DIR}
EOF
    fi

    if [[ ${CLI_COMMAND} == "u" ]];
    then
    sshpass -p ${SFTP_PASSWORD} sftp  -oStrictHostKeyChecking=no ${SFTP_SERVER} << EOF
put ${SOURCE_DIR} ${REMOTE_DIR}
EOF
    fi

    if [[ ${CLI_COMMAND} == "ls" ]];
    then
        if [ -z ${SOURCE_DIR} ];
        then
            echo ls -al | sshpass -p ${SFTP_PASSWORD} sftp -oStrictHostKeyChecking=no ${SFTP_SERVER}
        else
            echo ls ${SOURCE_DIR} -al | sshpass -p ${SFTP_PASSWORD} sftp -oStrictHostKeyChecking=no ${SFTP_SERVER}
        fi
    fi

    if [[ ${CLI_COMMAND} == "rm" ]];
    then
    echo "rm ${SOURCE_DIR}" | sshpass -p ${SFTP_PASSWORD} sftp  -oStrictHostKeyChecking=no ${SFTP_SERVER}
    fi

    if [[ ${CLI_COMMAND} == "rmdir" ]];
    then
    echo "rmdir ${SOURCE_DIR}" | sshpass -p ${SFTP_PASSWORD} sftp  -oStrictHostKeyChecking=no ${SFTP_SERVER}
    fi

    if [[ ${CLI_COMMAND} == "mkdir" ]];
    then
    echo "mkdir ${SOURCE_DIR}" | sshpass -p ${SFTP_PASSWORD} sftp  -oStrictHostKeyChecking=no ${SFTP_SERVER}
    fi
fi
