--write a	sql query to find the second highest salary from the Employees table.
select * from (
select *,dense_rank() over(order by salary desc )as dr 
from employee )a 
where dr=2

SELECT MAX(salary) AS second_highest
FROM Employee
WHERE salary NOT IN (SELECT MAX(salary) FROM Employee);

SELECT DISTINCT salary
FROM Employee
ORDER BY salary DESC
OFFSET 1 ROW FETCH NEXT 1 ROW ONLY;  -- SQL Server / Oracle

SELECT TOP 1 salary
FROM (
    SELECT TOP 2 salary
    FROM Employee
    ORDER BY salary DESC
) AS temp
ORDER BY salary ASC;

--2.write a SQL query to find the duplicate records in a table.
select employee_id,count(*) as cnt from employee
group by employee_id
having count(*)>1


select [employee_id],	[first_name],	[last_name] ,	[title],	[birth_date],	[hire_date],
	[address],	[city] ,	[region],	[postal_code],	[country] from employee 
where employee_id in (select employee_id from employee
group by 
	[employee_id],	[first_name],	[last_name] ,	[title],	[birth_date],	[hire_date],
	[address],	[city] ,	[region],	[postal_code],	[country]
having count(*)>1
)

with cte as (
select [employee_id],	[first_name],	[last_name] ,	[title],	[birth_date],	[hire_date],
	[address],	[city] ,	[region],	[postal_code],	[country]
, row_number()over(partition by employee_id order by employee_id ) as rn from employee ) 
select * from cte 
where rn>1


SELECT DISTINCT *
FROM Employee
EXCEPT
SELECT  *
FROM Employee;

SELECT e1.*
FROM Employee e1
JOIN Employee e2
  ON e1.employee_id = e2.employee_id
 AND e1.employee_id <> e2.employee_id;

 --3.Write a SQL query to remove deplicate records from table.


 WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY employee_id, first_name, last_name, department_id, salary
               ORDER BY hire_date
           ) AS rn
    FROM Employee
)
DELETE FROM cte WHERE rn > 1;
--orcle 
DELETE FROM Employee
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM Employee
    GROUP BY employee_id, first_name, last_name, salary
);



--select * from employee 

--4.write a SQL query to find the 5 highest salaris 
select distinct top 5   first_name,last_name,salary 
from employee

order by salary desc 

WITH cte AS (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM Employee
)
SELECT salary
FROM cte
WHERE rnk <= 5;

--5.Write a SQL query to find the Nth highest

SELECT TOP 1 salary
FROM (
    SELECT DISTINCT TOP  4 *
    FROM employee
    ORDER BY salary DESC
) AS temp
ORDER BY salary ASC;

--select * from Employee
WITH ranked AS (
    SELECT salary,
           ROW_NUMBER() OVER (ORDER BY salary DESC) AS rank
    FROM employee
)
SELECT salary
FROM ranked
WHERE rank = 1;

--6.write a SQL query to fetch deparments and their total salary expenditure
select department_id,sum(salary)  from employee 
group by department_id

SELECT e.employee_id,
       e.first_name,
       d.department_name,
       e.salary,
       SUM(e.salary) OVER (PARTITION BY d.department_name) AS dept_total_salary
FROM Employee e
JOIN Department d 
  ON e.department_id = d.department_id;


--7.write a SQL query to employee who joined in the last 6 months or years 
select *
from employee 
where year(hire_date ) >'2015'

SELECT *
FROM Employees
WHERE hire_date >= DATEADD(YEAR, -8, GETDATE());

--8.write a SQL query to employees who are not in any department
select e.employee_id, e.first_name, e.last_name, e.salary
from employee e 
left join  department d on e.department_id=d.department_id
where d.department_id is  null 

SELECT e.employee_id, e.first_name, e.last_name, e.salary
FROM Employees e
WHERE e.department_id NOT IN (SELECT department_id FROM Department);

SELECT e.employee_id, e.first_name, e.last_name, e.salary
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM Department d
    WHERE e.department_id = d.department_id
);

--9.write a SQL query to the total number of employees in each department
SELECT department_id,
       COUNT(*) AS total_employees
FROM Employees
GROUP BY department_id;

SELECT d.department_name
       ,COUNT(e.department_id) AS total_employees
FROM Employees e
JOIN Department d 
  ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_employees DESC;

--10.write a SQL query to pivot data to show department-wise employee count  
SELECT *
FROM (
    SELECT d.department_name, e.employee_id
    FROM Employees e
    JOIN Department d 
      ON e.department_id = d.department_id
) src
PIVOT (
    COUNT(employee_id)
    FOR department_name IN ([HR], [IT], [Finance], [Sales])
) p;


SELECT
    SUM(CASE WHEN d.department_name = 'HR' THEN 1 ELSE 0 END) AS HR,
    SUM(CASE WHEN d.department_name = 'IT' THEN 1 ELSE 0 END) AS IT,
    SUM(CASE WHEN d.department_name = 'Finance' THEN 1 ELSE 0 END) AS Finance,
    SUM(CASE WHEN d.department_name = 'Sales' THEN 1 ELSE 0 END) AS Sales
FROM Employees e
JOIN Department d 
  ON e.department_id = d.department_id;

--11.write a SQL query to 
--12.write a SQL query to find month-over-month revenu growth 
--select * from orders1; 
WITH monthly_revenue AS (
    SELECT 
        DATEPART(YEAR, order_date) AS year,
        DATEPART(MONTH, order_date) AS month,
        SUM(amount) AS revenue
    FROM Orders1
    GROUP BY DATEPART(YEAR, order_date), DATEPART(MONTH, order_date)
)
SELECT 
    year,
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
    CASE 
        WHEN LAG(revenue) OVER (ORDER BY year, month) IS NULL THEN NULL
        ELSE ROUND(
            ((revenue - LAG(revenue) OVER (ORDER BY year, month)) 
             / LAG(revenue) OVER (ORDER BY year, month)) * 100, 2
        )
    END AS mom_growth_percent
FROM monthly_revenue
ORDER BY year, month;

--13.write a SQL query to the running total of sales by date. 
select sale_date,total_amount,
sum(total_amount) over (order by sale_date ) as running 

from sales

--14.write a SQL query to gaps in a sequence of numbers.

SELECT 
    num AS current_num,
    LEAD(num) OVER (ORDER BY num) AS next_num,
    LEAD(num) OVER (ORDER BY num) - num -1 AS gap_size
FROM Numbers

WITH Seq AS (
    SELECT TOP 20 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
SELECT n AS missing_num
FROM Seq
WHERE n NOT IN (SELECT num FROM Numbers);

WITH Seq AS (
    SELECT MIN(num) AS n, MAX(num) AS max_n
    FROM Numbers
    UNION ALL
    SELECT n + 1, max_n
    FROM Seq
    WHERE n + 1 <= max_n
)
SELECT n AS missing_num
FROM Seq
WHERE n NOT IN (SELECT num FROM Numbers)
OPTION (MAXRECURSION 0);

SELECT 
    a.num AS current_num,
    b.num AS next_num,
    (b.num - a.num - 1) AS gap_size
FROM Numbers a
JOIN Numbers b ON b.num = (
    SELECT MIN(num) FROM Numbers WHERE num > a.num
)
WHERE b.num - a.num > 1;


--15.write a SQL query to 
--16.write a SQL query to 
--17.write a SQL query to 
--18.write a SQL query to 
--19.write a SQL query to 
--20.write a SQL query to 
--21.write a SQL query to 
--22.write a SQL query to 
--23.write a SQL query to 
--24.write a SQL query to 
--25.write a SQL query to 
--26.write a SQL query to 
--27.write a SQL query to 
--28.write a SQL query to 
--29.write a SQL query to 
--30.write a SQL query to 
--31.write a SQL query to 
--32.write a SQL query to 
--33.write a SQL query to 
--34.write a SQL query to reverse a string 
SELECT REVERSE(first_name) AS reversed_string from employee 

--35.write a SQL query to 
--36.write a SQL query to 
--37.write a SQL query to 
--38.write a SQL query to 
--39.write a SQL query to 
--40.write a SQL query to calculate yera over year growth .

SELECT 
    year,
    revenue,
    LAG(revenue) OVER (ORDER BY year) AS prev_year_revenue,
    --lead(revenue)over(order by year) as next_year_revenue ,
    CASE 
        WHEN LAG(revenue) OVER (ORDER BY year) = 0 THEN NULL
        ELSE ROUND(((revenue - LAG(revenue) OVER (ORDER BY year)) 
                     / LAG(revenue) OVER (ORDER BY year)) * 100, 2)
    END AS yoy_growth_percent
FROM Sales_revenu1;

--41.write a SQL query to 
--42.write a SQL query to to find difference between two dates in days 

SELECT --event_id,
       DATEDIFF(DAY, start_date, end_date) AS diff_in_days
FROM daterange;
--43.write a SQL query to find overlapping date ranges
--44.write a SQL query to 
--45.write a SQL query to 
--46.write a SQL query to 

--47.write a SQL query to insert only distinct records from anothar table 
-- Now insert distinct records from source
INSERT INTO Target (emp_id, emp_name, department)
SELECT DISTINCT emp_id, emp_name, department
FROM Employees_Source;

--48.write a SQL query to update salary by 10% for a specific depatment
update   employee 
set salary=salary*1.10
where department_id=1 
--49.write a SQL query to find employee name in uppercase and lowercase 
select upper(first_name),lower(last_name)
from employee 

--50.write a SQL query to generate a series of dates between two given dates.
with range as (
select start_date as dt ,end_date 
from daterange
union all 
select dateadd(day,1,dt) ,end_date 
from range 
where dateadd(day,1,dt)>=end_date 
)
select dt  from range 
order by dt 


-------
select * from Customers 

select 'jukur.prathap@gds.ey.com '

DECLARE @email VARCHAR(100) = 'jukur.prathap@gds.ey.com';

SELECT SUBSTRING(
           @email,
           CHARINDEX('@', @email) + 1,   -- start at 'e'
           CHARINDEX('.',@email) - CHARINDEX('@',@email)-1                               -- length of 'EY'
       ) AS output;

DECLARE @email VARCHAR(100) = 'jukur.prathap@gds.ey.com';

SELECT SUBSTRING(
           @email,
           CHARINDEX('@', @email) + 1,-- 6  -- start right after '@'
           CHARINDEX('.', @email) - CHARINDEX('.ey', @email) - 1   -- length until first dot
       ) AS output;

DECLARE @email VARCHAR(100) = 'jukur.prathap@gds.ey.com';

SELECT SUBSTRING(
           @email,
           CHARINDEX('.', @email) + 1,   -- start right after the first dot
           CHARINDEX('@', @email) - CHARINDEX('.', @email) - 1  -- length until '@'
       ) AS output;
