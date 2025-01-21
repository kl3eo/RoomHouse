#!/bin/bash

if [ -f /tmp/a.out ]; then
	/usr/local/pgsql/bin/psql -Upostgres ipaudit < /tmp/a.out && rm -f /tmp/a.out
fi

#/usr/local/pgsql/bin/psql -U postgres -tc "delete from apos where status is null and current_timestamp-apos.date_and_time > '12 hour'" people
/usr/local/pgsql/bin/psql -U postgres -tc "delete from ipaudit where current_timestamp - constart > '10 min'" ipaudit
