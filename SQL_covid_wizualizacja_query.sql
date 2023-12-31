USE Covid

-- Pisanie query do wizualizacji w Power BI (Modyfikacja zapyta� b�dzie r�wnie� zachodzi� w Power Query)

SELECT *
FROM ProcentPopulacjiZaszczepionyW


-- Procent ludzi, kt�rzy umarli na �wiecie na Covida
SELECT
	SUM(CONVERT(float,new_cases)) AS Wszystkie_przypadki,
	SUM(CONVERT(float,new_deaths)) AS Wszystkie_�mierci,
	SUM(CONVERT(float,new_deaths)) / SUM(CONVERT(float,new_cases)) * 100 AS Procent_�mierci
FROM CovidDeath



-- Ilo�� ludzi, kt�ra zmar�a w poszczeg�lnych kontynentach

SELECT
	location,
	SUM(CONVERT(float,new_deaths)) AS Wszystkie_�mierci
FROM CovidDeath
WHERE location NOT IN ('World', 'European Union', 'International', 'Upper','Upper middle income','Low income','Lower middle income','High income') -- UE jest cz�ci� Europy
AND continent = ''
GROUP BY location
ORDER BY Wszystkie_�mierci DESC


-- Procent populacji zaka�ony COVID 19

SELECT
	location,
	population,
	MAX(total_cases) AS Ilo��_os�b_zaka�onych,
	MAX((total_cases)/population) * 100 AS Procent_zaka�onych
FROM CovidDeath
WHERE location LIKE '%States'
GROUP BY location, population
ORDER BY Procent_zaka�onych DESC

-- Procent populacji zaka�ony covidem, dzie� po dniu

SELECT
	location,
	population,
	date,
	MAX(total_cases) AS Ilo��_os�b_zaka�onych,
	MAX((total_cases)/population)*100 AS Procent_zaka�onych
FROM CovidDeath
GROUP BY location, population, date
ORDER BY Procent_zaka�onych DESC

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
-- Procent �mierci w podziale na kraje
SELECT 
	location,
	population,
	MAX(CONVERT(float, total_deaths)) AS Ilosc_smierci,
	MAX(CONVERT(float, total_deaths)) / (population) AS Procent_smierci
FROM CovidDeath
GROUP BY location,population
ORDER BY Procent_smierci DESC

--Ilo�� zachorowa� + ilo�� zaszczepionych w podziale na lokacje

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









