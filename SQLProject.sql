

SELECT *
FROM CovidDeaths
ORDER BY 3,4


--SELECT location, date , new_cases , total_cases , total_deaths , population
--FROM CovidDeaths
--ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows the likehood of death if you contract covid-19 in your country 

Select location,
SUM(new_cases) as total_cases , 
SUM(CONVERT(INT,new_deaths)) as total_deaths,
(SUM(CONVERT(INT,new_deaths))/(SUM(new_cases)))*100 as death_percentage
FROM CovidDeaths
GROUP BY location
ORDER BY location


-- Total Cases & Total Deaths vs Population

Select location, date , population, total_cases , total_deaths , 
	   (total_cases/population)*100 as Cases_Percentage,
	   (total_deaths/population)*100 as Deaths_Percentage

FROM CovidDeaths
ORDER BY location, date


-- Countries with the highest infection & deaths compared to population

-- Infections
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_deaths) as HighestDeathCount ,
	   MAX((total_cases/population))*100 as PercentPopulationInfected,
	   MAX((total_deaths/population))*100 as PercentPopulationDeaths

FROM CovidDeaths
WHERE location NOT IN (continent)
GROUP BY location,population
ORDER BY HighestInfectionCount DESC

-- Deaths
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_deaths) as HighestDeathCount ,
	   MAX((total_cases/population))*100 as PercentPopulationInfected,
	   MAX((total_deaths/population))*100 as PercentPopulationDeaths

FROM CovidDeaths
WHERE location NOT IN (continent)
GROUP BY location,population
ORDER BY HighestDeathCount DESC




