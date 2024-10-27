
-- TVORBA TABULKY PRIMARY FINAL

CREATE TABLE t_sarka_vymetalikova_project_SQL_primary_final (
	id INT AUTO_INCREMENT PRIMARY KEY,
	category_code VARCHAR(10),
	category_name VARCHAR(255),
	category_type VARCHAR(50),
	date_year INT(11),
	avg_value DECIMAL(10,2),
	yoy DECIMAL (10,2)
	);
	
INSERT INTO t_sarka_vymetalikova_project_sql_primary_final (category_code, date_year, avg_value)
	SELECT
		category_code,
		YEAR(date_from) AS date_year,
		AVG(value) AS avg_value
	FROM czechia_price
	WHERE region_code IS NULL AND category_code != '212101'
	GROUP BY category_code, date_year
	HAVING date_year BETWEEN 2006 AND 2018;
	
INSERT INTO t_sarka_vymetalikova_project_sql_primary_final (category_code, date_year, avg_value)
	SELECT
		industry_branch_code AS category_code,
		payroll_year AS date_year,
		AVG(value) AS avg_value
	FROM czechia_payroll cp
	WHERE value_type_code = 5958 AND calculation_code = 100 AND unit_code = 200 AND industry_branch_code IS NOT NULL
	GROUP BY category_code, date_year
	HAVING date_year BETWEEN 2006 AND 2018;

UPDATE t_sarka_vymetalikova_project_sql_primary_final
JOIN czechia_payroll_industry_branch ON t_sarka_vymetalikova_project_sql_primary_final.category_code = czechia_payroll_industry_branch.code
SET t_sarka_vymetalikova_project_sql_primary_final.category_name = czechia_payroll_industry_branch.name, t_sarka_vymetalikova_project_sql_primary_final.category_type = 'payroll';
	
UPDATE t_sarka_vymetalikova_project_sql_primary_final
JOIN czechia_price_category ON t_sarka_vymetalikova_project_sql_primary_final.category_code = czechia_price_category.code
SET t_sarka_vymetalikova_project_sql_primary_final.category_name = czechia_price_category.name, t_sarka_vymetalikova_project_sql_primary_final.category_type = 'price';

CREATE TEMPORARY TABLE temp_yoy AS
	SELECT
		id,
		avg_value,
		category_code,
		date_year,
		(avg_value - LAG(avg_value, 1) OVER (PARTITION BY category_code ORDER BY category_code, date_year)) / LAG(avg_value, 1) OVER (PARTITION BY category_code ORDER BY category_code, date_year) * 100 AS growth
	FROM t_sarka_vymetalikova_project_sql_primary_final;

UPDATE t_sarka_vymetalikova_project_sql_primary_final f
JOIN temp_yoy t ON f.id=t.id
SET f.yoy = t.growth;


-- Kde data nejsou kompletni
-- bílé víno jakostní
   WITH periods AS (
	SELECT DISTINCT date_year
	FROM t_sarka_vymetalikova_project_SQL_primary_final
),
products AS (
	SELECT DISTINCT category_code
	FROM t_sarka_vymetalikova_project_SQL_primary_final
),
base AS (
	SELECT 
	     *
	FROM periods
	CROSS JOIN products
),
joined AS (
	SELECT  
       base.date_year,
       base.category_code,
       c.avg_value
  	FROM base 
  	LEFT JOIN t_sarka_vymetalikova_project_SQL_primary_final c ON base.date_year = c.date_year
  	AND base.category_code = c.category_code
)
SELECT * FROM joined
WHERE avg_value IS NULL;
   
-- SELECT * FROM t_sarka_vymetalikova_project_sql_primary_final;


