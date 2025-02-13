/*

Cleaning Data in SQL Queries

*/

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update properly we use:

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing


-- Populate Property Address data - some values are blank/NULL

SELECT*
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State) 
--- separate the address and the city in PropertyAddress; and the address, city and the state in OwnerAddress

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Adress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference 
				 ORDER BY 
				   UniqueID
				   ) AS row_num

FROM PortfolioProject..NashvilleHousing
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- Delete Unused Columns

SELECT*
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

