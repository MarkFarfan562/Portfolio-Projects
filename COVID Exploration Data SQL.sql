Select*
From Portfolio_Project..CovidDeaths
Where continent is not null
order by 3,4

Select*
From Portfolio_Project..CovidVaccinations
Where continent is not null
order by 3,4

--Data we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs. Total Deaths
-- Shows likeliehood of dying  if you contract COVID in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From Portfolio_Project..CovidDeaths
Where location like '%mexico%'
order by 1,2


-- Looking at Total cases vs. population
-- Shows what percentage of population got COVID

Select Location, date,  population, total_cases, (total_cases/population)*100 as Percent_population_infected
From Portfolio_Project..CovidDeaths
Where location like '%mexico%'
order by 1,2


--Looking at countries with highest infected rate compared to population


Select Location, population, MAX(total_cases) as highest_infected_count, MAX((total_cases/population))*100 as Percent_population_infected
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by location, population 
order by Percent_population_infected desc

--Showing countries with Highest Death Count per population


Select Location, MAX(cast(Total_deaths as int)) as Total_Death_count
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by location, population 
order by Total_Death_count desc


-- Lets check by continent

-- SHowing Continent with highest death count per population
Select location, MAX(cast(Total_deaths as int)) as Total_Death_count
From Portfolio_Project..CovidDeaths
Where continent is null
Group by location
order by Total_Death_count desc


-- Global Numbers by date

Select date, Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/ Sum(new_cases)*100 as Death_percentage
From Portfolio_Project..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- Global numbers

Select  Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/ Sum(new_cases)*100 as Death_percentage
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Looking at rolling vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vaccinations 
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations 
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *,  (Rolling_Vaccinations/population)*100
From PopvsVac


--Temp Table
Drop Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_vaccinations numeric)


Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations 
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *,  (Rolling_Vaccinations/population)*100
From #PercentpopulationVaccinated


-- Creating view to store date for later visualizations

Create view PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations 
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
From PercentpopulationVaccinated