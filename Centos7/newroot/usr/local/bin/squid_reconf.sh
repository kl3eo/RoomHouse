#/bin/bash
/bin/mv /tmp/squid.conf.experimental /etc/squid/squid.conf.strict.yota.experimental
/bin/rm -f /etc/squid/squid.conf
/bin/ln -s /etc/squid/squid.conf.strict.yota.experimental /etc/squid/squid.conf
/usr/sbin/squid -k reconfigure
