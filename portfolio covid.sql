-- Análisis exploratorio de los datos de la COVID 19

SELECT * 
FROM covid_deaths 
WHERE continent IS NOT NULL	
ORDER BY 2,3;


-- Seleccionando los datos que vamos a necesitar

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, t
	otal_deaths, 
	population
FROM covid_deaths 
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Investigando total de casos vs total de fallecidos
-- Nos da la probabilidad de fallecer por COVID en España
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths,
	total_deaths/total_cases*100 AS deaths_percentage
FROM covid_deaths 
WHERE location = 'Spain'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Investigando el total de casos VS la población
-- Nos da el porcentaje de la población se ha contagiado por COVID en España
SELECT 
	location, 
	date, 
	total_cases, 
	population,
	total_cases/population*100 AS infection_percentage
FROM covid_deaths 
-- WHERE location = 'Spain'
ORDER BY 1,2;

-- Porcentaje de infectados por paises ordenados de mayor a menor
SELECT 
	location, 
	population, 
	MAX(total_cases) AS Highest_Infection_count,
	MAX(total_cases/population*100) AS infection_percentage
FROM covid_deaths 
WHERE continent IS NOT NULL
GROUP BY 1,2
ORDER BY 4 DESC;

-- Veremos los paises con el mayor porcentaje de fallecidos por orden
SELECT 
	location,
	max(total_deaths) AS total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- Ver los datos por continente

SELECT sub.continent,
SUM(total_death_count) as total_death_count_continent
FROM
	(SELECT 
		continent,
		location,
		max(total_deaths) AS total_death_count
	FROM covid_deaths
	WHERE continent IS NOT NULL
	GROUP BY 1,2
	HAVING max(total_deaths) IS NOT NULL
	ORDER BY 3 DESC
	)sub
GROUP BY 1 ORDER BY 2 DESC;

--Valores Globales
-- Casos detectados
SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths)/SUM(new_cases)*100 AS death_percent
FROM covid_deaths
WHERE continent IS NOT NULL	
GROUP BY 1
ORDER BY 1;

--

SELECT 
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths)/SUM(new_cases)*100 AS death_percent
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Uniendo ambas tablas e investigando la población total vs los vacunados totales

SELECT 
	sub.*,
	sub.rolling_vaccinations/sub.population*100 AS percet_vaccination
FROM
(SELECT 
	d.location,
	d.continent,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.date=v.date
AND d.location=v.location
WHERE d.continent IS NOT NULL
ORDER BY 1,3) sub

-- Creando una "vista" de una tabla para poder acceder a ella más adelante
CREATE VIEW Percent_population_vaccinated
AS
SELECT 
	d.location,
	d.continent,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.date=v.date
AND d.location=v.location
WHERE d.continent IS NOT NULL
