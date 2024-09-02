#US Household Data Cleaning - Project


SELECT *
FROM us_project.us_household_income;


SELECT *
FROM us_project.us_household_income_statistics;

## Just by first glance at the us_household_income_statistics table I can see that the first column header has the wrong value
# SO i decided to change this

alter table us_project.us_household_income_statistics rename column `ï»¿id` to `id`;

## Now i run the query again so it should work. 
SELECT *
FROM us_project.us_household_income_statistics;

## Next I want to run the count of ids for both tables

SELECT count(id)
FROM us_project.us_household_income;


SELECT count(id)
FROM us_project.us_household_income_statistics;

#Next I want to see if there are duplicates id's with each table

select id, count(id)
from us_project.us_household_income
group by id
having count(id) > 1;

select id, count(id)
from us_project.us_household_income_statistics
group by id
having count(id) > 1;

# Running the above queries i found that there are duplicates id's in the us_household_income table
# These will need to be removed using a subquery and row number - 

select *
from
 (
select row_id, id,
row_number()  over(partition by id order by id) as row_num
from us_project.us_household_income
) duplicates
where row_num > 1;

## Now that I've identified the duplicated id, I am going to delete the duplicated id's from the table

delete from us_project.us_household_income
where row_id in (
       select row_id
	   from(
			  select row_id, id,
			  row_number()  over(partition by id order by id) as row_num
			from us_project.us_household_income
              ) duplicates
            where row_num > 1);

## I ran the below query agian and the rows were deleted & the table no longer has duplicates 
select *
from
 (
select row_id, id,
row_number()  over(partition by id order by id) as row_num
from us_project.us_household_income
) duplicates
where row_num > 1;

## Next I want to standardise the state names in the us_project.us_household_income table, as some have been imputted incorrectly
## I do this by first identifying the names that have been imputted incorrectly using the syntax below
select State_Name, count(State_Name)
from us_project.us_household_income
group by State_Name;

select distinct(State_name)
from us_project.us_household_income
group by State_name;


## I use the below syntax to standardise the state name Georgia
update us_project.us_household_income
set state_name = 'Georgia'
where state_name = 'georia';

# When I ran the below syntax there was null value in row _id 32 for place. 
select *
from us_project.us_household_income
where county = 'Autauga County'
order by 1;

## I used the below query to update the null value in row_id 32 for place

update us_project.us_household_income
set place = 'Autaugaville'
where county = 'Autauga County'and city = 'Vinemont';

## Check that the table has been updated
select *
from us_project.us_household_income
where city = 'Vinemont'
order by 1;

#Next I want to take a look at the column Type

select type, count(type)
from us_project.us_household_income
group by type;

## I can see that Borough and Boroughs have been imputted interchangably, am going to standardise this to just one value using
#the below syntax
update us_project.us_household_income
set type = 'Borough'
where type = 'Boroughs';

#END 
## I checked the remaining columns within the table and everything looks good and there's wasn't anything else left to clean. 
## 


