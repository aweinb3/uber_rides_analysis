
-- creating rides_14 table
CREATE TABLE rides_14(
    id int PRIMARY KEY,
    date timestamp,
    lat float,
    long float,
    base varchar
);

-- importing values from csv
copy rides_14
from '/Users/avi/Desktop/projects/Uber/2014/cleaned-apr14-sep14.csv'
delimiter ','
CSV HEADER;

-- make sure ids match
select count(*) as total_rows, count (distinct id) as unique
from rides_14;

-- creating rides_15 table
CREATE TABLE rides_15(
    dispatching_base_num varchar,
    date timestamp,
    affiliated_base_num varchar,
    locationid int
);

-- changing column locationid for easier joins
alter table rides_15 rename column locationid TO location_id
select * from rides_15 limit 1;

-- importing values from csv
copy rides_15
from '/Users/avi/Desktop/projects/Uber/2015/uber-raw-data-jan15-june15.csv'
delimiter ','
CSV HEADER;

-- adding id column
ALTER TABLE rides_15 add column id serial primary key;

select * from rides_15 limit 10;

-- creating zone table
CREATE TABLE zones(
    location_id int PRIMARY KEY,
    borough varchar,
    zone varchar
);

--importing values from csv
copy zones
from '/Users/avi/Desktop/projects/Uber/2015/taxi-zone-lookup.csv'
delimiter ','
CSV HEADER;

select * from zones;

-- indexing for quicker querying
create index on rides_14 (date)
create index on rides_15 (date)

-- summary of tables
select table_name, column_name, data_type 
from information_schema.columns
where table_name in ('rides_14', 'rides_15', 'zones')
order by table_name, column_name;