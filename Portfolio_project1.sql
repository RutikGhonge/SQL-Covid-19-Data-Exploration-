/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



--USE PortfolioProject;
SELECT * 
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
ORDER BY 3,4


-- Select Data that we are going to be starting with

SELECT location, date, total_cases,new_cases, total_deaths , population 
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
ORDER BY 1,2



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT   location, 
         date, 
		 total_cases,  
		 total_deaths , 
		 (total_deaths/ total_cases)*100  as Death_Percentage
FROM PortfolioProject..CovidDeaths
where location like '%india%'
and continent IS NOT NULL
ORDER BY 1,2




-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT   location, 
         date, 
		 population , 
		 total_cases, 
		 (total_deaths/ population)*100  as Percentage_Population_Infected
FROM PortfolioProject..CovidDeaths
where location like '%India%'
and continent IS NOT NULL
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population
SELECT   location,  
		 population , 
		 max(total_cases) as Highest_Infection_Count,   
		 max((total_deaths/ population)*100)  as Percentage_Population_Infected
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by location,population
ORDER BY Percentage_Population_Infected DESC


-- Countries with Highest Death Count per Population

SELECT  location,  
		 max(cast(total_deaths as INT)) as Total_Death_Count  
		  
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by location 
ORDER BY Total_Death_Count DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


SELECT  continent,  
		 max(cast(total_deaths as INT)) as Total_Death_Count  
		  
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by continent 
ORDER BY Total_Death_Count DESC


-- GLOBAL NUMBERS
-- Total New cases and New Deaths on a Particular Date in All Countries(Location)
SELECT   date,
		 sum(new_cases) as Total_cases,
		 SUM(cast(new_deaths as int)) as Total_Deaths,
		 SUM(cast(new_deaths as int))/sum(new_cases) *100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total cases deaths and deaths Percentage of Whole World
-- TOTAL GLOBAL CASES
SELECT   SUM(new_cases) as Total_cases,
		 SUM(cast(new_deaths as int)) as Total_Deaths,
		 SUM(cast(new_deaths as int))/sum(new_cases) *100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- VACCINATION DATA OF THE COUNTRIES

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_People_Vaccinated


FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location and
	   dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER by 1,2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH	PopvsVac(Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as

(SELECT dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_People_Vaccinated


FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location and
	   dea.date=vac.date
WHERE dea.continent IS NOT NULL
)

Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac





-- Using Temp Table to perform Calculation on Partition By in previous que
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccination NUMERIC,
Rolling_People_Vaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_People_Vaccinated


FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location and
	   dea.date=vac.date

Select *, (Rolling_People_Vaccinated/Population)*100
From #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
(
SELECT dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_People_Vaccinated


FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location=vac.location and
	   dea.date=vac.date
WHERE dea.continent IS NOT NULL
)



--  Now we can use as table
SELECT *
FROM PercentPopulationVaccinated