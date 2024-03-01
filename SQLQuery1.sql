--SELECT TOP 7* 
--FROM CovidDeaths
--order by 3,4 
--SELECT TOP 7*
--FROM CovidVaccinations
--order by 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
order by 1,2

--Total Covid Cases vs Total Deaths in Canada
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
Where location like '%Canada%'
AND continent IS NOT NULL
order by 1,2

--What percentage of people got Covid
SELECT location, date, total_cases, population,(total_cases/population)*100 TestedPositiveForCovid
FROM CovidDeaths
Where location like '%Canada%'
AND continent IS NOT NULL
order by 1,2

--What countries had the highest infection rate compare to population
SELECT location, population, MAX(total_cases) HighestInfectionRate, MAX((total_cases/population))*100 TestedPositiveForCovid
FROM CovidDeaths
Where continent IS NOT NULL
Group by location, population
order by TestedPositiveForCovid DESC

--Countries with the Highest Death Rate per Population
SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
Where continent IS NOT NULL
Group by location
order by TotalDeathCount DESC

--Continent with the Highest Death Rate per Population
SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
Where continent IS NULL
Group by location
order by TotalDeathCount DESC

SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
Where continent IS NOT NULL
Group by continent
order by TotalDeathCount DESC

--Continent with the Highest Death Count
SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
Where continent IS NOT NULL
Group by continent
order by TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

--How many pecent of the population are vaccinated
Select a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(cast(b.new_vaccinations as int)) OVER (Partition by a.location, a.date) RollingPeopleVaccinated
From CovidDeaths a
Join CovidVaccinations b
on a.location =b.location
and a.date=b.date
Where a.continent IS NOT NULL
Order by 2, 3

--Use CTE
WITH PopulationvsVaccination (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
Select a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(cast(b.new_vaccinations as int)) OVER (Partition by a.location order by a.date) RollingPeopleVaccinated
From CovidDeaths a
Join CovidVaccinations b
on a.location =b.location
and a.date=b.date
Where a.continent IS NOT NULL
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopulationvsVaccination

--TEMP TABLE

DROP TABLE IF EXISTS #PecentOfPopulationVaccinated 
CREATE TABLE #PecentOfPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
DATE datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PecentOfPopulationVaccinated
Select a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(cast(b.new_vaccinations as int)) OVER (Partition by a.location order by a.date) RollingPeopleVaccinated
From CovidDeaths a
Join CovidVaccinations b
on a.location =b.location
and a.date=b.date
--Where a.continent IS NOT NULL

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PecentOfPopulationVaccinated

--Creating view to store for Data Visualizations

CREATE VIEW PecentOfPopulationVaccinated as 
Select a.continent, a.location, a.date, a.population, b.new_vaccinations, 
SUM(cast(b.new_vaccinations as int)) OVER (Partition by a.location order by a.date) RollingPeopleVaccinated
From CovidDeaths a
Join CovidVaccinations b
on a.location =b.location
and a.date=b.date
Where a.continent IS NOT NULL
--Order by 2,3


SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM CovidDeaths
Where continent IS NOT NULL
Group by continent
order by TotalDeathCount DESC


SELECT *
FROM PercentOfPopulationVaccinated