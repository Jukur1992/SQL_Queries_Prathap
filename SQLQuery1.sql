 --cte  common table expresion 

 with cte as (
 select employee_id,first_name,last_name,row_number()over (partition by employee_id order by [hire_date]) as rn
 from Employee  )
 delete from cte where rn>1
 --orcle 
 DELETE FROM Employee
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM Employee
    GROUP BY employee_id
);



with cte as ( 

select year (order_date) as year
,sum(amount) as Revenue 
from orders1 
group by year (order_date)
) 
select year,revenue 
,revenue-lag(revenue)over(order by year) as yoy_growth
from cte 

with ranked as (

select customer_id,order_date ,amount 
,NTILE(2)
over(partition by customer_id order by amount ) as decile 
from orders  ) 
select customer_id,order_date ,amount 
from ranked  where decile=2


ALTER TABLE Employee
ADD department_id INT;



UPDATE Employee
SET department_id = 3
WHERE employee_id = 7;

UPDATE Employee
SET department_id = 4
WHERE employee_id = 9;

select department_id,count(*) as emp 
,count(*)*100/(select count(*) from Employee) as per
from Employee
group by department_id

select department_id, max(salary)-min(salary) as amount_diff from employee 
group by department_id


select MONTH(hire_date) as month 
,sum(case when region in ('Telangana','Tamil Nadu','Karnataka') then salary else 0 end ) as south
,sum(case when region in('Maharashtra','West Bengal') then salary else 0 end) as north 
,sum(case when region not in ('Telangana','Tamil Nadu','Karnataka','Maharashtra','West Bengal') then salary 
else 0 end ) as allstates
from employee 

group by MONTH(hire_date) order by 1
--select * from Employee   

select department_id,round(avg(salary),2) as dept_avg 
from employee 

group by department_id
having avg(salary)>(select avg(salary) from Employee)

WITH cte AS (
    SELECT 
        customer_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id 
            ORDER BY order_date DESC
        ) AS prev_date
    FROM Orders
)
SELECT 
    customer_id,
    avg(DATEDIFF(DAY, prev_date, order_date)) AS avg_gap_days
FROM cte
WHERE prev_date IS NOT NULL
GROUP BY customer_id;


/*without pivot */
select Product
,sum(case when quarter='Q1' then sales end ) as Q1
,sum(case when quarter='Q2' then sales end ) as Q2
--select *
from salesdate 
group by PRODUCT 
/* using pivot*/
select product,Q1,Q2 from (
select * from salesdate   ) src 
pivot ( 
sum(sales) for quarter in (Q1,Q2) ) P 

/*without unpivot*/ 
--select * from salesummary
select PRODUCT,'Q1' as quarter ,Q1 as sales from salesummary 
union 
select PRODUCT,'Q2' as quarter ,Q2 as sales from salesummary 
/*using unpivot */
select * from salesummary 
unpivot (
sales for quarter in (Q1,Q2) ) p 

--select * from Signals

WITH location_counts AS (
    SELECT device_id,
           location,
           COUNT(*) AS signal_count
    FROM Signals
    GROUP BY device_id, location
),
-- Step 2: Rank locations by signal count per device
--select * from location_counts
ranked AS (
    SELECT device_id,
           location,
           signal_count,
           ROW_NUMBER() OVER (
               PARTITION BY device_id
               ORDER BY signal_count DESC
           ) AS rn
    FROM location_counts
)
--select * from ranked 
-- Step 3: Final aggregation
SELECT lc.device_id,
       COUNT(DISTINCT lc.location) AS no_of_locations,
       r.location AS max_signal_location,
       SUM(lc.signal_count) AS no_of_signals
FROM location_counts lc
JOIN ranked r
  ON lc.device_id = r.device_id AND r.rn = 1
GROUP BY lc.device_id, r.location;
