## Data Cleaning - World Layoff Dataset



SELECT * FROM world_layoffs.layoffs;

# Step -1  - Removing Duplicates if there are any present
# Step -2 Standardise the data
# Step -3 Null Values
# Step -4 Removing irrelevant columns 

#We need to have a raw copy of the original World Layoff Dataset, as we'll be changing the dataset by a lot we are going to create a new table 
# Which is table we'll be working with for the data cleansing. 

create table layoff_staging
like layoffs;

select *
from layoff_staging;

insert layoff_staging
select *
from layoffs;


# Step -1 - REMOVING DUPLICATES We are going to first create a cte including a row number to identify the dulplicate values 

with duplicates_cte as 
(
select *, 
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) as row_num
from layoff_staging
)
select *
from duplicates_cte
where row_num > 1;

#Then we check if the above synatx has worked, by selecting a company to see if the duplicates are returned
select *
from layoff_staging
where company = 'Casper';

#Next we need to delete the duplicate values, as we can't update the cte to remove the duplicates, we will need to take the select syntax within
# the Cte and create another another table and delete the duplicate columns. 

create table `layoff_staging2` (
`company` text,
`location` text,
`industry` text,
`total_laid_off` int DEFAULT NULL,
`percentage_laid_off` text,
`date` text,
`stage` text,
`country` text,
`fund_raised_millions` int DEFAULT NULL,
`row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoff_staging2;

insert into layoff_staging2
select *, 
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) as row_num
from layoff_staging;

select *
from layoff_staging2
where row_num >1;

delete
from layoff_staging2
where row_num >1;

select *
from layoff_staging2;


# STEP 2- STANDARDISATION - FINDING ISSUES IN THE DATA AND FIXING IT.

#Removing Spacing at the begining/end of values in company
select company, trim(company)
from layoff_staging2;

update layoff_staging2
set company = trim(company)
;

# Searching for unstandardised industry names within the industry column
select distinct(industry)
from layoff_staging2;

## Within the industry colums, Crypto has be inputted as 'Crypto' and 'Crypto Currency' - We are going to standardise this to one.
select 
*
from layoff_staging2
where industry like 'crypto%'; 

#Updating to Crypto
update layoff_staging2
set industry = 'Crypto'
where industry like 'crypto%';
 
select distinct(industry)
from layoff_staging2;

#Standardising the country column

Select distinct(country), trim(trailing '.' from country)
from layoff_staging2
order by 1;

#Country United States have been inputted twice as a result of a typo error, We are going to update this using the syntax below
update layoff_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';


select distinct(country)
from layoff_staging2
order by 1;

#Next we want to change the dates from a text format to date format

select `date`, str_to_date(`date`,'%m/%d/%Y')
from layoff_staging2
;

update layoff_staging2
set date = str_to_date(`date`,'%m/%d/%Y')
;

select *
from  layoff_staging2;

# Then we modify the column header too.

alter table layoff_staging2
modify column `date`  date;


#STEP 3 - NULL AND BLANK VALUES 

# We first looked at rows where the total laid off and percentage laid off is null
select *
from  layoff_staging2
where total_laid_off is null
and percentage_laid_off is null; 

## We are going to first update the table by setting the blank values to null
update layoff_staging2
set industry = null
where industry = '';

# Then we looked at blank and null inputs per industry
select*
from layoff_staging2
where industry is null or industry = '';

# We filtered this down further by looking at one company 'Air Bnb' 
select *
from layoff_staging2
where company = 'Airbnb';

#We joined the table to itself to figure out what the blank values should be
select t1.industry, t2.industry
from layoff_staging2 as t1
join layoff_staging2 as t2
    on t1.company = t2.company 
where (t1.industry is null or t1.industry = '') 
and t2.industry is not null;

#Then we updated to set the null from the first table to values from the second table
update layoff_staging2  as t1
join layoff_staging2 as t2
    on t1.company = t2.company 
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

Select *
from layoff_staging2;

#Next we want to take a look at the companies that have no total_laid_off and no percentage_laid_off, we don't believe these companies
# had any layoffs, so we are going to delete them from the table as won't need them for the data exploratory phase. 
select *
from  layoff_staging2
where total_laid_off is null
and percentage_laid_off is null; 


## STEP 4 - REMOVING IRRELEVANT COLUMNS
delete
from  layoff_staging2
where total_laid_off is null
and percentage_laid_off is null; 

#Next we don't need the row_num columns anymore so we're going to drop it from the table.
alter table layoff_staging2
drop column row_num;

select *
from layoff_staging2;

##End 


