--2. Retrieve the Second Highest Salary from Employee Table
SELECT MAX(salary) AS SecondHighestSalary
FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee);

SELECT MAX(salary) AS FourthHighestSalary
FROM Employee
WHERE salary < (
    SELECT MAX(salary)
    FROM Employee
    WHERE salary < (
        SELECT MAX(salary)
        FROM Employee
        WHERE salary < (
            SELECT MAX(salary)
            FROM Employee
        )
    )
);


select max(salary) as fourthsalary from employee 
where salary <(select max(salary) from employee
where salary < (select max(salary) from employee
wHERE salary < (SELECT MAX(salary) FROM Employee
)
)
)