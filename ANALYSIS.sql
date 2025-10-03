SELECT * FROM "Walmart";

DROP TABLE "Walmart_db";
-- 
SELECT 
	COUNT(*) 
	FROM "Walmart";



SELECT 
	COUNT(DISTINCT branch)
FROM "Walmart";

SELECT MAX (quantity)
FROM "Walmart";

SELECT MIN (quantity)
FROM "Walmart";

----BUSINESS PROBLEMS----

-- What are the different payment methods, and how many transactions and
-- items were sold with each method? 

SELECT 
	payment_method,
	COUNT(*) AS no_of_payments,
	ROUND(SUM(quantity)) as no_qty_sold
FROM "Walmart"
GROUP BY payment_method;


-- Which category received the highest average rating in each branch?

SELECT *
FROM
(	SELECT
		branch,
		category,
		ROUND(AVG(rating)) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM "Walmart"
	GROUP BY 1, 2
)
WHERE rank = 1


--""" What is the busiest day of the week for each branch based on transaction
--volume? """
SELECT *
FROM
	(SELECT
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
		COUNT(*) AS no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM "Walmart"
	GROUP BY 1, 2
	)
WHERE rank = 1

--""" How many items were sold through each payment method? """

SELECT 
	payment_method,
	ROUND(SUM(quantity)) as no_qty_sold
FROM "Walmart"
GROUP BY payment_method;

-- What are the average, minimum, and maximum ratings for each category in
--each city? 

SELECT
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	ROUND(AVG(rating)) as avg_rating
FROM "Walmart"
GROUP BY 1, 2

--""" What is the total profit for each category, ranked from highest to lowest? """

SELECT 
	category,
	ROUND(SUM(total_price * profit_margin)) as profit
FROM "Walmart"
GROUP BY 1


--""" What is the most frequently used payment method in each branch? """

WITH cte
AS
(SELECT
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM "Walmart"
GROUP BY 1, 2)
SELECT *
FROM cte
WHERE rank = 1

--""" How many transactions occur in each shift (Morning, Afternoon, Evening)
--across branches? """

SELECT
	*,
	CASE 
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time
FROM "Walmart";
GROUP BY 1

-----------------------------
-----------------------------

SELECT
CASE 
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM "Walmart"
GROUP BY 1
-----------------
-----------------

SELECT
	branch,
CASE 
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM "Walmart"
GROUP BY 1, 2
ORDER by 1, 3 DESC


--"""Which branches experienced the largest decrease in revenue compared to
--the previous year? """

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS formated_date
FROM "Walmart"

-- 2022 Sales

WITH revenue_2022
AS
(
	SELECT
		branch,
		SUM(total_price) as revenue
	FROM "Walmart"
	WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
),
revenue_2023
as
(
	SELECT
		branch,
		SUM(total_price) as revenue
	FROM "Walmart"
	WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT 
	ls.branch,
	ROUND(ls.revenue) as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND((ls.revenue - cs.revenue)::numeric/ls.revenue::numeric * 100,2)
	AS rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC



