cd ~
[ -d ~/git ] && echo 'Tue Sep 20 06:42:28 UTC 2022 git folder exist' || mkdir ~/git
[ -d ~/git/iwac-infra ] && echo 'Tue Sep 20 06:42:28 UTC 2022 iwac-infra is exist' || git clone http://work-token-2nd:E8Yevk9Miq262wQhcH4_@172.22.0.171/RD/iwac-infra ~/git/iwac-infra-s235
# cd ~/git/iwac-infra
cd ~/git/iwac-infra-s235
git reset --hard && git fetch && git pull
# bash infra.sh online pack
# bash <(curl -s http://172.22.0.172:5555/ops/sftp) u ~/git/iwac-infra/cache/vm/online/*.box ./box/linux
# bash <(curl -s http://172.22.0.172:5555/ops/sftp) u ~/git/iwac-infra-s235/cache/vm/online/*.box ./box/linux
