-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- Meziroční růsty
SELECT
	category_code,
	category_name,
	date_year,
	yoy,
	CASE	WHEN yoy = 0 THEN 'stagnace'
			WHEN yoy < 0 THEN 'pokles'
			WHEN yoy > 0 THEN 'nárust'
			ELSE ''
			END AS description
FROM t_sarka_vymetalikova_project_sql_primary_final
WHERE category_type = 'payroll'
-- AND yoy < 0 											/*vyfiltruj si záznamy s poklesy*/
ORDER BY category_code;

-- Celkové a průměrné roční růsty
WITH total AS (
	SELECT *,
		LAG(avg_value, 1) OVER (PARTITION BY category_code ORDER BY category_code, date_year) AS value_2006,
		(avg_value - LAG(avg_value, 1) OVER (PARTITION BY category_code ORDER BY category_code, date_year)) / LAG(avg_value, 1) OVER (PARTITION BY category_code ORDER BY category_code, date_year) * 100 AS total_growth
	FROM t_sarka_vymetalikova_project_sql_primary_final
	WHERE category_type = 'payroll'
	AND (date_year = 2006
	OR date_year = 2018)
		),
average AS (
	SELECT
		category_code,
		category_name,
		ROUND(AVG(yoy),2) AS avg_yoy_per
	FROM t_sarka_vymetalikova_project_sql_primary_final
	WHERE category_type = 'payroll'
	GROUP BY category_name
)
SELECT
	t.category_code,
	t.category_name,
	t.value_2006,
	t.avg_value AS value_2018,
	ROUND(t.total_growth, 2) AS total_growth_per,
	g.avg_yoy_per
FROM total t
JOIN average g ON t.category_code = g.category_code 
WHERE t.date_year = 2018
ORDER BY total_growth_per;



