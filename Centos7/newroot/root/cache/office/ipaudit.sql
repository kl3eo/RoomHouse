CREATE TABLE if not exists ipaudit (
     ip1 text DEFAULT '' NOT NULL,
     ip2 text DEFAULT '' NOT NULL,
     protocol int4 DEFAULT '0' NOT NULL,
     ip1port int4 DEFAULT '0' NOT NULL,
     ip2port int4 DEFAULT '0' NOT NULL,
     ip1bytes bigint DEFAULT '0' NOT NULL,
     ip2bytes bigint DEFAULT '0' NOT NULL,
     ip1pkts bigint DEFAULT '0' NOT NULL,
     ip2pkts bigint DEFAULT '0' NOT NULL,
     eth1 text DEFAULT '' NOT NULL,
     eth2 text DEFAULT '' NOT NULL,
     constart timestamp DEFAULT current_timestamp NOT NULL,
     constartmsec int4 DEFAULT '0' NOT NULL,
     constop timestamp DEFAULT current_timestamp NOT NULL,
     constopmsec int4 DEFAULT '0' NOT NULL,
     probename text DEFAULT '' NOT NULL
   );

