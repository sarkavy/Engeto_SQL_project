-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH payroll AS (
	SELECT
		ROUND (AVG(yoy), 2) AS avg_yoy_payroll,
		date_year 
	FROM t_sarka_vymetalikova_project_sql_primary_final
	WHERE category_type = 'payroll' AND yoy IS NOT NULL
	GROUP BY date_year
	),
price AS (
	SELECT
		ROUND (AVG(yoy), 2) AS avg_yoy_price,
		date_year 
	FROM t_sarka_vymetalikova_project_sql_primary_final
	WHERE category_type = 'price' AND yoy IS NOT NULL
	GROUP BY date_year
)
SELECT
	pr.date_year,
	pr.avg_yoy_price,
	pa.avg_yoy_payroll,
	ROUND (pa.avg_yoy_payroll - pr.avg_yoy_price, 2) AS difference
FROM payroll pa
JOIN price pr ON pa.date_year = pr.date_year;
