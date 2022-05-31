/*
Data Exploration using COVID-19 information from Jan 2020-Present (May 2022)

Utilized: Joins, conversion of data types (Cast, Convert functions), CTE's,
Aggregate Functions, creating views for later data visualization

Data retrieved from Our World in Data, URL = https://ourworldindata.org/covid-deaths
*/

SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent <> ' '
ORDER BY 3,4

--Select Data starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country 
-- (specifically United States in below query)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows percentage of population that has contracted COVID-19 during any point between 2020-Present

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent <> ' '
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Continents with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent = ' '
AND location <> 'World'
AND location <> 'Upper middle income'
AND location <> 'High income'
AND location <> 'Lower middle income'
AND location <> 'European Union'
AND location <> 'Low income'
AND location <> 'International'
GROUP BY location
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS
-- Daily view of new cases, new deaths related to COVID-19, and Percentage of new cases
-- resulting in death

SELECT date, SUM(new_cases) as SumNewCases
, SUM(cast(new_deaths as int)) as SumNewDeaths
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent <> ' ' 
GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations by Country/Date
-- Shows Percentage of Population that has received at least one COVID vaccination
-- Using CTE to perform calculation on Partition By

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccines vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent <> ' '
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac


-- Creating Views for later data visualizations

-- Percent of the Population Vaccinated

Create View PercentPopulationVaccinated as
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccines vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent <> ' '
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac

Select *
From PercentPopulationVaccinated

--Death Count per Continent

Create View DeathCountByContinent as
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent = ' '
AND location <> 'World'
AND location <> 'Upper middle income'
AND location <> 'High income'
AND location <> 'Lower middle income'
AND location <> 'European Union'
AND location <> 'Low income'
AND location <> 'International'
GROUP BY location


-- Death Count per Country

Create View DeathCountByCountry as
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent <> ' '
GROUP BY Location

-- Daily View of New Cases, New Deaths, and Percentage of new cases resulting in death

Create View GlobalNewCasesAndDeaths as
SELECT date, SUM(new_cases) as SumNewCases
, SUM(cast(new_deaths as int)) as SumNewDeaths
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent <> ' ' 
GROUP BY date
