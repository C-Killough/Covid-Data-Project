select * from coviddeaths
where continent is not null
order by 3, 4

	
--Select Data I'm going to be using

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2;

-- Looking at Total cases vs Total Deaths
-- Shows the liklihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths::float/total_cases::float)*100 as DeathPercentage
from coviddeaths
where location like '%States%'
And continent is not null
order by 1,2;


-- Looking at Total Cases vs Population
-- shows what percentage of population has got Covid
	
select location, date, population, total_cases, (total_cases::float/population::float)*100 as Cases_by_population
from coviddeaths
where location like '%States%'
And continent is not null
order by 1,2;

-- Finding countries with the highest infection rates

select location, population, Max(total_cases) as highest_infection_count, Max((total_cases::float/population::float)*100) as percent_of_population_infected
from coviddeaths
where total_cases is not null
And continent is not null
group by location, population
order by percent_of_population_infected desc;


-- showing the countries with the highest death count per population

select location, Max(total_deaths) as highest_death_count, Max((total_deaths::float/population::float)*100) as percent_of_population_killed
from coviddeaths
where total_deaths is not null
And continent is not null
group by location
order by percent_of_population_killed desc;


-- checking continents as well

select continent, Max(total_deaths) as total_death_count, Max((total_deaths::float/population::float)*100) as percent_of_population_killed
from coviddeaths
where total_deaths is not null
And continent is not null
group by continent
order by percent_of_population_killed desc;

-- Global Numbers

select sum(new_cases) as total_cases,
	sum(new_deaths) as total_deaths, 
	((Sum(new_cases))::float)/ ((sum(new_deaths)::float)*100) 
	as DeathPercentage
from coviddeaths
where continent is not null
order by 1,2;

--total population vs vaccinations


-- USE CTE

with pop_vs_vac (continent, location, date, population,new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by  dea.location, dea.date)
	as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2 ,3
)
select *, (rolling_people_vaccinated::float/population::float)*100
from pop_vs_vac

-- Temp Table

drop table if exists percent_population_vaccinated
create temporary table percent_population_vaccinated
(
	continent text,
	location text,
	date date,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
);
	
insert into percent_population_vaccinated(
select dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by  dea.location, dea.date)
	as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
);


	
Select *, (rolling_people_vaccinated/population) * 100
from percent_population_vaccinated


-- creating views to store data for later visualizations

create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by  dea.location, dea.date)
	as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3