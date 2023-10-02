# Check Global variable, if variable is not exist, then exit this script for error
[ -z ${ADDRESS} ] && exit 1
[ -z ${VM_ID} ] && exit 1
[ -z ${SHLLL_LIST} ] && exit 1
[ -z ${TIMESTAMP} ] && exit 1
[ -z ${DEVICE_NAME} ] && exit 1
# Declare variable
SERVER=jenkins@${ADDRESS}
MACHINE_NAME=vm-${VM_ID}

# Geneter command
[ -e import-data.sh ] && rm import-data.sh
touch import-data.sh
echo 'curl -s http://172.22.0.172:5555/ops/sftp > ~/sftp.sh' >> import-data.sh
echo 'sleep 60' >> import-data.sh

echo "if [ \$(sudo bash ~/sftp.sh ls backup-data | grep ${SHLLL_LIST}.sh | wc -l) -eq 1 ]; then" >> import-data.sh
echo "source ~/sftp.sh d backup-data/${SHLLL_LIST}.sh" >> import-data.sh
echo "sed -i 's/\r$//' ${SHLLL_LIST}.sh" >> import-data.sh
echo "source ${SHLLL_LIST}.sh ${VM_ID} ${TIMESTAMP} ${DEVICE_NAME}">> import-data.sh
echo "else" >> import-data.sh
echo "echo ${SHLLL_LIST}.sh not find" >> import-data.sh
echo "exit 0" >> import-data.sh
echo "fi" >> import-data.sh

# Copy to target server
scp import-data.sh ${SERVER}:~/vm/${MACHINE_NAME}/share

# Copy to vm and execute
CMD="cd ~/vm/${MACHINE_NAME}"
CMD="${CMD} && vagrant ssh -c 'sudo bash ~/share/import-data.sh'"
ssh ${SERVER} ${CMD}
