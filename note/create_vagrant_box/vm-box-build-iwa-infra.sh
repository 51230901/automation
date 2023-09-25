cd ~
[ -d ~/git ] && echo 'Sun Sep 10 05:01:00 UTC 2023 git folder exist' || mkdir ~/git
[ -d ~/git/iwa-infra ] && echo 'Sun Sep 10 05:01:00 UTC 2023 iwa-infra is exist' || git clone http://work-token-2nd:E8Yevk9Miq262wQhcH4_@172.22.0.171/RD/infra/iwa-infra ~/git/iwa-infra-s235
# cd ~/git/iwa-infra
cd ~/git/iwa-infra-s235
git reset --hard && git fetch && git pull
# bash infra.sh online --reboot pack
# bash <(curl -s http://172.22.0.172:5555/ops/sftp) u ~/git/iwa-infra/cache/vm/online/*.box ./box/linux
# bash <(curl -s http://172.22.0.172:5555/ops/sftp) u ~/git/iwa-infra-s235/cache/vm/online/*.box ./box/linux
