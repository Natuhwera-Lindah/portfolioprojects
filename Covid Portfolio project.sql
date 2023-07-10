--SELECT * 
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4
--Select data that we shall be using
SELECT Location,date,total_cases,new_cases, total_deaths, population 
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths
ORDER BY 1,2

-- Looking at total cases Vs Total deaths
-- shows likehood of dying if you contract covid in your country
SELECT Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total cases vs Population
--Shows what percentage of populaion got covid
SELECT Location,date,population,total_cases, (total_cases/population)*100 AS percentagePopulationInfected
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT Location,population,MAX(total_cases) AS HighestInfectioncount,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY population,location
ORDER BY percentagePopulationInfected DESC 

-- Showing countries with highest death count per population
SELECT Location,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break down things by continent
-- Showing continents with the highest death count per population
SELECT continent,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))
OVER (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths AS dea
JOIN [PORTFOLIO PROJECT].dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE
WITH popvsvac (continent, Location, date, population,new_vaccinations,  RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))
OVER (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths AS dea
JOIN [PORTFOLIO PROJECT].dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, ( RollingPeopleVaccinated/population)*100
FROM popvsvac

-- Temp table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))
OVER (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths AS dea
JOIN [PORTFOLIO PROJECT].dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
Select *, ( RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations))
OVER (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths AS dea
JOIN [PORTFOLIO PROJECT].dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated










