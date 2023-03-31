--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
--Shows the liklihood of dying if you contract covid in my country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Look at Total cases vs Population
--Shows what percentage of Population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentOfPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC

--Showing Countries with the Highest Death Count per Population
---- Using WHERE continent is not null to take out WORLD/ income/etc.

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with Highest Death Count

--SELECT continent, MAX(total_deaths) as TotalDeathCount
--FROM CovidDeaths
--WHERE continent is not null
----WHERE location like '%states%'
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

-----compare with below, for some reason the below one is correct.

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--For Drill Down Effect, run the same queries above you ran for Countries on Continents

---- Looking at the Total Cases vs Total Deaths

SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

----Look at Total cases vs Population
----Shows what percentage of Population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
WHERE continent is null
ORDER BY 1,2


----Looking at Continents with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentOfPopulationInfected
FROM CovidDeaths
Where continent is null
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC


----Showing Continents with the Highest Death Count per Population

SELECT location, population, MAX(total_deaths) as TotalDeathCount, (MAX(total_deaths)/population)*100 as DeathCountperPopulation
FROM CovidDeaths
WHERE continent is null
GROUP BY location, population
ORDER BY DeathCountperPopulation DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, (Sum(new_deaths))/(SUM(new_cases))*100 as GlobalDeathPercentage
FROM CovidDeaths
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2

--CovidVaccinations Table

SELECT *
FROM CovidVaccinations

--JOIN TABLES TOGETHER

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
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

--Temp Table

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
WHERE dea.continent is not null
--ORDER BY 2,3 


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

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