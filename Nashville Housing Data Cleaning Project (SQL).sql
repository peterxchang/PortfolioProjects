/*
Cleaning Data in SQL Queries (Nashville Housing Data)

Using Joins, CTE's, substrings, partitions, case statements

*/

Select *
From [Portfolio Project]..NashvilleHousingData

--------------------------------------------------------------------------------------------------------

-- Standardize Date Form

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project]..NashvilleHousingData

Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date; 

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)



--------------------------------------------------------------------------------------------------------

-- Populating Property Address Data

Select *
From [Portfolio Project]..NashvilleHousingData
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousingData a
JOIN [Portfolio Project]..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousingData a
JOIN [Portfolio Project]..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------

-- Parsing Addresses into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project]..NashvilleHousingData
--Where PropertyAddress is null
--Order by ParcelID

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

From [Portfolio Project]..NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousingData
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousingData
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 


Select *
From [Portfolio Project]..NashvilleHousingData




Select OwnerAddress
From [Portfolio Project]..NashvilleHousingData

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From [Portfolio Project]..NashvilleHousingData

--------------------------------------------------------------------------------------------------------

-- Updating Table

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


--------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousingData
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From [Portfolio Project]..NashvilleHousingData

Update NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						Else SoldAsVacant
						END

--------------------------------------------------------------------------------------------------------

-- Removing Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num


From [Portfolio Project]..NashvilleHousingData
--Order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1

--------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns


Select *
From [Portfolio Project]..NashvilleHousingData

ALTER TABLE [Portfolio Project]..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project]..NashvilleHousingData
DROP COLUMN SaleDate

