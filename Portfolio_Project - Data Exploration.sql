Select *
from Portfolio_Project..CovidDeaths
order by 3,4

--Select *
--from Portfolio_Project..CovidVaccinations
--order by 3,4

-- Selecting the Data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Showing the likelihood of dying if you contract COVID in India

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
where location like 'India'
order by 1, 2

-- Looking at Total Cases vs Population
-- Showing what percentage of population got COVID in India

Select location, date, population, total_cases, (total_cases/population)*100 as Infected_Percentage
from Portfolio_Project..CovidDeaths
where location like 'India'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from Portfolio_Project..CovidDeaths
-- where location like 'India'
group by location, population
order by PercentagePopulationInfected desc

-- Showing Countries with highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
-- where location like 'India'
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing Continents with highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
-- where location like 'India'
where continent is null
group by location
order by TotalDeathCount desc

-- Using Continents instead of location. Using continents is necessary for Tableau visualization.

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
-- where location like 'India'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null
group by date
order by 1, 2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Using TEMP TABLE

Drop Table if exists #PercentPopeulationVaccinated
Create Table #PercentPopeulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopeulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
-- where dea.continent is not null
-- order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopeulationVaccinated

-- Creating View  to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3
