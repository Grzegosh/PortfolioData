--Zbiór danych dostêpny pod :
-- https://ourworldindata.org/covid-deaths 

CREATE DATABASE Covid

USE Covid


-- Eksploracja danych;
SELECT *
FROM CovidDeath
WHERE continent = ''

SELECT *
FROM CovidDeath;


-- Wybieramy dane, które bêdziemy wykorzystywaæ;

SELECT
	date,
	location,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeath
ORDER BY date, location

-- Wszystkie przypadki zachorowañ vs wszystkie œmierci w Polsce


SELECT
	date,
	location,
	total_cases,
	total_deaths,
	ROUND((total_deaths/total_cases)*100,3) AS '% œmierci'
FROM CovidDeath
WHERE location = 'Poland'
ORDER BY location, date ; -- Na dzieñ 09.04.2022 'total cases' zgadza sie z wartosci¹ podawan¹ przez Google



-- Wszystkie przypadki zachorowañ vs populacja

SELECT
	date,
	location,
	total_cases,
	population,
	ROUND((total_cases/population)*100,3) AS '% zara¿onej populacji'
FROM CovidDeath
WHERE location = 'Poland'
ORDER BY location, date ; -- Na dzieñ 09.04.2022 tylko 15,815% populacji by³o zaka¿oncyh koronawirusem.


-- Pañstwa z najwy¿szym wspó³czynnikiem zachorowañ w stosunku do populacji

SELECT
	location,
	MAX(total_cases) AS 'Najwy¿sza iloœæ zaka¿eñ',
	population,
	ROUND((MAX(total_cases)/population)*100,3) AS '% zara¿onej populacji'
FROM CovidDeath
GROUP BY location, population
ORDER BY ROUND((MAX(total_cases)/population)*100,3) DESC;


-- Pañstwa z najwiêkszym wspó³czynnikiem œmiertelnoœci

SELECT
	location,
	MAX(total_deaths) AS 'Iloœæ œmierci',
	population,
	ROUND((MAX(CAST(total_deaths AS bigint))/population)*100,3) AS '% œmierci spowodowanej covidem'
FROM CovidDeath
GROUP BY location, population
ORDER BY ROUND((MAX(CAST(total_deaths AS bigint))/population)*100,3) DESC;


-- Uproœæmy analizê na kontynenty


SELECT
	location,
	MAX(CAST(total_deaths AS bigint)) AS 'Iloœæ œmierci'
FROM CovidDeath
WHERE continent = ''
GROUP BY location
ORDER BY MAX(CAST(total_deaths AS bigint)) DESC;

-- Kontynenty z najwy¿szym wspó³czynikiem œmiertelnoœci


SELECT
	location,
	MAX(total_deaths) AS 'Iloœæ œmierci',
	population,
	ROUND((MAX(CAST(total_deaths AS bigint))/population)*100,3) AS '% œmierci spowodowanej covidem'
FROM CovidDeath
WHERE continent = ''
GROUP BY location, population
ORDER BY ROUND((MAX(CAST(total_deaths AS bigint))/population)*100,3) DESC;


-- Kontynenty z najwy¿szym wspó³czynnikiem zachorowañ w stosunku do populacji


SELECT
	location,
	MAX(total_cases) AS 'Najwy¿sza iloœæ zaka¿eñ',
	population,
	ROUND((MAX(total_cases)/population)*100,3) AS '% zara¿onej populacji'
FROM CovidDeath
WHERE continent = ''
GROUP BY location, population
ORDER BY ROUND((MAX(total_cases)/population)*100,3) DESC;


-- Liczby w odwo³aniu do œwiata

SELECT 
	DATE,
	SUM(total_cases) AS 'Iloœæ osób zaka¿onych na œwiecie'
FROM CovidDeath
WHERE continent = ''
GROUP BY date
ORDER BY date DESC


-- Dzienne zachorowania oraz œmierci w podziale na dni oraz kontynenty
SELECT
	date,
	SUM(CAST(new_cases AS bigint)) AS 'Nowe przypadki',
	SUM(CAST(new_deaths AS bigint)) AS ' Nowe œmierci'
FROM CovidDeath
WHERE continent = ''
GROUP BY date;

-- Populacja vs osoby, które siê zaszczepi³y
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

-- Suma ruchoma nowych zaszczepieñ dzieñ po dniu

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


-- CTE (* liczy równie¿ ludzi, którzy siê szczepili kilka razy)


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


