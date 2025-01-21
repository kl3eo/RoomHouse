/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data >logfile 2>&1 &
/usr/local/pgsql/bin/createdb test
/usr/local/pgsql/bin/psql test
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data stop
exit
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data start
psql -l
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data stop
exit
