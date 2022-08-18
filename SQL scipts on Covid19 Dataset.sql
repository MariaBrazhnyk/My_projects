Select * 
from PortfolioProject..CovidDeath
where continent is not null
order by 3,4

--Select * 
--from PortfolioProject..CovidVaccination
--order by 3,4

Select	location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		population
from PortfolioProject..CovidDeath
where continent is not null
order by 1, 2

UPDATE PortfolioProject..CovidDeath
SET total_deaths = NULLIF(total_deaths, ''),
	total_cases = NULLIF(total_cases, ''),
	population = NULLIF(population, ''),
	continent = NULLIF(continent, ''),
	new_cases = NULLIF(new_cases, ''),
	new_deaths = NULLIF(new_deaths, '')


--Want to know percentage of death cases in my country

Select	location, 
		date, 
		total_cases, 
		total_deaths, 
		(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location = 'Ukraine' and
	continent is not null
order by 1, 2

-- Want to know total cases/population

Select	location, 
		date, 
		total_cases, 
		population, 
		(cast(total_cases as float)/cast(population as float))*100 as CasesPercentage
from PortfolioProject..CovidDeath
--where location = 'Ukraine'
where continent is not null
order by 1, 2

-- Countries with Highest Infection Rate compared to Population

Select	location, 
		population,
		Max(total_cases) as HighestInfectionCount,
		max(cast(total_cases as float)/cast(population as float))*100 as CasesPercentage
from PortfolioProject..CovidDeath
--where location = 'Ukraine'
where continent is not null
group by location, population
order by CasesPercentage desc

-- Countries with Highest Death Count per Population

Select	location, max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location = 'Ukraine'
where continent is not null
group by location
order by TotalDeathCount desc

-- Continents with highest death per population

Select	continent, max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location = 'Ukraine'
where continent is not null
group by continent
order by TotalDeathCount desc 

-- Global Numbers

Select	sum(cast(new_cases as float)) as total_cases, 
		sum(cast(new_deaths as float)) as total_deaths,
		sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeath
--where location = 'Ukraine' and
where continent is not null
--group by date 
order by 1, 2 


UPDATE PortfolioProject..CovidVaccination
SET new_vaccinations = NULLIF(new_vaccinations, '')


-- Total Population vs Vaccinations

select	dea.continent, 
		dea.location, 
		dea.date, 
		population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
		from PortfolioProject..CovidDeath dea
	join PortfolioProject..CovidVaccination vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select	dea.continent, dea.location, dea.date, population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

-- Temp table

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select	dea.continent, 
		dea.location, 
		dea.date, 
		population,
		vac.new_vaccinations, 
		sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating view

Create view PercentPopulationVaccinated as
select	dea.continent, 
		dea.location, 
		dea.date, 
		population,
		vac.new_vaccinations, 
		sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated