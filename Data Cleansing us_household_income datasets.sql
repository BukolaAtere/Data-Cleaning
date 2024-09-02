## US Household Income Data Cleaning

#Data Cleaning Steps


select 
* from usproject.ushouseholdincome
;

select 
* from usproject.ushouseholdincome_statistics
;

# STEP 1 - Changing one of the column name of statistics table to something more suitable

ALTER TABLE usproject.ushouseholdincome_statistics rename column `ï»¿id` to `ID`;

select count(id)
from usproject.ushouseholdincome
;

select count(id)
from usproject.ushouseholdincome_statistics
;

# STEP 2 - identifying duplicates within the dataset

select id, count(id)
from usproject.ushouseholdincome
group by id
having count(id) >1; 
 
select row_id
from
(
select row_id, id, row_number() over(partition by id order by id) row_num
	from usproject.ushouseholdincome 
	) duplicates 
	where row_num >1
    ;
    
# STEP - 3 deleting duplicates records from datasets using subqueries and row_numbers

delete from usproject.ushouseholdincome
where row_id in (
	select row_id
	from
	(select row_id, id, row_number() over(partition by id order by id) row_num
	from usproject.ushouseholdincome 
	) duplicates 
	where row_num >1);
    
    
select id, count(id)
from usproject.ushouseholdincome_statistics
group by id
having count(id) >1; 


#Data Standardisation using the update/set function

select distinct state_name
from usproject.ushouseholdincome
order by 1;

UPDATE ushouseholdincome
SET State_Name = 'Georgia'
where State_Name = 'georia';

select 
* from usproject.ushouseholdincome
WHERE county = 'Autauga County'
;

update ushouseholdincome
set place = 'Autaugaville'
where county = 'Autauga County'
and city = 'Vinemouth'
;

select type, count(type)
from usproject.ushouseholdincome
group by type;

update ushouseholdincome
set type = 'Boroughs'
where type = 'Borough';
