--Zbi�r danych dost�pny pod :
-- https://ourworldindata.org/covid-deaths 

CREATE DATABASE Covid

USE Covid


-- Eksploracja danych;
SELECT *
FROM CovidDeath
WHERE continent = ''

SELECT *
FROM CovidDeath;


-- Wybieramy dane, kt�re b�dziemy wykorzystywa�;

SELECT
	date,
	location,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeath
ORDER BY date, location

-- Wszystkie przypadki zachorowa� vs wszystkie �mierci w Polsce


SELECT
	date,
	location,
	total_cases,
	total_deaths,
	ROUND((total_deaths/total_cases)*100,3) AS '% �mierci'
FROM CovidDeath
WHERE location = 'Poland'
ORDER BY location, date ; -- Na dzie� 09.04.2022 'total cases' zgadza sie z wartosci� podawan� przez Google



-- Wszystkie przypadki zachorowa� vs populacja

SELECT
	date,
	location,
	total_cases,
	population,
	ROUND((total_cases/population)*100,3) AS '% zara�onej populacji'
FROM CovidDeath
WHERE location = 'Poland'
ORDER BY location, date ; -- Na dzie� 09.04.2022 tylko 15,815% populacji by�o zaka�oncyh koronawirusem.


-- Pa�stwa z najwy�szym wsp�czynnikiem zachorowa� w stosunku do populacji

SELECT
	location,
	MAX(total_cases) AS 'Najwy�sza ilo�� zaka�e�',
	population,
	ROUND((MAX(total_cases)/population)*100,3) AS '% zara�onej populacji'
FROM CovidDeath
GROUP BY location, population
ORDER BY ROUND((MAX(total_cases)/population)*100,3) DESC;


-- Pa�stwa z najwi�kszym wsp�czynnikiem �miertelno�ci

SELECT
	location,
	MAX(total_deaths) AS 'Ilo�� �mierci',
	population,
	ROUND((MAX(CAST(total_deaths AS bigint))/population)*100,3) AS '% �mierci spowodowanej covidem'
FROM CovidDeath
GROUP BY location, population
ORDER BY ROUND((MAX(CAST(total_deaths AS bigint))/population)*100,3) DESC;


-- Upro��my analiz� na kontynenty


SELECT
	location,
	MAX(CAST(total_deaths AS bigint)) AS 'Ilo�� �mierci'
FROM CovidDeath
WHERE continent = ''
GROUP BY location
ORDER BY MAX(CAST(total_deaths AS bigint)) DESC;

-- Kontynenty z najwy�szym wsp�czynikiem �miertelno�ci


SELECT
	location,
	MAX(total_deaths) AS 'Ilo�� �mierci',
	population,
	ROUND((MAX(CAST(total_deaths AS bigint))/population)*100,3) AS '% �mierci spowodowanej covidem'
FROM CovidDeath
WHERE continent = ''
GROUP BY location, population
ORDER BY ROUND((MAX(CAST(total_deaths AS bigint))/population)*100,3) DESC;


-- Kontynenty z najwy�szym wsp�czynnikiem zachorowa� w stosunku do populacji


SELECT
	location,
	MAX(total_cases) AS 'Najwy�sza ilo�� zaka�e�',
	population,
	ROUND((MAX(total_cases)/population)*100,3) AS '% zara�onej populacji'
FROM CovidDeath
WHERE continent = ''
GROUP BY location, population
ORDER BY ROUND((MAX(total_cases)/population)*100,3) DESC;


-- Liczby w odwo�aniu do �wiata

SELECT 
	DATE,
	SUM(total_cases) AS 'Ilo�� os�b zaka�onych na �wiecie'
FROM CovidDeath
WHERE continent = ''
GROUP BY date
ORDER BY date DESC


-- Dzienne zachorowania oraz �mierci w podziale na dni oraz kontynenty
SELECT
	date,
	SUM(CAST(new_cases AS bigint)) AS 'Nowe przypadki',
	SUM(CAST(new_deaths AS bigint)) AS ' Nowe �mierci'
FROM CovidDeath
WHERE continent = ''
GROUP BY date;

-- Populacja vs osoby, kt�re si� zaszczepi�y
SELECT 
	a.continent, 
	a.location, 
	a.date,
	CONVERT(float,REPLACE(b.new_vaccinations,',','.')) AS 'Szczepienia'
FROM CovidDeath a
JOIN CovidVacc b
ON a.location = b.location
AND a.date = b.date
WHERE a.continent != ''
ORDER BY 1,2,3

-- Suma ruchoma nowych zaszczepie� dzie� po dniu

SELECT
	a.location,
	a.date,
	a.population,
	CONVERT(float,REPLACE(b.new_vaccinations,',','.')) AS 'Szczepienia',
	SUM(CONVERT(float,REPLACE(b.new_vaccinations,',','.'))) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS 'Suma ruchoma'
FROM CovidDeath a
JOIN CovidVacc b
ON a.location = b.location
AND a.date = b.date
ORDER BY 1,2


-- CTE (* liczy r�wnie� ludzi, kt�rzy si� szczepili kilka razy)


WITH popszcz (location, date, population, new_vaccinations, Suma_ruchoma)
as
(
SELECT
	a.location,
	a.date,
	a.population,
	CONVERT(float,REPLACE(b.new_vaccinations,',','.')) AS 'Szczepienia',
	SUM(CONVERT(float,REPLACE(b.new_vaccinations,',','.'))) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS Suma_ruchoma
FROM CovidDeath a
JOIN CovidVacc b
ON a.location = b.location
AND a.date = b.date
)
SELECT *, (Suma_ruchoma/population)*100 AS 'Procent populacji'
FROM popszcz
ORDER BY 1,2

-- Tabela tymczasowa

CREATE TABLE ProcentPopulacjiZaszczepiony
(
Lokacja nvarchar(255),
Date datetime,
Populacja numeric,
Nowe_dawki numeric,
Suma_ruchoma numeric,
)

INSERT INTO ProcentPopulacjiZaszczepiony
SELECT
	a.location,
	a.date,
	a.population,
	CONVERT(float,REPLACE(b.new_vaccinations,',','.')) AS 'Szczepienia',
	SUM(CONVERT(float,REPLACE(b.new_vaccinations,',','.'))) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS 'Suma ruchoma'
FROM CovidDeath a
JOIN CovidVacc b
ON a.location = b.location
AND a.date = b.date
ORDER BY 1,2

SELECT *, ROUND((Suma_ruchoma/Populacja)*100,2) AS 'Procent populacji zaszczepiony'
FROM ProcentPopulacjiZaszczepiony


-- Tworzenie widoku

CREATE VIEW ProcentPopulacjiZaszczepionyW AS
SELECT
	a.location,
	a.date,
	a.population,
	CONVERT(float,REPLACE(b.new_vaccinations,',','.')) AS 'Szczepienia',
	SUM(CONVERT(float,REPLACE(b.new_vaccinations,',','.'))) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS 'Suma ruchoma'
FROM CovidDeath a
JOIN CovidVacc b
ON a.location = b.location
AND a.date = b.date


