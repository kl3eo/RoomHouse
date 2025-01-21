CREATE TABLE if not exists rooms (id serial, name text, status int2 default 0, valid_till timestamp, dtm timestamp, movie_name text, movie_player text, house text, num_rooms int2 default 1);
ALTER TABLE rooms ADD CONSTRAINT name_unq UNIQUE(name);
insert into rooms (name) values ('corfu');

CREATE TABLE if not exists joins (id serial, ipaddr text, country text, city text, name text, room text, mode text, role text, dtm timestamp, accid text, eligible int2 default 0, house text, currroom char default null);
CREATE TABLE if not exists sessions (session text, date_and_time timestamp, ip text, acc_id text, bnum numeric, last_acc_id text, payload numeric default null);

CREATE TABLE if not exists wtagonliners (
    name text,
    p_vremya_z timestamp without time zone,
    room text
);

CREATE TABLE if not exists wtagshoutbox (
    messageid integer DEFAULT nextval(('mes_seq'::text)::regclass) NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    message text NOT NULL,
    ip integer NOT NULL,
    date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    room text
);

CREATE SEQUENCE mes_seq;

ALTER TABLE ONLY wtagshoutbox ADD CONSTRAINT wtagshoutbox_pkey PRIMARY KEY (messageid);

ALTER TABLE members ADD COLUMN room text;
ALTER TABLE members ADD COLUMN room_master bool default false;

ALTER TABLE wtagonliners ADD COLUMN room text;
ALTER TABLE wtagshoutbox ADD COLUMN room text;

CREATE TABLE if not exists blocked (ip text, dte timestamp);

ALTER TABLE rooms add column dtm timestamp;
ALTER TABLE rooms add column movie_name text;
ALTER TABLE rooms add column movie_player text;
alter table rooms add column house text;
alter table rooms add column num_rooms int2 default 1;

alter table joins add column eligible int2 default 0;
alter table joins add column house text;
alter table joins add column currroom char default null;

alter table sessions add column payload numeric default null;



