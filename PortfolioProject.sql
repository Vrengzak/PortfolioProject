select *
from PortfolioProject..[ covidDeaths]
order by 3,4

select *
from PortfolioProject..covidVaccinations
order by 3,4
--select the data that we will be working on
select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProject ..[ covidDeaths]
order by 1,2
--Looking at total cases vs total deaths 

select location, date, total_cases, new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject ..[ covidDeaths]
where location like '%Nigeria%'
order by 1,2
--Looking at total cases vs Population
--shows the population got covid

select location, date, population, total_cases, (total_cases/population)*100 as infectionRate
from PortfolioProject ..[ covidDeaths]
where location like '%kingdom%'
order by 1,2

--looking at countries with the highest infection rate compared to poluation

select location, population, Max (total_cases)as highestInfectionCount, MAX((total_cases/population))*100 as infectionRate
from PortfolioProject ..[ covidDeaths]
group by location, population
order by infectionRate desc

--Shows the countries with highest death count per population
select location, Max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject ..[ covidDeaths]
where continent is not null
group by location
order by totalDeathCount desc

--Lets break things down by continent

select location, Max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject ..[ covidDeaths]
where continent is null
group by location
order by totalDeathCount desc
--GLOBAL NUMBERS
Select sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum (new_cases)*100 as Deathpercentage
from PortfolioProject..[ covidDeaths]
where continent is not null
--group by date
order by 1,2

--VACCINATIONS!
select *
from PortfolioProject..[ covidDeaths] dea
join PortfolioProject..covidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--looking at total polulation vs vaccinations
with PopvsVac(continent, Location,date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
from PortfolioProject..[ covidDeaths]dea
join PortfolioProject..covidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac
--use VTE
--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
from PortfolioProject..[ covidDeaths]dea
join PortfolioProject..covidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating views for later visualisation

create view PercentPopulationVaccinat as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
from PortfolioProject..[ covidDeaths]dea
join PortfolioProject..covidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3