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

for SHELLNAME in ${SHLLL_LIST};
do
    echo "data_pair=\$(sudo bash ~/sftp.sh ls import-data/${DEVICE_NAME} | grep ${DEVICE_NAME}_vm-${VM_ID} | grep ${TIMESTAMP} | wc -l)" >> import-data.sh
    echo "if [ \${data_pair} -gt 0 ]; then" >> import-data.sh
    echo "exit 0" >> import-data.sh 
    echo "else" >> import-data.sh
    echo "exit 1" >> import-data.sh
    echo "fi" >> import-data.sh
    echo "if [ \$(sudo bash ~/sftp.sh ls import-data/${DEVICE_NAME} | grep ${SHELLNAME}.sh | wc -l) -eq 1 ]; then" >> import-data.sh
    echo "source ~/sftp.sh d import-data/${DEVICE_NAME}/${SHELLNAME}.sh" >> import-data.sh
    echo "sed -i 's/\r$//' ${SHELLNAME}.sh" >> import-data.sh
    echo "source ${SHELLNAME}.sh ${VM_ID} ${TIMESTAMP} ${DEVICE_NAME}" >> import-data.sh
    echo "else" >> import-data.sh
    echo "echo ${SHELLNAME}.sh not find" >> import-data.sh
    echo "exit 0" >> import-data.sh
    echo "fi" >> import-data.sh
done

# Copy to target server
scp import-data.sh ${SERVER}:~/vm/${MACHINE_NAME}/share

# Copy to vm and execute
CMD="cd ~/vm/${MACHINE_NAME}"
CMD="${CMD} && vagrant ssh -c 'sudo bash ~/share/import-data.sh'"
ssh ${SERVER} ${CMD}

# Update the database
CMD="cd ~/vm/${MACHINE_NAME}"
CMD="${CMD} && vagrant ssh -c 'cd ~/package && sudo bash run.sh update'"
ssh ${SERVER} ${CMD}