# Overview

Welcome to my SQL and Power BI COVID-19 dashboard project. In this project I wanted to practice and showcase my ability to visualize data utilizing different software and create a functioning dashboard. I sourced this data from Our World In Data.

# The Goal

To create and display a functioning dashboard visualizing numerical, geographical, and percentage data concerning the COVID-19 pandemic.  

# Tools I Used

To complete this project, I utilized several key skills:

* SQL: The main tool I used for cleaning and working with the data for this project. This allowed me to prepare data for visualization, as well as create views to allow for ease of use.
    * I used PostgreSQL for this project through PGAdmin4.
* Microsoft PowerBI: This tool was of critical use for this project as my main tool for creating visualizations and displaying those visualizations in a dashboard. 
* Microsoft Excel: I used this for quickly separating the data into two different databases.
* Visual Studio Code: My default code editor and interface for utilizing Git & GitHub
* Git & Github: Essential for version control and sharing my SQL and auxiliary files.

# Data Investigation
This section shows some examples of initial investigation done into the data set. 

```sql

-- Initial look at data provided
select * from coviddeaths
where continent is not null
fetch first 10 row only
order by 3, 4;

-- Looking at Total Cases vs Population
-- This shows what percentage of population has gotten Covid
	
select location, date, population, total_cases, (total_cases::float/population::float)*100 as Cases_by_population
from coviddeaths
where location like '%States%'
And continent is not null
order by 1,2;

-- Looking for which continent had the highest number of deceased according to population size.

select continent, Max(total_deaths) as total_death_count, Max((total_deaths::float/population::float)*100) as percent_of_population_killed
from coviddeaths
where total_deaths is not null
And continent is not null
group by continent
order by percent_of_population_killed desc;

-- Utilizing  a CTE to create a rolling percentage of population vaccinated column 

with pop_vs_vac (continent, location, date, population,new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by  dea.location, dea.date)
	as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
select *, (rolling_people_vaccinated::float/population::float)*100
from pop_vs_vac;

```

# Data Preparation
This section shows examples of how data was prepared in order to easily visualize once imported into MS PowerBI.

```sql

--Creating a percentage population vaccinated view
	
create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by  dea.location, dea.date)
	as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--Creating a view to show the percent of the population infected by any given date. 

create view percent_population_infected_with_date as 
select location, population,date, max(total_cases) as highest_infection_count,  max((total_cases::float/population::float))*100 as percent_population_infected
from coviddeaths
group by location, population, date
order by percent_population_infected desc;

```

# Final Visualization 
This is the final dashboard showing the visualizations of the various views created. 

![PowerBI Dashboard](Covid-Data-Project\BI_Dashboard.png)
