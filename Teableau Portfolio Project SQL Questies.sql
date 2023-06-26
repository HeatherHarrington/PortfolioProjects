/* 

Queries used for Tableau Project

*/




--1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--just double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International" Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----where location like '%states%'
--where location = 'World'
----Group by date
--order by 1,2

--2.

--We take these out as they are not included in the above queries and want to stay consistent
--European Union is part of Europe

Select location, sum(cast(new_deaths as int) ) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null
and location not in ('World','European Union', 'International')
Group by location
order by TotalDeathCount desc

--3. 

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc

--4.

select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc



--Queries I originally had, but excluded some because it created too long video
--Here only in case you want to check them out

--1.

select dea.continent, dea.location, dea.date, dea.population, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3


--2.

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International" Location


--Select SUM(New_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--where location = 'World'
--Order by 1,2


--3. 

-- We take these out as they are not included in the above queries and want to stay consistent
--European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 4. 

Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By Location, Population
Order by PercentPopulationInfected desc


--5. 

--Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where continent is not null
--order by 1,2

-- Took the above query and added population

Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--6. 

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac

--7. 

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
Order by PercentPopulationInfected desc