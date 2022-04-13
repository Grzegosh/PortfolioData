USE Covid

-- Pisanie query do wizualizacji w Power BI (Modyfikacja zapytaæ bêdzie równie¿ zachodziæ w Power Query)

SELECT *
FROM ProcentPopulacjiZaszczepionyW


-- Procent ludzi, którzy umarli na œwiecie na Covida
SELECT
	SUM(CONVERT(float,new_cases)) AS Wszystkie_przypadki,
	SUM(CONVERT(float,new_deaths)) AS Wszystkie_œmierci,
	SUM(CONVERT(float,new_deaths)) / SUM(CONVERT(float,new_cases)) * 100 AS Procent_œmierci
FROM CovidDeath



-- Iloœæ ludzi, która zmar³a w poszczególnych kontynentach

SELECT
	location,
	SUM(CONVERT(float,new_deaths)) AS Wszystkie_œmierci
FROM CovidDeath
WHERE location NOT IN ('World', 'European Union', 'International', 'Upper','Upper middle income','Low income','Lower middle income','High income') -- UE jest czêœci¹ Europy
AND continent = ''
GROUP BY location
ORDER BY Wszystkie_œmierci DESC


-- Procent populacji zaka¿ony COVID 19

SELECT
	location,
	population,
	MAX(total_cases) AS Iloœæ_osób_zaka¿onych,
	MAX((total_cases)/population) * 100 AS Procent_zaka¿onych
FROM CovidDeath
WHERE location LIKE '%States'
GROUP BY location, population
ORDER BY Procent_zaka¿onych DESC

-- Procent populacji zaka¿ony covidem, dzieñ po dniu

SELECT
	location,
	population,
	date,
	MAX(total_cases) AS Iloœæ_osób_zaka¿onych,
	MAX((total_cases)/population)*100 AS Procent_zaka¿onych
FROM CovidDeath
GROUP BY location, population, date
ORDER BY Procent_zaka¿onych DESC

-- Wszystkie przypadki
SELECT
	location,
	MAX(total_cases) AS Przypadki
FROM CovidDeath
GROUP BY location
ORDER BY Przypadki DESC

-- Dzienne przypadki
SELECT location,
	date,
	new_cases
FROM CovidDeath
-- Procent œmierci w podziale na kraje
SELECT 
	location,
	population,
	MAX(CONVERT(float, total_deaths)) AS Ilosc_smierci,
	MAX(CONVERT(float, total_deaths)) / (population) AS Procent_smierci
FROM CovidDeath
GROUP BY location,population
ORDER BY Procent_smierci DESC

--Iloœæ zachorowañ + iloœæ zaszczepionych w podziale na lokacje

SELECT 
	a.location,
	a.date,
	a.new_cases,
	b.new_vaccinations
FROM CovidDeath a
JOIN CovidVacc b
ON a.location = b.location AND a.date = b.date
GROUP BY a.location, a.date, a.new_cases, b.new_vaccinations
ORDER BY a.date DESC;









