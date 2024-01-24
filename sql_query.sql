SELECT *
FROM CovidDataset..CovidDeaths
where continent is not null
order by 3,4



SELECT *
FROM CovidDataset..CovidVaccinations
order by 3,4



--Select required data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDataset..CovidDeaths
order by 1,2



--Looking at Total Cases vs Total Deaths
--Show the likelihoof of dying if you contract convid in specific country
SELECT Location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18, 5), total_deaths) / CONVERT(DECIMAL(18, 5), total_cases)))*100 as [DeathsOverTotal]
FROM CovidDataset..CovidDeaths
Where location like 'Australia'
order by 1,2



--Looking at Total Cases vs Population
Show what percentage of population got Covid
SELECT Location, date, Population, total_cases, (CONVERT(DECIMAL(18, 5), total_cases) / CONVERT(DECIMAL(18, 5), Population))*100 as [PercentPopulationInfected]
FROM CovidDataset..CovidDeaths
Where location like 'Australia'
order by 1,2



----Looking at the country with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(DECIMAL(18, 5), total_cases) / CONVERT(DECIMAL(18, 5), Population))*100 as [PercentPopulationInfected]
FROM CovidDataset..CovidDeaths
--Where location like 'Australia'
Group by location, population
order by [PercentPopulationInfected] desc



----Break the queries down by continent
SELECT continent, MAX(cast(total_deaths as int)) as [TotalDeathCount]
FROM CovidDataset..CovidDeaths
--Where location like 'Australia'
Where continent is not null
Group by continent
order by TotalDeathCount desc



----Show the country with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as [TotalDeathCount]
FROM CovidDataset..CovidDeaths
--Where location like 'Australia'
Where continent is null
Group by continent
order by TotalDeathCount desc



----Show the continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as [TotalDeathCount]
FROM CovidDataset..CovidDeaths
--Where location like 'Australia'
Where continent is not null
Group by continent
order by TotalDeathCount desc



---- DeathPercentage of global
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDataset..CovidDeaths
--Where location like 'Australia'
where continent is not null
--Group by date
order by 1,2




-- Looking at Total Population vs Vaccinations
---- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From CovidDataset..CovidVaccinations vac
Join CovidDataset..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



----CreateTemp Table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
From CovidDataset..CovidVaccinations vac
Join CovidDataset..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Create view to store data for later visualization
Use CovidDataset
GO
Create View PercentageOfThePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataset..CovidVaccinations vac
Join CovidDataset..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null