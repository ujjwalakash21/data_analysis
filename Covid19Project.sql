/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From [dbo].[CovidDeath]
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [dbo].[CovidDeath]
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].[CovidDeath]
Where location like '%India%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [dbo].[CovidDeath]
--Where location like '%India%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [dbo].[CovidDeath]
--Where location like '%India%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeath]
--Where location like '%India%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeath]
--Where location like '%India%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM((new_cases)), SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/SUM((new_cases))*100 AS DeathPercentage
From [dbo].[CovidDeath]
--- Where location like '%India%'
WHERE continent is not null 
---GROUP BY date
order by 1,2

---looking at total polulation vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CAST(vac.new_vaccinations as int)) over (partition by dea.location)
FROM[dbo].[CovidDeath] dea 
JOIN [dbo].[CovidVaccination] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

---use cte

with PopvsVac (continent,location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
---order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

