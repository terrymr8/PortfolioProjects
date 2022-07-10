SELECT * FROM PortfolioProject..CovidDeaths Where continent is not null order by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the Likedlihood of dying if you contract COVID-19 in Africa 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location= 'Africa'
order by 1,2


--Looking at the total cases vs population
--Shows what % of population go Covid


Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location= 'Africa'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location= 'Africa'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing the continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location= 'Africa'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Want to calculate everything across the entire world
--Global Numbers

Select date SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location= 'Africa'	
where continent is not null
Group By date
Order By 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location= 'Africa'	
where continent is not null
--Group By date
Order By 1,2


--Looking at TOtal Population vs. Vaccinations
--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =  vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacciantions numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =  vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order By 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =  vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3


Select *
From PercentPopulationVaccinated