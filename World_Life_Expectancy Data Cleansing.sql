# World Life Expectancy Data Cleaning

SELECT * 
FROM world_life_expectancy
;

# First Step is to identify duplicates within the dataset, I've decided to identify duplicates by first 
#concatinating the country annd year columns as we should have unqiue value for this. 

select country, year, concat(country,year), count(concat(country,year))
from world_life_expectancy
group by country, year, concat(country,year)
having count(concat(country,year)) >1 ;

#Next I use a subquery and a row number over partition to identify the unique row id of 
# concatenated countries and year

select *
from 
(
select row_id, 
concat(country,year), 
row_number() over(partition by concat(country,year) order by concat(country,year)) as row_num
from world_life_expectancy
) as row_table
where row_num >1
;

#Next step is to delete the row_id that are duplicated 
# Prior to deleting, i imported the dataset again to have a backup
delete from world_life_expectancy
where Row_ID in 
(select row_id
from 
(
select row_id, 
concat(country,year), 
row_number() over(partition by concat(country,year) order by concat(country,year)) as row_num
from world_life_expectancy
) as row_table
where row_num >1)
;


#Next I've noticed in the column status there are some blank values
SELECT * 
FROM world_life_expectancy
where Status = '';

select distinct(country)
from world_life_expectancy 
where Status <> '';

select distinct(country)
from world_life_expectancy 
where Status = 'Developing';

#Next we update the columns with blank statuses by joining the table to itself and using the update function.
                 
update world_life_expectancy t1
join world_life_expectancy t2
on t1.country = t2.country
set t1.status = 'developing' 
where t1.status = ''
and t2.status <> ''
and t2.status = 'developing';

# Also change for blank status where status should be developed
update world_life_expectancy t1
join world_life_expectancy t2
on t1.country = t2.country
set t1.status = 'developed' 
where t1.status = ''
and t2.status <> ''
and t2.status = 'developed';

#Next I identified the blank values in the life expectancy columns
SELECT * 
FROM world_life_expectancy
where `Life expectancy` = '';

# We will need to fill in the blanks for cloumsn that have no life expectancy values filled insert
# To do this we will take the life expectency values of the previoues and succeeding years and the work out the avereage

SELECT country, `Life expectancy`
FROM world_life_expectancy;

#We are going to use a self join

SELECT t1.country, t1.year, t1.`Life expectancy`, 
t2.country, t2.year, t2.`Life expectancy`,
t3.country, t3.year, t3.`Life expectancy`
FROM world_life_expectancy t1
join world_life_expectancy t2
on t1.country = t2.country
and t1.year = t2.year -1 
join world_life_expectancy t3
on t1.country = t3.country
and t1.year = t3.year +1 
where t1.`Life expectancy` = '';

#Now that I have found the blank life expectancy and what the life expectancies are for the previous and succesif years in one table
#we work our what the average should be for those blank values 

SELECT t1.country, t1.year, t1.`Life expectancy`, 
t2.country, t2.year, t2.`Life expectancy`,
t3.country, t3.year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/ 2,1)
FROM world_life_expectancy t1
join world_life_expectancy t2
on t1.country = t2.country
and t1.year = t2.year -1 
join world_life_expectancy t3
on t1.country = t3.country
and t1.year = t3.year +1 
where t1.`Life expectancy` = '';

#next we fill in the blank values with the what we have calculated using the update and join function

update world_life_expectancy t1
join world_life_expectancy t2
on t1.country = t2.country
and t1.year = t2.year -1
join world_life_expectancy t3
on t1.country = t3.country
and t1.year = t3.year +1 
set t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/ 2,1)
where t1.`Life expectancy` = '';