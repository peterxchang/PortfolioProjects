/*
COVID-19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
From [Portfolio Project]..COVIDDeaths
where continent is not null
order by 3,4

--SELECT *
--From [Portfolio Project]..COVIDVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..COVIDDeaths
order by 1,2

-- Total Cases vs. Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..COVIDDeaths
Where location like '%states%'
order by 1,2

-- Total Cases vs. Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From [Portfolio Project]..COVIDDeaths
Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentPopulationInfected
From [Portfolio Project]..COVIDDeaths
-- Where location like '%states%'
GROUP by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..COVIDDeaths
-- Where location like '%states%'
where continent is not null
GROUP by Location, Population
order by TotalDeathCount desc

-- Highest Death Count by Continent

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..COVIDDeaths
-- Where location like '%states%'
where continent is not null
GROUP by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..COVIDDeaths
-- Where location like '%states%'
where continent is not null
Group by date
order by 1,2


-- Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..COVIDDeaths dea
Join [Portfolio Project]..COVIDVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..COVIDDeaths dea
Join [Portfolio Project]..COVIDVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..COVIDDeaths dea
Join [Portfolio Project]..COVIDVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..COVIDDeaths dea
Join [Portfolio Project]..COVIDVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Create View HighesDeathCountperContinent as
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..COVIDDeaths
-- Where location like '%states%'
where continent is not null
GROUP by continent
--order by TotalDeathCount desc

Create View TotalCasesvsTotalDeaths as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..COVIDDeaths
Where location like '%states%'
--order by 1,2