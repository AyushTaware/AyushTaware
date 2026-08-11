create database zomato; 
use zomato;
CREATE TABLE IF NOT EXISTS zomato (
    url TEXT,
    address TEXT,
    name VARCHAR(255),
    online_order VARCHAR(10),
    book_table VARCHAR(10),
    rate VARCHAR(10),
    votes INT,
    phone VARCHAR(100),
    location VARCHAR(255),
    rest_type VARCHAR(255),
    dish_liked TEXT,
    cuisines TEXT,
    approx_cost VARCHAR(50),
    reviews_list LONGTEXT,
    menu_item LONGTEXT,
    listed_in_type VARCHAR(100),
    listed_in_city VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/zomato.csv'
INTO TABLE zomato
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SHOW VARIABLES LIKE 'secure_file_priv';

select* from zomato;

-- Basic SQL Questions

-- Q1 How many restaurants are present in the dataset?

select count(*) from zomato;

-- Q2 How many unique locations are there?

select count(distinct location) from zomato;

-- Q3 Find top 10 locations having maximum restaurants.

select location,count(name) as no_of_resturants from zomato
group by location
order by no_of_resturants desc
limit 10;

-- Q4 How many restaurants support Online Order?

select name from zomato
where online_order = 'yes';

-- Q5 How many restaurants support Table Booking?

select name from zomato
where book_table = 'yes';

-- Q6 Find restaurant types available in the dataset.

select distinct rest_type from zomato;

-- Q7 How many unique cuisines are available?

select name, cuisines from zomato;

-- Q8 Find restaurants whose rating is missing.

select name,rate from zomato where rate = 0;

-- Q9 Find restaurants having more than 1000 votes.

select name,votes from zomato where votes > 1000;

-- Q10 Find top 10 costliest restaurants.

select name,approx_cost from zomato 
order by approx_cost desc
limit 10;

-- Medium level Questions

-- Q1 Find Top 10 highest rated restaurants having at least 500 votes.

select name,rate,votes from zomato
where votes>500 and rate not in('new','-')
order by rate desc
limit 10;

-- Q2 Find average rating of restaurants in each location.Order highest to lowest.

select location,avg(rate) as avg_rating
from zomato
where rate is not null and rate not in ('new','-') 
group by location
order by avg_rating desc;

-- OR

SELECT 
    location, 
    ROUND(AVG(CAST(REPLACE(rate, '/5', '') AS DECIMAL(3,2))), 2) AS avg_rating
FROM zomato
WHERE rate IS NOT NULL 
  AND rate NOT IN ('NEW', '-')
GROUP BY location
ORDER BY avg_rating DESC;

-- Q2 find resturant having rating avg more than location avg.

with avg_rate as (SELECT 
    location, 
    ROUND(AVG(CAST(REPLACE(rate, '/5', '') AS DECIMAL(3,2))), 2) AS avg_rating
FROM zomato
WHERE rate IS NOT NULL 
  AND rate NOT IN ('NEW', '-')
GROUP BY location
ORDER BY avg_rating DESC),
res_details as
(select location,name,cast(rate as decimal(3,2)) as rate from zomato where rate not in ('new','-') and rate is not null)
select r.location,r.name,r.rate,a.avg_rating from avg_rate a join res_details r on a.location = r.location
where r.rate>a.avg_rating; 

-- OR

with avg_rate as (SELECT 
    location, 
    ROUND(AVG(CAST(REPLACE(rate, '/5', '') AS DECIMAL(3,2))), 2) AS avg_rating
FROM zomato
WHERE rate IS NOT NULL 
  AND rate NOT IN ('NEW', '-')
GROUP BY location
ORDER BY avg_rating DESC)
select z.location,z.name,cast(z.rate as decimal(3,2)) as rate from zomato z join avg_rate on avg_rate.location=z.location  
where rate not in ('new','-') and rate is not null and rate>avg_rate.avg_rating;


-- OR
WITH avg_rate AS (
    SELECT 
        location, 
        ROUND(AVG(CAST(REPLACE(rate, '/5', '') AS DECIMAL(3,2))), 2) AS avg_rating
    FROM zomato
    WHERE rate IS NOT NULL 
      AND rate NOT IN ('NEW', '-')
    GROUP BY location
),
res_details AS (
    SELECT 
        location,
        name,
        CAST(REPLACE(rate, '/5', '') AS DECIMAL(3,2)) AS numeric_rate,
        rate AS original_rate
    FROM zomato
    WHERE rate IS NOT NULL 
      AND rate NOT IN ('NEW', '-')
)
SELECT 
    r.location,
    r.name,
    r.original_rate,
    a.avg_rating
FROM res_details r 
JOIN avg_rate a 
  ON r.location = a.location          -- 1. Links restaurants to THEIR location's average
WHERE r.numeric_rate > a.avg_rating;  -- 2. Compares clean numbers with clean numbers

-- Q3 Find locations having average rating above 4.2.

select location,round(avg(cast(replace(rate,'/5','') as decimal(3,2))),2) as avg_rating
from zomato
where rate is not null and rate not in('new','-')
group by location
having avg_rating > 4.2;

-- Q4 Find top 5 cuisines based on average rating.

select cuisines,round(avg(cast(replace(rate,'/5','') as decimal(3,2))),2) as avg_rating
from zomato
where rate is not null and rate not in('new','-')
group by cuisines
order by avg_rating desc
limit 5;

-- Q5 Find locations where Online Ordering is more popular.

select location,count(case when online_order ='yes' then 1 end) as no_of_hotels_provide_online_order,
ROUND(
        (count(case when online_order = 'yes' then 1 end) * 100.0) / COUNT(*), 
        2
    ) AS online_order_percentage
from zomato
group by location 
order by no_of_hotels_provide_online_order desc;

-- Q6 Find average cost for two for each restaurant type.

select rest_type,round(avg(cast(replace(approx_cost,',','') as decimal(10,2))),2) as avg_cost_for_two
from zomato
where approx_cost is not null
group by rest_type;

-- Q7 Find restaurant type generating maximum customer engagement.(Use votes as engagement.)

select rest_type,sum(votes) as engagement
from zomato
where rest_type is not null 
group by rest_type
order by engagement desc;

-- Q8 Find percentage of restaurants providing table booking.

select count(*) as total_resturants,
count(case when book_table ='yes' then 1 end ) as no_of_table_booking_rest,
round(count(case when book_table ='yes' then 1 end)*100/count(*),2) as percentage_of_table_booking
from zomato
where book_table is not null;

-- Q9 Find percentage of restaurants supporting online ordering.

select location,count(*) as total_resturants,count(case when online_order = 'yes' then 1 end) as no_of_online_order_rest,
round(count(case when online_order ='yes' then 1 end)*100/count(*),2) as percentage_of_online_order
from zomato
group by location;

-- Q10 find resturent have cost more than city avg.

select location,round(avg(approx_cost),2) as l_avg_cost
from zomato
group by location;
select * from zomato;
select city,round(avg(approx_cost)) as c_avg_cost
from zomato
group by city;

select listed_in_city,count(listed_in_city) as number
from zomato
group by listed_in_city
having number>1; 

select location,count(location) as number
from zomato
group by location
having number>1;

with c_avg as
(select listed_in_city,round(avg(replace(approx_cost,',','')),2) as city_avg_cost
from zomato
group by listed_in_city),
l_avg as
(select location,listed_in_city,round(avg(replace(approx_cost,',','')),2) as loc_avg_cost
from zomato
group by location,listed_in_city)
select l.location,l.loc_avg_cost,c.city_avg_cost,c.listed_in_city from c_avg c join l_avg l on c.listed_in_city = l.listed_in_city
where loc_avg_cost>city_avg_cost;

-- ----------------------------------------------------------------------------------------

WITH CityAverage AS (
    SELECT 
        AVG(CAST(REPLACE(`approx_cost`, ',', '') AS DECIMAL(10,2))) AS overall_city_avg
    FROM zomato
    WHERE `approx_cost` IS NOT NULL
),
LocationAverage AS (
    SELECT 
        location,
        ROUND(AVG(CAST(REPLACE(`approx_cost`, ',', '') AS DECIMAL(10,2))), 2) AS location_avg_cost,
        COUNT(*) AS total_restaurants
    FROM zomato
    WHERE `approx_cost` IS NOT NULL
      AND location IS NOT NULL
    GROUP BY location
)
SELECT 
    l.location,
    l.location_avg_cost,
    ROUND(c.overall_city_avg, 2) AS city_avg_cost,
    l.total_restaurants
FROM LocationAverage l
CROSS JOIN CityAverage c
WHERE l.location_avg_cost > c.overall_city_avg
ORDER BY l.location_avg_cost DESC;


-- ----------------------------------------------------------------------------------------
-- ADV SQL Qeustions:

use zomato;
select * from zomato;

-- Q1. Find restaurants whose rating is above the average rating of their location.(Subquery)
	
select z.location,z.name,
cast(replace(z.rate,'/5','') as decimal(3,2)) as rest_avg_rating,
loc_avg.l_avg_rating
 from(select location,round(avg(cast(replace(rate,'/5','') as decimal(3,2))),2) as l_avg_rating
from zomato
group by location) as loc_avg  join zomato z on loc_avg.location=z.location
where z.rate>loc_avg.l_avg_rating ;

-- Q2. Find restaurants whose votes are greater than average votes of their cuisine.(Correlated Subquery)

select z.name,z.votes,c_avg.cuisines_avg_votes
from (select cuisines,round(avg(votes),2) as cuisines_avg_votes
from zomato
group by cuisines) as c_avg join zomato z on c_avg.cuisines = z.cuisines
where z.votes>c_avg.cuisines_avg_votes;

-- Q3. Rank restaurants within each location based on rating.(Window)
	
select location,name,rate,dense_rank() 
over(partition by location order by cast(replace(rate,'/5','') as decimal(3,2)) desc) as rate_rank
from zomato
where rate is not null and rate not in ('new','');

-- Q4. Find Top 3 restaurants from every location.(Window)

with ranking as
(select location,name,rate,row_number() 
over(partition by location order by cast(replace(rate,'/5','') as decimal(3,2)) desc) as rate_rank
from zomato
where rate is not null and rate not in ('new',''))
select location,name,rate,rate_rank
from ranking 
where rate_rank<=3;

-- Q5. Find second highest rated restaurant from every location.(Window)
	
with ranking as
(select location,name,rate,row_number() 
over(partition by location order by cast(replace(rate,'/5','') as decimal(3,2)) desc) as rate_rank
from zomato
where rate is not null and rate not in ('new',''))
select location,name,rate,rate_rank
from ranking 
where rate_rank=2;

-- Q6.Rank cuisines by average rating.(Window)
	
with avg_cuisines as
(select cuisines,round(avg(votes),2) as avg_cuisines_rate 
from zomato 
group by cuisines)
select cuisines,avg_cuisines_rate,row_number() over() as ranking
from avg_cuisines;

-- Q7.	Find restaurants whose cost is higher than average cost of their restaurant type.

with rest_type_avg as
(select rest_type,round(avg(cast(replace(approx_cost,',','') as decimal(10,2))),2) as type_avg
from zomato
group by rest_type)
select z.location,z.name,z.rest_type,z.approx_cost,rest_type_avg.type_avg
from rest_type_avg join zomato z on rest_type_avg.rest_type=z.rest_type
where rest_type_avg.type_avg<z.approx_cost;

-- Q8.	Find locations where every restaurant supports Online Order.(Conditional Aggregation)

select location,count(*)as no_of_rest,count(case when online_order='yes' then 1 end) as online_order_rest
from zomato
group by location
having count(*)=online_order_rest;

-- Q9.	Find restaurants contributing to top 20% votes.(Window + Running Total)
	
with t_vote_per as
(select sum(votes)as total_votes,round(sum(votes)/sum(votes)*100,2) as total_votes_percentage
from zomato)
select z.votes,round(z.votes/t_vote_per.total_votes*100,2) as rest_vote_per
from t_vote_per join zomato z;

-- Q10. Find restaurants having same rating but different costs.(Self-thinking.)

with zaa as 
(select name,cast(trim(replace(rate,'/5','')) as decimal(3,1)) as rating,
cast(trim(replace(approx_cost,',','')) as decimal(10,2)) as price
from zomato)
select t.name,a.rating,a.price
from zaa a join zaa t on a.rating=t.rating and a.price<>t.price and a.name<t.name;



