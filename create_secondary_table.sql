
-- TVORBA TABULKY SECONDARY FINAL

CREATE TABLE t_sarka_vymetalikova_project_SQL_secondary_final (
	id INT AUTO_INCREMENT PRIMARY KEY,
	country VARCHAR(255),
	year INT(4),
	gdp DECIMAL(20,2),
	gdp_yoy DECIMAL (10,2),
	gini DECIMAL(10,2),
	population DECIMAL(20,2),
	taxes DECIMAL(10,2)
	);

INSERT INTO t_sarka_vymetalikova_project_sql_secondary_final (country, year, gdp, gini, population, taxes)
		SELECT
			c.country,
			e.year,
			e.gdp,
			e.gini,
			e.population,
			e.taxes
		FROM countries c
		JOIN economies e ON c.country = e.country 
		WHERE continent = 'Europe' AND year BETWEEN 2006 AND 2018;

CREATE TEMPORARY TABLE temp_hdp AS
	SELECT
		id,
		country,
		year,
		gdp,
		(gdp - LAG(gdp, 1) OVER (PARTITION BY country ORDER BY country, year)) / LAG(gdp, 1) OVER (PARTITION BY country ORDER BY country, year) * 100 AS gdp_yoy
	FROM t_sarka_vymetalikova_project_sql_secondary_final
	WHERE country NOT IN ('Faroe Islands', 'Liechtenstein','Gibraltar');

UPDATE t_sarka_vymetalikova_project_sql_secondary_final s
JOIN temp_hdp h ON s.id=h.id
SET s.gdp_yoy = h.gdp_yoy;

-- Země, u kteréch se nepřiřadil kontinent
-- Isle of Man, Timor-Leste
WITH continent AS (
	SELECT
		e.country,
		c.continent,
		e.year
	FROM economies e
	JOIN countries c ON e.country = c.country
)
SELECT DISTINCT country
FROM continent
WHERE continent IS NULL AND year BETWEEN 2006 AND 2018;

-- Kde nejsou kompletní data hdp pro evropské státy
-- Faroe Islands, Liechtenstein, Gibraltar
WITH country AS (
	SELECT DISTINCT country
	  FROM t_sarka_vymetalikova_project_sql_secondary_final
		),
	period AS (
		SELECT DISTINCT YEAR
		FROM t_sarka_vymetalikova_project_sql_secondary_final
	),
	base AS (
		SELECT 
		     *
		FROM period
		CROSS JOIN country
	),
	joined AS (
SELECT  
       base.year,
       base.country,
       t.gdp
  FROM base
  LEFT JOIN t_sarka_vymetalikova_project_sql_secondary_final t
    ON base.year = t.year
   AND base.country = t.country
)
SELECT DISTINCT country FROM joined
-- SELECT * FROM joined
WHERE gdp IS NULL;

-- SELECT *FROM  t_sarka_vymetalikova_project_sql_secondary_final;




	