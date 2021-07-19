/*
Daniel Simons

Within this file is a variety of data exploration from 'ourworldindata.org' on the COVID-19 pandemic to date. 
Skills used include; Joins, Temp Tables, Creating Views, Converting Data Types, Windows & Aggregate Functions and CTE's.

*/



Select *
From Portfolio_Project..[covid-data-deaths]
Where continent is not null
order by 3,4

--Select *
--From Portfolio_Project..[covid-data-vaccinations]
--order by 3,4

--Confirming both data sets have been imported correctly, now only displaying the first data set.

--Henceforth selecting data I will be using.

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..[covid-data-deaths]
order by 1,2

--Comparison of Total Cases to Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Percentage of deaths from cases'
From Portfolio_Project..[covid-data-deaths]

--Identifies statistics for the UK as searched for easilly with the term kingdom for comparison between countries etc...
where location like '%kingdom%'
order by 1,2

--Comparison of total cases to population
Select Location, date, total_cases,population, (total_cases/population)*100 as 'Percentage of population who has contracted COVID'
From Portfolio_Project..[covid-data-deaths]
where location like '%kingdom%'
order by 1,2

--Comparison of countries with the highest infection rate to population
Select Location, population, MAX(total_cases) as 'Total infection count', MAX((total_cases/population))*100 as PopInfectedToDate
From Portfolio_Project..[covid-data-deaths]
Group by population, location
order by PopInfectedToDate desc --Ordered by largest to smallest, Clear to see Andora has the highest ratio.

--Analysis of countries with the highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotDeathCount
From Portfolio_Project..[covid-data-deaths]
Where continent is not null
Group by population, location
order by TotDeathCount desc

--This data set includes larger groupings for location such as continents and the world and hence they present the highest total death count. Introducing a condition in which the continent column is not null mitigates this problem and can be added to each of the above queries.
--Currently this results in the united states being first in the total death count in comparison to the entirity of the world as before.

--Breaking things down by continent and larger groupings
Select location, MAX(cast(Total_deaths as int)) as TotDeathCount
From Portfolio_Project..[covid-data-deaths]
Where continent is null
Group by location
order by TotDeathCount desc


--Presenting continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotDeathCount
From Portfolio_Project..[covid-data-deaths]
Where continent is not null
Group by continent
order by TotDeathCount desc


--Breakdown of global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageDeaths 
--new_deaths classed as an nvarchar rather than float and therefore needs to be cast as an integer.
From Portfolio_Project..[covid-data-deaths]
--where location like '%kingdom%'
where continent is not null
Group by date
order by 1,2




--Total population vs Vaccinations

--Using CTE (Number of columns must be equal in each, else error in PopvsVac)
With PopvsVac (Continent, location, date, population,new_vaccinations, CollectiveVaccinations)
as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CollectiveVaccinations
From Portfolio_Project..[covid-data-deaths] dea
Join Portfolio_Project..[covid-data-vaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (CollectiveVaccinations/population)*100
From PopvsVac




-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric, 
New_vaccinations numeric, 
CollectiveVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CollectiveVaccinations
From Portfolio_Project..[covid-data-deaths] dea
Join Portfolio_Project..[covid-data-vaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (CollectiveVaccinations/population)*100
From #PercentPopulationVaccinated




--Creating View storing data for visualisations
Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as CollectiveVaccinations
From Portfolio_Project..[covid-data-deaths] dea
Join Portfolio_Project..[covid-data-vaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
