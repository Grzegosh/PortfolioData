CREATE DATABASE Housing;
USE Housing;

-- Proces czysczenia danych

-- èrÛd≥o do danych : 'https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data'

SELECT *
FROM Nashvile_housing;

-- Zmiana formatu wyúwietlania kolumny SaleDate
SELECT
	SaleDate,
	CONVERT(DATE,SaleDate)
FROM Nashvile_housing; -- Tak chcemy aby wyglπda≥y nasze dane

ALTER TABLE Nashvile_housing
ALTER COLUMN [SaleDate] DATE;


------------------------------------------------------------------------

SELECT *
FROM Nashvile_housing
ORDER BY ParcelID;

-- Moøemy zauwaøyÊ, øe ParcellID determinuje jaki powinien byÊ adres posiad≥oúci , wykorzystamy to aby uzupe≥niÊ nasze dane 

SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress) AS Adres_jaki_powinnismy_dodaÊ
FROM Nashvile_housing a
JOIN Nashvile_housing b
ON a.ParcelID = b.ParcelID
AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashvile_housing a
JOIN Nashvile_housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

 -- Pozbyliúmy siÍ nieruchomoúci bez adresu.
SELECT *
FROM Nashvile_housing
WHERE PropertyAddress IS NULL;


--------------------------------------------------------------------------------------

-- Rozbijanie adresu na indywidualne kolumny (Adres, Miasto, Stan)

SELECT PropertyAddress
FROM Nashvile_housing


SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Adres,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) AS Miasto
FROM Nashvile_housing;

ALTER TABLE Nashvile_housing
ADD Adres nvarchar(255);

ALTER TABLE Nashvile_housing
ADD Miasto nvarchar(50);

UPDATE Nashvile_housing SET Adres = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);
UPDATE Nashvile_housing SET Miasto = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress));

SELECT *
FROM Nashvile_housing;


SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),1),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM Nashvile_housing;

ALTER TABLE Nashvile_housing
ADD Owner_address nvarchar(255);

ALTER TABLE Nashvile_housing
ADD Owner_city nvarchar(50);

ALTER TABLE Nashvile_housing
ADD Owner_state nvarchar(2);

UPDATE Nashvile_housing SET Owner_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3);
UPDATE Nashvile_housing SET Owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2);
UPDATE Nashvile_housing SET Owner_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

ALTER TABLE Nashvile_housing
ALTER COLUMN Owner_state nvarchar(10);

SELECT *
FROM Nashvile_housing;


----------------------------------------------------------------------------------------------------

-- Zmiana Y i N na 'Yes' i 'No' w kolumnie 

SELECT DISTINCT SoldAsVacant
FROM Nashvile_housing;

SELECT
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' ELSE 
	CASE WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant
	END
	END
FROM Nashvile_housing;

UPDATE Nashvile_housing SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' ELSE 
	CASE WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant
	END
	END

SELECT DISTINCT SoldAsVacant
FROM Nashvile_housing;

-------------------------------------------------------------------------------------------------

--Usuwanie duplikatÛw (Jeúli LegalReference oraz ParcelID sπ takie same, uznajemy, øe dany rekord jest duplikatem



SELECT *
FROM Nashvile_housing;

WITH  RowNum AS (

SELECT *,
	ROW_NUMBER() OVER (PARTITION BY
	LegalReference,
	ParcelID
	ORDER BY UniqueID) Duplikaty
FROM Nashvile_housing
)
DELETE
FROM RowNum
WHERE Duplikaty >1


-- Usuwanie niepotrzebnych kolumn


SELECT *
FROM Nashvile_housing;

ALTER TABLE Nashvile_housing
DROP COLUMN  LandUse, OwnerAddress, PropertyAddress;