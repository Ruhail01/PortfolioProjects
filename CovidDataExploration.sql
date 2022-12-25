------ Covid Deaths and Cases -------

SELECT *
FROM SQLDataExp..CovidDeaths
ORDER BY 3,4


SELECT location, date , new_cases , total_cases , total_deaths , population
FROM SQLDataExp..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows the likehood of death if you contract covid-19 in your country

Select location,
SUM(new_cases) as total_cases ,
SUM(CONVERT(INT,new_deaths)) as total_deaths,
(SUM(CONVERT(INT,new_deaths))/(SUM(new_cases)))*100 as death_percentage
FROM SQLDataExp..CovidDeaths
GROUP BY location
ORDER BY location


-- Total Cases & Total Deaths vs Population

Select location, date , population, total_cases , total_deaths ,
         (total_cases/population)*100 as Cases_Percentage,
         (total_deaths/population)*100 as Deaths_Percentage

FROM SQLDataExp..CovidDeaths
ORDER BY location, date


-- Countries with the highest infection & deaths compared to population

-- Infections
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_deaths) as HighestDeathCount ,
         MAX((total_cases/population))*100 as PercentPopulationInfected,
         MAX((total_deaths/population))*100 as PercentPopulationDeaths

FROM SQLDataExp..CovidDeaths
WHERE location NOT IN (continent)
GROUP BY location,population
ORDER BY HighestInfectionCount DESC

-- Deaths
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_deaths) as HighestDeathCount ,
         MAX((total_cases/population))*100 as PercentPopulationInfected,
         MAX((total_deaths/population))*100 as PercentPopulationDeaths

FROM SQLDataExp..CovidDeaths
WHERE location NOT IN (continent)
GROUP BY location,population
ORDER BY HighestDeathCount DESC


-- Continents with the highest infection and death count

--Infections

Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_deaths) as HighestDeathCount ,
         MAX((total_cases/population))*100 as PercentPopulationInfected,
         MAX((total_deaths/population))*100 as PercentPopulationDeaths

FROM SQLDataExp..CovidDeaths
WHERE continent is null
GROUP BY location,population
ORDER BY HighestInfectionCount DESC


-- Deaths
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_deaths) as HighestDeathCount ,
         MAX((total_cases/population))*100 as PercentPopulationInfected,
         MAX((total_deaths/population))*100 as PercentPopulationDeaths

FROM SQLDataExp..CovidDeaths
WHERE continent is null
GROUP BY location,population
ORDER BY HighestDeathCount DESC


----- Covid Vaccinations -----

SELECT *
FROM SQLDataExp..CovidVaccinations


-- Joining both tables


SELECT *
FROM SQLDataExp..CovidDeaths as deaths
INNER JOIN SQLDataExp..CovidVaccinations as vac
ON deaths.location = vac.location AND deaths.date = vac.date



-- Total Vaccinations vs Population

SELECT deaths.continent , deaths.location , deaths.date , deaths.population , vac.new_vaccinations,
      SUM(CONVERT(int, vac.new_vaccinations))
      OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as total_vaccinations_to_date
FROM SQLDataExp..CovidDeaths as deaths
INNER JOIN SQLDataExp..CovidVaccinations as vac
ON deaths.location = vac.location AND deaths.date = vac.date
WHERE deaths.continent is not null and deaths.location = 'Canada' and vac.new_vaccinations is not null
ORDER BY 2,3


--- Using CTE

WITH PopvsVac (Continent, Location, Date , Population, New_Vaccinations , Total_vaccinations_to_date)
AS
(

SELECT deaths.continent , deaths.location , deaths.date , deaths.population , vac.new_vaccinations,
      SUM(CONVERT(bigint, vac.new_vaccinations))
      OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as total_vaccinations_to_date
FROM SQLDataExp..CovidDeaths as deaths
INNER JOIN SQLDataExp..CovidVaccinations as vac
ON deaths.location = vac.location AND deaths.date = vac.date
WHERE deaths.continent is not null  and vac.new_vaccinations is not null

)

SELECT *, ((Total_vaccinations_to_date)/(Population))*100 as Percent_Vaccinated
FROM PopvsVac
ORDER BY Location, Date


--- Using Temp Tables to perform again perform calculation on Partition By 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vaccinations_to_date numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as total_vaccinations_to_date

From SQLDataExp..CovidDeaths deaths
Join SQLDataExp..CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date


Select *, (total_vaccinations_to_date/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as total_vaccinations_to_date
From SQLDataExp..CovidDeaths deaths
Join SQLDataExp..CovidVaccinations vac
	On deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null

SELECT *
FROM PercentPopulationVaccinated
