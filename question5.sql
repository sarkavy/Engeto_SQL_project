-- 5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce,
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

WITH average AS (
		SELECT
		ROUND(AVG(yoy), 2) AS avg_yoy,
		date_year,
		category_type
	FROM t_sarka_vymetalikova_project_sql_primary_final
	GROUP BY date_year, category_type
	),
cz_hdp AS (
		SELECT
			country,
			year,
			gdp AS hdp,
			gdp_yoy AS hdp_yoy
		FROM t_sarka_vymetalikova_project_sql_secondary_final
		WHERE country = 'Czech Republic'
		),
joined AS(		
	SELECT
		a.category_type,
		a.date_year,
		a.avg_yoy AS curr_yoy,
		LEAD(a.avg_yoy,1) OVER (PARTITION BY a.category_type ORDER BY a.date_year) AS next_yoy,
		cz_hdp.hdp_yoy
	FROM average a
	LEFT JOIN cz_hdp ON a.date_year = cz_hdp.YEAR
	)
SELECT
	category_type,
	date_year,
	curr_yoy,
	next_yoy,
	hdp_yoy,
	CASE	WHEN hdp_yoy > 4 AND (curr_yoy > hdp_yoy OR next_yoy > hdp_yoy) THEN 'výrazný růst'
			WHEN hdp_yoy < -4 AND (curr_yoy < hdp_yoy OR next_yoy < hdp_yoy) THEN 'výrazný pokles'
			ELSE ''
			END AS description
FROM joined;


