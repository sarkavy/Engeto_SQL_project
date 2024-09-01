-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH payroll AS (
	SELECT 
		AVG(avg_value) AS avg_payroll,
		date_year 
	FROM t_sarka_vymetalikova_project_sql_primary_final
	WHERE category_type = 'payroll' AND (date_year = 2006 OR date_year = 2018)
	GROUP BY date_year
	)
SELECT
	t.category_name,
	t.date_year,
	t.avg_value AS avg_price,
	ROUND(payroll.avg_payroll, 0) AS avg_payroll,
	ROUND(payroll.avg_payroll/t.avg_value, 0) AS ppw
FROM t_sarka_vymetalikova_project_sql_primary_final t
JOIN payroll ON t.date_year = payroll.date_year
WHERE t.category_code IN ('114201','111301') AND (t.date_year = 2006 OR t.date_year = 2018);



