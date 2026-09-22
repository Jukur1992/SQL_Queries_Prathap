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

select * from employee 
where region like 'Tel%'