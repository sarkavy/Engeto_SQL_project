-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT
	category_name,
	ROUND (AVG(yoy),2) AS avg_yoy 
FROM t_sarka_vymetalikova_project_sql_primary_final t
WHERE category_type = 'price'
GROUP BY category_name
ORDER BY avg_yoy;

