-- language: sql
-- Retrieve and sort COVID-19 death data by continent, excluding null values

select *
from `covid19-392218.Coviddata.CovidDeaths`
where continent is not null
order by 3,4

-- Selecting the data that we will be starting with

select location, date, total_cases, new_cases, total_deaths, population
from `covid19-392218.Coviddata.CovidDeaths`
where continent is not null 
order by 1,2

-- Looking at the number of cases vs the number of deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `covid19-392218.Coviddata.CovidDeaths`
Where continent is not null 
order by 1,2

-- Looking at the death percentages in the United Kingdom

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from `covid19-392218.Coviddata.CovidDeaths`
where location like '%United Kingdom%' and
continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in the United Kingdom

select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from `covid19-392218.Coviddata.CovidDeaths`
where location like '%United Kingdom%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from `covid19-392218.Coviddata.CovidDeaths`
where continent is not null 
group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from `covid19-392218.Coviddata.CovidDeaths`
where continent is not null 
group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from `covid19-392218.Coviddata.CovidDeaths`
where continent is null 
group by location
order by TotalDeathCount desc

-- Global numbers

select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from `covid19-392218.Coviddata.CovidDeaths`
where continent is not null 
group By date
order by 1,2

-- Total Population vs Vaccinations
-- The Percentage of Population that has recieved at least one Covid Vaccine

-- Performing Rolling Count Calculation using Subquery

select continent, location, date, population, new_vaccinations,
  SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingCountVaccination,
  (SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) / population) * 100 AS PercentageVaccinated
from (
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  from `covid19-392218.Coviddata.CovidDeaths` dea
  join `covid19-392218.Coviddata.CovidVaccinations` vac
    ON dea.location = vac.location
    and dea.date = vac.date
  where dea.continent is not null
) subquery
order by 2, 3;

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac as (
  select subquery.continent, subquery.location, subquery.date, subquery.population, subquery.new_vaccinations,
    SUM(subquery.new_vaccinations) OVER (PARTITION BY subquery.location order by subquery.location, subquery.date) as RollingCountVaccination,
    (SUM(subquery.new_vaccinations) OVER (PARTITION BY subquery.location order by subquery.location, subquery.date) / subquery.population) * 100 as PercentageVaccinated
  from (
    select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    from `covid19-392218.Coviddata.CovidDeaths` dea
    join `covid19-392218.Coviddata.CovidVaccinations` vac
      on dea.location = vac.location
      and dea.date = vac.date
    where dea.continent is not null
  ) as subquery
)
select *
from PopvsVac
order by location, date;

-- Creating views to store data for later visualisations in Tableau
-- Population infected count

create view `covid19-392218.Coviddata.PopulationInfected` as
select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from `covid19-392218.Coviddata.CovidDeaths`
where continent is not null 
group by Location, Population
order by PercentPopulationInfected desc

-- Death count per country

create view `covid19-392218.Coviddata.PopulationDeathCount` as
select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from `covid19-392218.Coviddata.CovidDeaths`
where continent is not null 
group by Location
order by TotalDeathCount desc

-- Death count per continent
create view `covid19-392218.Coviddata.ContinentDeathCount` as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from `covid19-392218.Coviddata.CovidDeaths`
where continent is null 
group by location
order by TotalDeathCount desc

-- Global death percentage per day

create view `covid19-392218.Coviddata.GlobalDeathPercentage` as
select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from `covid19-392218.Coviddata.CovidDeaths`
where continent is not null 
group By date
order by 1,2

-- The percent of population that has recieved at least one vaccine

create view `covid19-392218.Coviddata.PopulationVaccinated` as
select continent, location, date, population, new_vaccinations,
  SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingCountVaccination,
  (SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) / population) * 100 AS PercentageVaccinated
from (
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  from `covid19-392218.Coviddata.CovidDeaths` dea
  join `covid19-392218.Coviddata.CovidVaccinations` vac
    ON dea.location = vac.location
    and dea.date = vac.date
  where dea.continent is not null
) subquery
order by 2, 3;
