/*****************************/
/* COVID 19 Data Exploration */
/*****************************/

/* Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Type */


--Look at Data available in Table 1 titled CovidDeaths

SELECT *
FROM CovidDeaths
ORDER BY location, date


-- Select Data that I want to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid 19 in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


--Total Cases vs Population
--Shows what percentage of population has been infected with Covid 19

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Countries with the Highest Death Counts

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--BREAKING THINGS DOWN BY CONTINENT


--Continents with Highest Death Count

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null
and location <> 'World'
GROUP BY location
ORDER BY TotalDeathCount DESC


--Continents with Highest Total Cases vs Total Deaths


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as InfectedDeathPercentage
FROM CovidDeaths
WHERE continent is null
and location <> 'World'
ORDER BY 1,2

--Continents with Highest Total cases vs Population


SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
WHERE continent is null
and location <> 'World'
ORDER BY 1,2


--Continents with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentOfPopulationInfected
FROM CovidDeaths
Where continent is null
and location <> 'World' 
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC


--Showing Continents with the Highest Death Count per Population

SELECT location, population, MAX(total_deaths) as TotalDeathCount, (MAX(total_deaths)/population)*100 as DeathCountperPopulation
FROM CovidDeaths
WHERE continent is null
and location <> 'World' 
GROUP BY location, population
ORDER BY DeathCountperPopulation DESC


--GLOBAL NUMBERS



--Global Total Death Count

SELECT location, SUM(new_deaths) as GlobalDeathCount
FROM CovidDeaths
WHERE continent is null 
and location = 'World'
GROUP BY location


--Global Total Cases vs Total Deaths

SELECT location, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, (Sum(new_deaths))/(SUM(new_cases))*100 as GlobalDeathPercentage
FROM CovidDeaths
WHERE continent is null 
and location ='World'
GROUP BY location


--Global Total Cases vs Population

SELECT location, population, SUM(new_cases) as Total_Cases, (Sum(new_cases)/population)*100 as GlobalInfectedPercentage
FROM CovidDeaths
WHERE continent is null 
and location = 'World'
GROUP BY location, population
ORDER BY GlobalInfectedPercentage



--Table 2 titled CovidVaccinations

--Look at Data available in CovidVaccinations 

SELECT *
FROM CovidVaccinations
ORDER BY location, date


--JOIN CovidDeaths and CovidVaccinations together

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
ORDER BY dea.Location, dea.date


--Total Population vs Vaccination
--Show percentage of population that has recieved at least one Covid 19 vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Use CTE to perform calculation on PARTITION BY in previous query

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Use Temp Table to perform calculation on PARTITION BY in previous query

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3 


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 

SELECT *
FROM PercentPopulationVaccinated