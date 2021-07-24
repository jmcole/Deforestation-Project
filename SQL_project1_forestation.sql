CREATE VIEW forestation
AS SELECT
f.country_code Code, f.country_name Country, f.year, f.forest_area_sqkm Area, ROUND(CAST(l.total_area_sq_mi as numeric) * 2.59,2) AS area_km, r.region Region, r.income_group, ROUND(CAST(f.forest_area_sqkm as numeric) /(CAST(l.total_area_sq_mi as numeric) *2.59)* 100,2) AS Percent_Forested
FROM forest_area f, land_area l, regions r
WHERE f.country_code=l.country_code AND f.year = l.year
AND l.country_code=r.country_code;

-- a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.

SELECT area
FROM forestation
WHERE country = 'World' AND year = 1990;

-- 41282694.9

-- b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”

SELECT area
FROM forestation
WHERE country = 'World' AND year = 2016;
-- 39958245.9

-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?

SELECT b.area-a.area
AS loss
FROM forestation AS a
JOIN forestation  AS b
  ON  (a.year = '1990' AND b.year = '2016'
  AND a.country = 'World' AND b.country = 'World');
-- -1324449

-- d. What was the percent change in forest area of the world between 1990 and 2016?

SELECT ROUND((CAST(b.area as numeric) - CAST(a.area as numeric) )* 100 / CAST(b.area as numeric),2) AS percent_loss
	FROM forestation as a
    JOIN forestation as b
        ON  (a.year = '1990' AND b.year = '2016'
        AND a.country = 'World' AND b.country = 'World');
-- -3.21

-- e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

SELECT country, area_km As SqKm
	FROM forestation
	WHERE year = 2016 AND area_km < (SELECT ABS(b.area-a.area)
AS loss
FROM forestation AS a
JOIN forestation  AS b
  ON  (a.year = '1990' AND b.year = '2016'
  AND a.country = 'World' AND b.country = 'World'))
	ORDER BY area_km DESC
	LIMIT 1;
-- Peru	1279999.99

-- Part II
CREATE VIEW forestation
AS SELECT
f.country_code Code, f.country_name Country, f.year, f.forest_area_sqkm Area, l.total_area_sq_mi * 2.59 AS area_km, r.region Region, 
r.income_group, ROUND(CAST(f.forest_area_sqkm as numeric)/CAST(l.total_area_sq_mi *2.59 as numeric)* 100,2) AS Percent_Forested
FROM forest_area f, land_area l, regions r
WHERE f.country_code=l.country_code AND f.year = l.year
AND l.country_code=r.country_code;

CREATE View Region AS
SELECT region, ROUND((SUM(CAST(area as numeric))/SUM(CAST(area_km as numeric)))*100, 2) AS Regions, year
FROM forestation
GROUP BY region,year;

-- a. What was the percent forest of the entire world in 2016?

SELECT region,regions as Percent_Forested
FROM Region
WHERE year = 2016 AND region = 'World'
GROUP BY region,regions;

--World	31.38

--Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
(SELECT region,regions AS Forested_Area
FROM region
WHERE year = 2016
order by regions DESC
LIMIT 1)
UNION ALL
(SELECT region,regions AS Forested_Area
FROM region
WHERE year = 2016
order by regions ASC
LIMIT 1);

--Latin America & Caribbean	46.16
--Middle East & North Africa	2.07

--Table 2.1: Percent Forest Area by Region, 1990 & 2016:
SELECT region, 
max(case when year = 1990 then Regions end) as "1990",
max(case when year = 2016 then Regions end) as "2016"
FROM Region
WHERE year = 1990 or year = 2016
GROUP BY region;

---Part III

--Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?

SELECT a.country AS country, a.region as region,ROUND(CAST(b.area AS numeric)- ROUND(CAST(a.area AS numeric),2)) AS Change,ROUND((CAST(b.area AS numeric)- CAST(a.area AS numeric))/CAST(b.area as numeric)*100,2) AS Percent
FROM forestation AS a
JOIN forestation  AS b
  ON  b.year = '1990' AND a.year = '2016' and a.country = b.country
  WHERE a.country <> 'World'
  GROUP by a.country, a. region,change,percent
  ORDER by Change ASC -- order by percent for increase in percent
  LIMIT 5;


--Table 3.1: Top 5 Amount Decrease in Forest Area by Country, 1990 & 2016:

SELECT a.country AS country, a.region as region, ROUND(CAST(a.area as numeric)-CAST(b.area as numeric),2) as Total_Change
FROM forestation AS a
JOIN forestation  AS b
  ON  b.year = '1990' AND a.year = '2016' and a.country = b.country
  WHERE a.country <> 'World'
  GROUP by a.country, a. region,Total_change
  ORDER by Total_Change ASC
  LIMIT 5;


  --Table 3.2: Top 5 Percent Decrease in Forest Area by Country, 1990 & 2016:
  --b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?

SELECT a.country AS country, a.region as Region,ROUND((CAST(b.area AS numeric) - CAST(a.area AS numeric))/CAST(a.area AS numeric)*100,2) AS Percentage_loss
FROM forestation AS a
JOIN forestation  AS b
  ON  a.year = '1990' AND b.year = '2016' and a.country = b.country
  WHERE a.country <> 'World'
  GROUP by a.country, a.region,percentage_loss
  ORDER by percentage_loss ASC
  LIMIT 5;

  -- Table 3.3: Count of Countries Grouped by Forestation Percent Quartiles, 2016:
  --c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

WITH a AS(SELECT country, percent_forested
FROM forestation
WHERE year = 2016
AND country <> 'World'
)
SELECT
COUNT(CASE WHEN a.percent_forested <= 25 THEN 1 ELSE NULL END) AS q1,
COUNT(CASE WHEN a.percent_forested > 25 AND a.percent_forested <= 50 THEN 1 ELSE NULL END) AS q2,
COUNT(CASE WHEN a.percent_forested > 50 AND a.percent_forested <= 75 THEN 1 ELSE NULL END) AS q3,
COUNT(CASE WHEN a.percent_forested > 75 THEN 1 ELSE NULL END) AS q4
FROM a;

--Table 3.4: Top Quartile Countries, 2016:
--d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

SELECT country,region, percent_forested
FROM forestation
WHERE year = 2016
AND country <> 'World'
AND percent_forested > 75
ORDER BY Percent_forested DESC;

-- e. How many countries had a percent forestation higher than the United States in 2016?

SELECT COUNT(country) percent_forested
FROM forestation
WHERE year = 2016
AND country <> 'World'
AND percent_forested > (SELECT percent_forested FROM forestation WHERE country = 'United States' AND year = 2016)
Order by percent_forested DESC;

-- 94