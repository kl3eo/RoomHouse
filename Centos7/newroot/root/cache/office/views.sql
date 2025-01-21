CREATE TABLE if not exists vmails (id serial, author text, a_topic text, z_destination text, store_url text, vremya_z timestamp, status bool default null);
CREATE TABLE if not exists views (z text, v text, t timestamp);
CREATE TABLE if not exists blocked (ip text, dte timestamp);
