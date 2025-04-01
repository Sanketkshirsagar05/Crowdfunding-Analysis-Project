Create database crowdfunding;

use crowdfunding;

select count(*) from projects;

select count(*) from creator;
 
select count(*) from location;
 
select count(*) from category;

#Q1. Convert the Date fields to Natural Time------------------------------------------------

alter table projects add column Created_date date;

update projects
set Created_date = if(created_at > 0, date(from_unixtime(created_at)), null);


alter table projects add column Successful_at_date date;

update projects
set Successful_at_date = if(successful_at > 0, date(from_unixtime(successful_at)), null);
    
    
select ProjectID, Created_date, Successful_at_date
from projects;

#2. Build a Calendar Table using the Column Created Date-----------------------------------------------------------

#A.Year
alter table projects add year int;

update projects
set year = year(created_date);

#B.Monthno
alter table projects add month_no int;

update projects
set month_no = month(created_date);

#C.Monthfullname
alter table projects add month_name varchar(20);

update projects
set month_name = monthname(created_date);

#D.Quarter
alter table projects add quarter varchar(20);

update projects
set quarter = 
    case 
        when month(created_date) between 1 and 3 then 'Qtr-1'
        when month(created_date) between 4 and 6 then 'Qtr-2'
        when month(created_date) between 7 and 9 then 'Qtr-3'
        when month(created_date) between 10 and 12 then 'Qtr-4'
    end;
    
#E.YearMonth
alter table projects add yearmonth varchar(20);

update projects
set yearmonth = date_format(created_date, '%Y-%b');

# F.Weekdayno
alter table projects add weekday_no int;

update projects
set weekday_no = case 
    when dayofweek(created_date) = 1 then 7 
    else dayofweek(created_date) - 1
end;

#G.Weekdayname
alter table projects add weekday_name varchar(20);

update projects
set weekday_name = dayname(created_date);

# H.FinancialMonth
alter table projects add financial_month varchar(20);

update projects
set financial_month = 
    case 
        when month(created_date) = 4 then 'FM1'
        when month(created_date) = 5 then 'FM2'
        when month(created_date) = 6 then 'FM3'
        when month(created_date) = 7 then 'FM4'
        when month(created_date) = 8 then 'FM5'
        when month(created_date) = 9 then 'FM6'
        when month(created_date) = 10 then 'FM7'
        when month(created_date) = 11 then 'FM8'
        when month(created_date) = 12 then 'FM9'
        when month(created_date) = 1 then 'FM10'
        when month(created_date) = 2 then 'FM11'
        when month(created_date) = 3 then 'FM12'
    end;

#I.Financial Quarter
alter table projects add financial_quarter varchar(20);

update projects
set financial_quarter = 
    case 
        when month(created_date) between 4 and 6 then 'FQ-1'
        when month(created_date) between 7 and 9 then 'FQ-2'
        when month(created_date) between 10 and 12 then 'FQ-3'
        when month(created_date) between 1 and 3 then 'FQ-4'
    end;



select ProjectID,year,month_no,month_name,quarter,yearmonth,weekday_no,weekday_name,financial_month,financial_quarter from projects;

#Q4. Convert the Goal amount into USD using the Static USD Rate.----------------------------------------------------
alter table projects add goal_usd bigint;

update projects
set goal_usd = goal * static_usd_rate;

select ProjectID,goal_usd from projects;

#Q5.Projects Overview KPI :-----------------------------------------------------------------------------------------
#A.Total Number of Projects based on outcome 
select state, count(*) as total_projects
from projects
group by state
order by total_projects desc;

#B.Total Number of Projects based on Locations
select country, count(*) as total_projects
from projects
group by country
order by total_projects desc;

#C.Total Number of Projects based on Category
select c.name, count(p.ProjectID) as total_projects
from projects p
join category c on p.category_id = c.id
group by c.name
order by total_projects desc;

#D.Total Number of Projects created by Year , Quarter , Month
#Year Quarter
select year, quarter, count(*) as total_projects
from projects
group by year, quarter
order by year, quarter;

#Month
select month_no,month_name, count(*) as total_projects
from projects
group by month_no,month_name
order by month_no,month_name;


#Q6  ------------------------------------------------------------------------------------------------
#A.Successful Projects
select concat(format(count(*) / 1000, 0), 'K') as successful_projects  
from projects  
where state = 'successful';

#B.Amount Raised 
select concat( '$ ',format(sum(usd_pledged) / 1000000, 0), 'M') AS total_amount_raised
from projects;

#C.Number of Backers
select concat(format(sum(backers_count) / 1000000, 0), 'M') AS total_backers
from projects;

#D.Avg Number of Days for successful projects
select format(avg(datediff(Successful_at_date, Created_date)), 0) as avg_days_to_success
from projects
where state = 'successful';

#Q7.Top Successful Projects :-------------------------------------------------------------------------------

#A.Based on Number of Backers
select name, backers_count
from projects
where state = 'successful'
order by backers_count desc
limit 10;

#B.Based on Amount Raised.
select name,usd_pledged
from projects
where state = 'successful'
order by usd_pledged desc
limit 10;

#8. ----------------------------------------------------------------------------------------------------------
#A.Percentage of Successful Projects overall
select 
    concat(round((count(case when state = 'successful' then 1 end) * 100.0) / count(*),2),'%')  as success_percentage
from projects;

#B.Percentage of Successful Projects  by Category
select 
    c.name,
    round((count(case when p.state = 'successful' then 1 end) * 100.0) / count(p.ProjectID),2) as success_percentage
from projects p
join category c on p.category_id = c.id
group by c.name
order by success_percentage desc
limit 5;

#C.Percentage of Successful Projects by Year , Month 
select 
    yearmonth, 
    concat(round((count(case when state = 'successful' then 1 end) * 100.0) / count(ProjectID), 2),'%') as success_percentage
from projects
group by yearmonth
order by success_percentage desc
limit 5;

#D.Percentage of Successful projects by Goal Range 
select 
    case 
        when goal <= 10000 then 'Low'
        when goal <= 50000 then 'Medium'
        when goal <= 100000 then 'High'
        else 'Very High' 
    end as goal_range,
    concat(round((count(case when state = 'successful' then 1 end) * 100.0) / count(ProjectID), 2),'%') as success_percentage
from projects
group by goal_range
order by success_percentage desc;




