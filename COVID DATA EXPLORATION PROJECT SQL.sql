USE CovidDataExplorationProject
GO


SELECT * 
FROM CovidDataExplorationProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4;




--Selecting the data that we're going to be using for Covid Deaths

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDataExplorationProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;

ALTER TABLE CovidDataExplorationProject..CovidDeaths ALTER COLUMN total_cases FLOAT;
ALTER TABLE CovidDataExplorationProject..CovidDeaths ALTER COLUMN total_deaths FLOAT;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDataExplorationProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4;

--Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
FROM CovidDataExplorationProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;

--Shows likelihood of dying if you contract covid in India

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDataExplorationProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2;


--Looking at total_cases vs population
--Shows what percentage of population got covid
SELECT Location, date, population ,total_cases, (total_cases/population)*100 as InfectedPercentage
FROM CovidDataExplorationProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2;

--Looking at countries with Highest Infection Rate compared to Population
SELECT Location, population , MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
FROM CovidDataExplorationProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY Location, population
ORDER BY InfectedPercentage DESC;


--Showing the countries with Highest Death count
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDataExplorationProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Showing the Continents with Highest Death Count
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDataExplorationProject..CovidDeaths
WHERE continent IS NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Global Numbers
SELECT date,  SUM(new_cases) AS new_cases, SUM(CAST(new_deaths AS INT)) AS new_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases) * 100 AS DeathPercentage 
FROM CovidDataExplorationProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases <> 0
GROUP BY date
ORDER BY 1,2;


--Looking at Total Population vs Vaccinations

SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(CAST(CovidVaccinations.new_vaccinations AS BIGINT)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date)
	AS RollingPeopleVaccinated
FROM CovidDataExplorationProject..CovidDeaths CovidDeaths
JOIN CovidDataExplorationProject..CovidVaccinations CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
ORDER BY 2,3




--USE CITY

WITH popVSVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
	SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
	, SUM(CAST(CovidVaccinations.new_vaccinations AS BIGINT)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date)
		AS RollingPeopleVaccinated
	FROM CovidDataExplorationProject..CovidDeaths CovidDeaths
	JOIN CovidDataExplorationProject..CovidVaccinations CovidVaccinations
		ON CovidDeaths.location = CovidVaccinations.location
		AND CovidDeaths.date = CovidVaccinations.date
	WHERE CovidDeaths.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM popVSVac;



--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
	, SUM(CAST(CovidVaccinations.new_vaccinations AS BIGINT)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date)
		AS RollingPeopleVaccinated
	FROM CovidDataExplorationProject..CovidDeaths CovidDeaths
	JOIN CovidDataExplorationProject..CovidVaccinations CovidVaccinations
		ON CovidDeaths.location = CovidVaccinations.location
		AND CovidDeaths.date = CovidVaccinations.date

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated;




--Creating View to store data for later visulizations
CREATE VIEW PercentPopulationVaccinated AS 

SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
	, SUM(CAST(CovidVaccinations.new_vaccinations AS BIGINT)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date)
		AS RollingPeopleVaccinated
	FROM CovidDataExplorationProject..CovidDeaths CovidDeaths
	JOIN CovidDataExplorationProject..CovidVaccinations CovidVaccinations
		ON CovidDeaths.location = CovidVaccinations.location
		AND CovidDeaths.date = CovidVaccinations.date
	WHERE CovidDeaths.continent IS NOT NULL
	--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated

