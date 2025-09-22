
-- first compare total rides in each table
select extract(year from date) as year, count(id) from rides_14 group by year
union
select extract (year from date) as year, count(id) from rides_15 group by year



-- =====================================
-- 2.1 - 2014 time series analysis =====
-- =====================================

-- monthly rides 2014
select
    to_char (date, 'Month') as month,
    count(id) as rides_2014,
    round (
        (count(id) - lag(count(id)) over (order by extract(month from date)))
        *100.0 / lag(count(id)) over (order by extract (month from date)),2) as pct_growth
from rides_14
group by month, extract(month from date)
order by extract(month from date);

-- rides by day of week
select to_char(date, 'day') as day,
    count(id) as rides,
    round(count(id)*100 / sum(count(id)) over(), 1) as pct_of_total
from rides_14
group by day, extract(dow from date) 
order by extract(dow from date);

-- all rides grouped by hour [use for viz]
select
    to_char (date, 'dy') as day,
    extract (hour from date) as hour,
    count (*) as rides
from rides_14
group by hour, day
order by min(extract (dow from date)), hour;



-- WEEKEND VS WEEKDAYS


-- rides/hour on weekends
select
    to_char (date, 'dy') as dow,
    extract (hour from date) as hour,
    count (*) as rides
from rides_14
where extract(dow from date) in (0,6) -- counts sat/sun rides
    OR extract(dow from date) = 5 AND extract (hour from date) > 17 -- counts rides on friday past 5p
group by hour, dow
order by dow asc, hour;

-- weekend vs weekday trends (select tot rides, % of total, avg rides/day)
SELECT
    day_type,
    total_rides,
    pct_of_total,
    case
        when day_type = 'weekday' then total_rides/5
        when day_type = 'weekend' then total_rides/2
    end as avg_daily_rides
from(
    select
        case
            when extract (dow from date) in (0,6) then 'weekend'
            else 'weekday'
        end as day_type,
        count(id) as total_rides,
        round(count(id)*100/sum(count(id)) over(), 1) as pct_of_total
    from rides_14
    group by day_type
) subquery;


-- BEHAVIORAL PATTERNS


-- which night do more people go out, friday or saturday?
select 
    extract(hour from date) as hour, 
    sum(case when to_char(date, 'dy') = 'sat' then 1 else 0 end) as fri, -- coming home from fri night
    sum(case when to_char(date, 'dy') = 'sun' then 1 else 0 end) as sat -- coming home from sat night
from rides_14
where extract(hour from date) between 0 and 4
    and extract(dow from date) in (0,6)
group by hour
union all
select -- finding subtotal
    null as hour, 
    sum(case when to_char(date, 'dy') = 'sat' then 1 else 0 end) as fri,
    sum(case when to_char(date, 'dy') = 'sun' then 1 else 0 end) as sat
from rides_14
where extract(hour from date) between 0 and 4
    and extract(dow from date) in (0,6);


-- rush hour demand by day- when are people working from home






-- =====================================
-- 2.2 - 2015 zone analysis ============
-- =====================================

-- How many boroughs
select distinct(borough) from zones;

-- Total zones per borough?
select borough, count(zone) as count from zones
group by borough
order by count desc;

-- Unknown boroughs
select * from zones where borough = 'Unknown'

-- How many rides start in 'Unknown'?
select z.borough, r.location_id, count(r.id)
from zones as z
join rides_15 as r using(location_id)
where z.borough = 'Unknown'
group by z.borough, r.location_id;
    -- very negligible amount relative to total rides (~0.04%)


-- which borough has the most ride requests
select z.borough, count(r.id) as rides
from zones as z
join rides_15 as r using(location_id)
group by z.borough
order by rides desc;

-- top 10 zones for origination
select z.borough, z.zone, count(r.id) as rides
from zones as z
join rides_15 as r using(location_id)
group by z.zone, z.borough
order by rides desc
limit 10;

-- most popular zone per borough
select z.borough, z.zone, count(r.id) as rides
from zones as z
join rides_15 as r using(location_id)


-- dif in popular zones by time of day?

-- classify zones as high/med/low traffic --> show count of each
    -- maybe use stat analysis to 


-- Comparing monthly demand by airport
select
    to_char(r.date, 'mon') as month,
    sum(case when z.zone = 'JFK Airport' then 1 else 0 end) as jfk,
    sum(case when z.zone = 'LaGuardia Airport' then 1 else 0 end) as lga,
    sum(case when z.zone = 'Newark Airport' then 1 else 0 end) as ewr
from rides_15 as r
join zones as z using(location_id)
where z.zone in ('Newark Airport', 'JFK Airport', 'LaGuardia Airport')
group by extract(month from r.date), to_char(r.date, 'mon')
order by extract(month from r.date);
    -- look into peak days at airports vs other places




-- =====================================
-- 2.3 - 2014/2015 Q2 growth analysis ==
-- =====================================

-- weekly ride patterns
-- group by day - maybe can do 