/*
Covid 19 Data Exploration February 24th 2020 - April 30th 2021  

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select *
--FROM [PortfolioProject].dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM [PortfolioProject].dbo.CovidDeaths 
WHERE location like '%states%' 
AND continent is not null
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [PortfolioProject].dbo.CovidDeaths 
WHERE location like '%states%'
ORDER BY 1,2

--Exploring some countries

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [PortfolioProject].dbo.CovidDeaths 
WHERE location IN ('Andorra','United States','Portugal','Czechia','South Korea') 
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [PortfolioProject].dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [PortfolioProject].dbo.CovidDeaths 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [PortfolioProject].dbo.CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Correct numbers of continents with the highest death count per population

Select location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [PortfolioProject].dbo.CovidDeaths 
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

-- Total Population vs Vaccinations

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null -- and dea.location = 'Portugal'
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH CTE_PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null --and dea.location = 'Portugal'
-- ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM CTE_PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null --and dea.location = 'Portugal'
-- ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

