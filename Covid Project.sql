--select *
--From CovidProject..CovidVaccinations
--order by 3,4

--select *
--From CovidProject..CovidDeaths
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Show the likelihood of dying if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where location like 'Canada'
order by 1,2

--Looking at total cases vs total population
select location, date, total_cases,population, total_deaths, (total_cases/population)*100 as InfectionPercentage
From CovidProject..CovidDeaths
where location like 'Canada'
order by 1,2

 -- looking at contries with highest infection rate compared to population
 select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
where continent is not NULL
group by location, population
order by PercentPopulationInfected desc


-- Looking at contries with highest death count per popilation
select location, max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc

-- Lets break things down by continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is NUll
group by location
order by TotalDeathCount desc

select continent, max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is not NUll
group by continent
order by TotalDeathCount desc

--Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null
order by 1,2


--looking at total popluation vs vacciations
--Use CTE
with PopVsVac (Continent, location, date, poplulation, new_vaccinations, RollingPeopleVaccination)
as
(
select
d.continent, d.location, d.date, d.population, v.new_vaccinations
,sum(convert(int, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as RollingPeopleVaccination
--(RollingPeopleVaccination/d.population)*100
from CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2,3
)
select *, 
(RollingPeopleVaccination/poplulation)*100
from PopVsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric,
)
Insert Into #PercentPopulationVaccinated
select
d.continent, d.location, d.date, d.population, v.new_vaccinations
,sum(convert(int, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as RollingPeopleVaccination
--(RollingPeopleVaccination/d.population)*100
from CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2,3
select *, 
(RollingPeopleVaccination/population)*100
from #PercentPopulationVaccinated


--createview to store data for later visualization
create view PercentPopulationVaccinated as
select
d.continent, d.location, d.date, d.population, v.new_vaccinations
,sum(convert(int, v.new_vaccinations)) over (Partition by d.location order by d.location, d.date) as RollingPeopleVaccination
--(RollingPeopleVaccination/d.population)*100
from CovidProject..CovidDeaths d
JOIN CovidProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
where d.continent is not null

select *
from PercentPopulationVaccinated
