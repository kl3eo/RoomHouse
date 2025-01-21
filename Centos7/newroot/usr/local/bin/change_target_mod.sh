#!/bin/bash
chmod 775 /home/nobody/vchat/target/classes/static/
rm -rf /home/nobody/vchat_video/target/classes/static/icon/reg && cd /home/nobody/vchat_video/target/classes/static/icon/ && ln -s /var/www/html/cp/public_html/icon/reg
