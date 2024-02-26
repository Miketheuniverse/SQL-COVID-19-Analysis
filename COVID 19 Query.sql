-- 1) Total Cases vs Total Deaths -- Mortality Rate
SELECT location AS [Location],
SUM(CAST(new_cases AS FLOAT)) AS [Total Cases],
SUM(CAST(new_deaths AS FLOAT)) AS [Total Deaths],
ROUND(SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0) * 100, 2) AS [Death Percentage]
FROM Covid19Data
WHERE Continent IS NOT NULL AND [total_cases] IS NOT NULL
GROUP BY location
ORDER BY [Death Percentage] desc;


-- 2) Percentage of Country Population that got COVID and Country with Highest Infection Rate
SELECT location AS [Location], SUM(new_cases) as [TOTAL CASES],population,
MAX(ROUND(CAST(total_cases AS FLOAT) * 1.0 /population * 100,2)) as [Percent of Population Infected]
FROM Covid19Data
WHERE Continent is not NULL
group by location, population
order by MAX(ROUND(CAST(total_cases AS FLOAT) * 1.0 /population * 100,2)) DESC

-- 3) Country with the highest death rate per population
SELECT location, population, 
MAX(total_deaths) as hightestDeathCount, 
MAX(ROUND(CAST (total_deaths AS FLOAT) * 1.0/population*100, 2)) as PercentPopulationDied
FROM Covid19Data
WHERE Continent is not NULL AND [total_cases] IS NOT NULL
Group by location, population
order by 4 desc

--4) What country has the highest death count
SELECT location,
SUM(CAST (new_deaths AS FLOAT)) as [Highest Death Count]
FROM Covid19Data
WHERE CONTINENT IS NOT NULL 
GROUP BY location
ORDER BY SUM(CAST (new_deaths AS FLOAT)) DESC;

--5)Continent with Highest Death Count
SELECT continent, SUM(new_deaths) as [Highest Death Count by Continent]
FROM Covid19Data
WHERE CONTINENT IS NOT NULL 
Group by continent
order by SUM(new_deaths) desc

--6) Global Cases for each day
SELECT date, SUM(new_cases) as [Total New Cases], SUM(new_deaths) as [Total New Deaths], 
ROUND(
CASE WHEN 
SUM(new_cases) <> 0 THEN SUM(new_deaths)*1.0/SUM(new_cases)*100 
ELSE NULL
END,3) AS death_rate
FROM Covid19Data
WHERE Continent is not NULL
GROUP BY DATE
Order by date 


--7) Rolling count of people vaccinated
SELECT CD.continent, CD.location, CD.date, v.daily_vaccinations,
SUM(CAST(V.daily_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY cd.Date) as [Rolling Count of Vaccinated]
FROM Covid19Data AS CD
INNER JOIN Vaccinations as V ON CD.location = V.location and CD.date = V.date
order by cd.location, cd.date

-- 8) What is the rolling count of people vaccinated, meaning after each day what is the total number of vaccinated people
-- using CTE
WITH PopulationandVaccinated (continent, location, date, population, [Rolling Count of Vaccinated])
AS (
SELECT CD.continent, CD.location, CD.date,CD.population,
SUM(CAST(V.daily_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.Date) as [Rolling Count of Vaccinated]
FROM Covid19Data AS CD
INNER JOIN Vaccinations as V ON CD.location = V.location and CD.date = V.date
WHERE CD.continent IS NOT NULL
)

SELECT *, ([Rolling Count of Vaccinated]/population)*100 as PercentPopulationVaccinated
FROM PopulationandVaccinated

--9) Rolling count of people vaccinated using temporary table
DROP TABLE IF EXISTS #PopulationandVaccinated

SELECT CD.continent, CD.location, CD.date,CD.population,
SUM(CAST(V.daily_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.Date) as [Rolling Count of Vaccinated]
INTO #PopulationandVaccinated
FROM Covid19Data AS CD
INNER JOIN Vaccinations as V ON CD.location = V.location and CD.date = V.date
WHERE CD.continent IS NOT NULL


SELECT *, ([Rolling Count of Vaccinated]/population)*100 as PercentPopulationVaccinated
FROM #PopulationandVaccinated

DROP TABLE IF EXISTS #PopulationandVaccinated

