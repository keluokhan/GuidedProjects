select *
from coviddeaths

update coviddeaths 
set continent = null 
where continent = ''

--select *
--from covidvaccinations

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths c 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from coviddeaths
where location like 'Azer%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date, population, total_cases , (total_cases/population)*100 as InfectionRate
from coviddeaths
where location like 'Azer%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
from coviddeaths
group by location, population 
order by InfectionRate desc;

-- Showing countries with the highest death count per population
select location , MAX(cast(total_deaths as signed int)) as TotalDeathCount
from coviddeaths
where continent  is not null
group by location  
order by TotalDeathCount desc;

-- Showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as signed int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent  
order by TotalDeathCount desc;

-- global numbers
select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as signed int)) as Total_deaths,
SUM(cast(new_deaths as signed int))/sum(new_cases)*100 as Death_percentage
from coviddeaths
where continent is not null
-- group by date
order by 1,2

-- Looking at total population vs vaccination
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent , dea.location , dea.date, population, new_vaccinations, 
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac 
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp table
drop temporary table if exists PercentPopulationVaccinated;

create temporary table PercentPopulationVaccinated
(
continent text,
location text,
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

insert into PercentPopulationVaccinated
select dea.continent , dea.location , dea.date, population, new_vaccinations, 
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac 
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3;

select *, (RollingPeopleVaccinated/population)*100 as RVP
from PercentPopulationVaccinated;

-- Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent , dea.location , dea.date, population, new_vaccinations, 
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac 
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null;
-- order by 2,3;

select *
from percentpopulationvaccinated