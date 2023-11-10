/* File inquiry */

USE PortfolioProject1_Vaccinations
SELECT * FROM CovidVaccinations$ ORDER BY 3,4

SELECT * FROM CovidDeaths$ ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths$ ORDER BY 1,2

/* Death-case-ratio CH*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) AS death_case_ratio FROM CovidDeaths$ WHERE location = 'Switzerland' ORDER BY 1,2 

/* Death-case-ratio global*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) AS death_case_ratio FROM CovidDeaths$ WHERE continent is not null ORDER BY 1,2 

/* Case-population-ratio CH */

SELECT location, date, total_cases, population, (total_cases/population) AS case_population_ratio FROM CovidDeaths$ WHERE location = 'Switzerland' ORDER BY 1,2 

/* Case-population-ratio CH */

SELECT location, date, total_cases, population, (total_cases/population) AS case_population_ratio FROM CovidDeaths$ WHERE continent is not null  ORDER BY 1,2 


/* Max Cases by population */

SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX(total_cases/population) AS case_population_ratio FROM CovidDeaths$ GROUP BY location, population ORDER BY case_population_ratio desc

/* Max Deaths by population */

SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count, population, MAX(total_deaths/population) AS deaths_population_ratio FROM CovidDeaths$ WHERE continent is not null GROUP BY location, population ORDER BY deaths_population_ratio desc

/* Max Deaths by continent*/

SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count FROM CovidDeaths$ WHERE continent is null GROUP BY location ORDER BY highest_death_count desc

/* Global development over time */

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) AS death_case_ratio FROM CovidDeaths$ WHERE continent is not null GROUP BY date ORDER BY 1,2

/* Join data to look at vaccination-population-ratio*/

SELECT CovidDeaths$.date, CovidDeaths$.population, CovidDeaths$.location, CovidDeaths$.continent, CovidVaccinations$.new_vaccinations, SUM(CAST(CovidVaccinations$.new_vaccinations as int)) OVER (PARTITION BY CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.date) AS vaccination_trend
FROM CovidDeaths$
JOIN CovidVaccinations$
	ON CovidDeaths$.location = CovidVaccinations$.location
	AND CovidDeaths$.date = CovidVaccinations$.date
	WHERE CovidDeaths$.continent is not null 
	ORDER BY 3,4

/* Generate CTE to infer vaccination rate by country */

With cte_vac_rate (date, population, location, continent, new_vaccinations, vaccination_trend)
as
(
SELECT CovidDeaths$.date, CovidDeaths$.population, CovidDeaths$.location, CovidDeaths$.continent, CovidVaccinations$.new_vaccinations, SUM(CAST(CovidVaccinations$.new_vaccinations as int)) OVER (PARTITION BY CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.date) AS vaccination_trend
FROM CovidDeaths$
JOIN CovidVaccinations$
	ON CovidDeaths$.location = CovidVaccinations$.location
	AND CovidDeaths$.date = CovidVaccinations$.date
	WHERE CovidDeaths$.continent is not null 
)
SELECT *, (vaccination_trend/population) AS vaccination_rate
FROM cte_vac_rate
ORDER BY 3,4

/* Creating visualization basis for vaccination trend */

CREATE VIEW vaccination_trend AS
SELECT CovidDeaths$.date, CovidDeaths$.population, CovidDeaths$.location, CovidDeaths$.continent, CovidVaccinations$.new_vaccinations, SUM(CAST(CovidVaccinations$.new_vaccinations as int)) OVER (PARTITION BY CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.date) AS vaccination_trend
FROM CovidDeaths$
JOIN CovidVaccinations$
	ON CovidDeaths$.location = CovidVaccinations$.location
	AND CovidDeaths$.date = CovidVaccinations$.date
	WHERE CovidDeaths$.continent is not null 

/* Creating visualization basis for deaths by continent */
CREATE VIEW deaths_by_continent AS
SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count FROM CovidDeaths$ WHERE continent is null GROUP BY location 

/* Visualisations for Tableau */

--- 1 ---

SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count, MAX(total_cases) AS highest_infection_count, (MAX(cast (total_deaths as int))/MAX(total_cases)) AS deaths_cases_ratio FROM CovidDeaths$ WHERE continent is null GROUP BY location ORDER BY highest_death_count desc

--- 2 ---

SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX(total_cases/population) AS case_population_ratio FROM CovidDeaths$ GROUP BY location, population ORDER BY case_population_ratio desc

--- 3 ---

SELECT location, date, MAX(total_cases) AS highest_infection_count, population, MAX(total_cases/population) AS case_population_ratio FROM CovidDeaths$ GROUP BY location, population, date ORDER BY case_population_ratio desc

