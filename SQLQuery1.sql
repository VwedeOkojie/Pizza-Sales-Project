/*
Covid 19 Data Exploration

Skills used: Joins, CTE's Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



SELECT TOP * 
FROM CovidDeaths
ORDER BY 3,4 



-- Select Data that we are going to be starting with

SELECT Location, Date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2



--Total Covid Cases vs Total Deaths in Canada
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
Where Location Like '%Canada%'
AND Continent IS NOT NULL
ORDER BY 1,2



--What percentage of people got infected with Covid?

SELECT Location, Date, total_cases, population,(total_cases/population)*100 TestedPositiveForCovid
FROM CovidDeaths
Where Location Like '%Canada%'
AND Continent IS NOT NULL
ORDER BY 1,2



--What Countries had the Highest Infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) HighestInfectionRate, MAX((total_cases/population))*100 TestedPositiveForCovid
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TestedPositiveForCovid DESC



--Countries with the Highest Death Rate Compared to Population

SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



--BREAKING THINGS DOWN BY CONTINENT

--Continent with the Highest Death Rate per Population

SELECT Continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC



--Global Numbers

SELECT SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--How Many Pecent of the Population are Vaccinated?

SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, 
SUM(cast(b.new_vaccinations as int)) OVER (Partition by a.location ORDER BY a.location,  a.date) RollingPeopleVaccinated
FROM CovidDeaths a
JOIN CovidVaccinations b
ON a.location =b.location
AND a.date=b.date
WHERE a.continent IS NOT NULL
ORDER BY 2, 3



--Using CTE to Perform Calculation on Partition By in Previous Query

WITH PopulationvsVaccination (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(cast(b.new_vaccinations as int)) OVER (Partition by a.location ORDER BY a.location, a.date) RollingPeopleVaccinated
FROM CovidDeaths a
JOIN CovidVaccinations b
ON a.location =b.location
AND a.date=b.date
WHERE a.continent IS NOT NULL
)
SELECT*, (RollingPeopleVaccinated/population)*100 PercentageOfVaccinated
FROM PopulationVsVaccination



--Using Temp Table to Perform Calculation on Partition By in Previous Query

DROP TABLE IF EXISTS #PecentOfPopulationVaccinated 
CREATE TABLE #PecentOfPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
DATE datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PecentOfPopulationVaccinated
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(cast(b.new_vaccinations as int)) OVER (Partition by a.location order by a.date) RollingPeopleVaccinated
FROM CovidDeaths a
JOIN CovidVaccinations b
ON a.location =b.location
AND a.date=b.date

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PecentOfPopulationVaccinated




--Creating View to Store for Data Visualizations

CREATE VIEW PecentOfPopulationVaccinated as 
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, 
SUM(cast(b.new_vaccinations as int)) OVER (Partition by a.location order by a.date) RollingPeopleVaccinated
FROM CovidDeaths a
JOIN CovidVaccinations b
ON a.location =b.location
AND a.date=b.date
WHERE a.continent IS NOT NULL
