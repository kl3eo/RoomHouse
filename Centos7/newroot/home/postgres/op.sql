postgres=# CREATE DATABASE cp ENCODING 'UTF8' lc_collate 'ru_RU.UTF8' lc_ctype 'ru_RU.UTF8' TEMPLATE template0;
CREATE DATABASE
postgres=# CREATE DATABASE op ENCODING 'UTF8' lc_collate 'ru_RU.UTF8' lc_ctype 'ru_RU.UTF8' TEMPLATE template0;
CREATE DATABASE
postgres=# create user op with password 'parol765';
CREATE ROLE
postgres=# grant all on database op to op;
GRANT

