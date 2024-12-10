Select * from portfolioproject..CovidDeaths
order by 3,4

--Select * from portfolioproject..CovidVaccination
--order by 3,4

--Select Data that we are going to be using

Select location , date , total_cases , new_cases , total_deaths , population  
from portfolioproject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
Select location , date , total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location like 'turkey'
order by 1,2


-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
Select location , date , population, total_cases , (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
where location like 'turkey'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount , max(total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
--where location like 'turkey'
group by location , population
order by PercentPopulationInfected desc



-- Showing Countries  with Highest Death Count per Population
-- cast(total_deaths as int) -> we converted total_deaths column integer 
-- we should get rid of continents thats why we will filter where continent is not null

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
--where location like 'turkey'
where continent is not null
group by location 
order by TotalDeathCount desc

-- LET'S BREAK THIS DOWN BY CONTINENT 
-- this doesnt look correct it seems north america numbers equal same USA
-- now this is corect numbers 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
--where location like 'turkey'
where continent is null
group by location 
order by TotalDeathCount desc



Select date, sum(new_cases)-- , (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Looking at Total Poplulation vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location, dea. Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
order by 2,3

 
--USE CTE (RollingPeopleVaccinated to use new column again)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location, dea. Date) as RollingPeopleVaccinated
--, (Rolling PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccination vac
  On dea.location = vac.location
  and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated


-- Creating View  to store data for later visualizations

USE portfolioproject

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    --, (RollingPeopleVaccinated/population)*100
FROM 
    portfolioproject..CovidDeaths dea
JOIN 
    portfolioproject..CovidVaccination vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;
-- ORDER BY 2,3;




Select *
From PercentPopulationVaccinated