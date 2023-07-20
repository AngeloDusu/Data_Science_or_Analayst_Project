-- in many part i cant use cast or convert to integer so i use decimal and make percentage
-- i cant cast the total_deaths to int so i use decimal 
-- still my first project ever so idk if its right or no :)

SELECT *
FROM PortProject1..CovidDeaths
order by 3,4

--SELECT *
--FROM PortProject1..CovidVactinations
--order by 3,4

-- Select data that i will going to use

SELECT location, total_cases, new_cases, total_deaths, population
FROM PortProject1..CovidDeaths
order by 1,2

-- looking at total case vs total deaths

Select Location, date, 
	CONVERT(DECIMAL(15,3), total_cases) as total_cases,
	CONVERT(DECIMAL(15,3), total_deaths) as total_death, 
	CONVERT(DECIMAL(15,3), (CONVERT(DECIMAL(15,3), total_cases) / CONVERT(DECIMAL(15,3), total_deaths)))*100  as deathpercentage

From PortProject1..CovidDeaths
Where location = 'Indonesia'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid

Select Location, date,
	CONVERT(DECIMAL(15,3), total_cases) as total_cases,
	CONVERT(DECIMAL(15,3), population) as population, 
	CONVERT(DECIMAL(15,3), (CONVERT(DECIMAL(15,3), total_cases) / CONVERT(DECIMAL(15,3), population)))*100  as pplinfected_percentage

From PortProject1..CovidDeaths
-- Where location = 'Indonesia'
order by 1,2


-- looking at countries at highest infection rate compared to population

Select Location,
	CONVERT(DECIMAL(15,3), MAX(total_cases)) as HighestInfectionCount,
	CONVERT(DECIMAL(15,3), population) as population, 
	CONVERT(DECIMAL(15,3), MAX((CONVERT(DECIMAL(15,3), total_cases) / CONVERT(DECIMAL(15,3), population))))*100  as PercentPopulationInfected

From PortProject1..CovidDeaths
-- Where location = 'China'
Group By location, population
Order By PercentPopulationInfected desc

-- showing countries with highest death count per population
-- i cant cast the total_deaths to int so i use decimal 
-- still my first project ever so idk if its right or no :)

Select Location, MAX(CONVERT(decimal, total_deaths)) as TotalDeathCount
From PortProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAK THINGS DOWN BY CONTINENT

-- showing the continent with the highest deaths

Select continent, MAX(CONVERT(decimal, total_deaths)) as TotalDeathCount
From PortProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- global number

-- GLOBAL NUMBERS

Select SUM(convert(decimal, new_cases)) as total_cases, SUM(convert(decimal, new_deaths )) as total_deaths, SUM(convert(decimal,new_deaths))/SUM(convert(decimal, New_Cases))*100 as DeathPercentage
From PortProject1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- total population vs vactinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortProject1..CovidDeaths dea
Join PortProject1..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortProject1..CovidDeaths dea
Join PortProject1..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- using Temp Table

DROP table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortProject1..CovidDeaths dea
Join PortProject1..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- creating view for store data for later visual

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortProject1..CovidDeaths dea
Join PortProject1..CovidVactinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3

SELECT *
FROM PercentPopulationVaccinated