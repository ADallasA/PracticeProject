Select *
From PracticePortfolio..CovidDeaths$
order by 3,4

--Select *
--From PracticePortfolio..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PracticePortfolio..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PracticePortfolio..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs population
--shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PracticePortfolio..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PracticePortfolio..CovidDeaths$
--Where location like '%states%'
Group by location, Population
order by PercentPopulationInfected desc

--Showing countries with the Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PracticePortfolio..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Broken down by continent



Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PracticePortfolio..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_Deaths as int))/SUM(New_Cases)*100--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PracticePortfolio..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2


--Joining tables on date and location

Select *
From PracticePortfolio..CovidDeaths$ dea
Join PracticePortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

	--Looking at total population VS vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PracticePortfolio..CovidDeaths$ dea
Join PracticePortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

--USE CTE

With PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PracticePortfolio..CovidDeaths$ dea
Join PracticePortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac

--USE TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PracticePortfolio..CovidDeaths$ dea
Join PracticePortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated


--Creating View to store dta for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PracticePortfolio..CovidDeaths$ dea
Join PracticePortfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated