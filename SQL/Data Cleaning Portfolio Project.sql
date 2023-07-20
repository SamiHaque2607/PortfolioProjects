-- Cleaning Data in SQL Queries

-- Standardize the Date Format
Select *
From NashvilleData.dbo.NashvilleHousing;

-- Convert the "SaleDate" column to a date format and store it in a new column "SaleDateConverted"
Select saleDateConverted, CONVERT(Date, SaleDate)
From NashvilleData.dbo.NashvilleHousing;

-- Update the "SaleDate" column with the converted date
Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

-- If the update doesn't work properly, add a new column "SaleDateConverted" to the table
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

-- Update the new column with the converted date
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Populate Property Address data
Select *
From NashvilleData.dbo.NashvilleHousing
order by ParcelID;

-- Identify and populate missing "PropertyAddress" data by matching records based on "ParcelID"
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleData.dbo.NashvilleHousing a
JOIN NashvilleData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

-- Update the missing "PropertyAddress" data with the matched value
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleData.dbo.NashvilleHousing a
JOIN NashvilleData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID;

-- Split "PropertyAddress" into separate columns for "Address" and "City"
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From NashvilleData.dbo.NashvilleHousing;

-- Add columns for "PropertySplitAddress" and "PropertySplitCity" to the table
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

-- Update the new columns with the separated address and city values
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

-- Select all columns from the table to check the data
Select *
From NashvilleData.dbo.NashvilleHousing;

-- Select "OwnerAddress" column from the table
Select OwnerAddress
From NashvilleData.dbo.NashvilleHousing;

-- Split "OwnerAddress" into separate columns for "OwnerSplitAddress," "OwnerSplitCity," and "OwnerSplitState"
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerSplitState
From NashvilleData.dbo.NashvilleHousing;

-- Add columns for "OwnerSplitAddress," "OwnerSplitCity," and "OwnerSplitState" to the table
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

-- Update the new columns with the separated owner address, city, and state values
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

-- Select all columns from the table to check the data
Select *
From NashvilleData.dbo.NashvilleHousing;

-- Change Y and N to Yes and No in the "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleData.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2;

-- Update "SoldAsVacant" values from Y and N to Yes and No
Update NashvilleHousing
SET SoldAsVacant = CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END;

-- Remove Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) row_num
From NashvilleData.dbo.NashvilleHousing
)
-- Select and keep only the duplicates rows
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

-- Select all columns from the table to check the data
Select *
From NashvilleData.dbo.NashvilleHousing;

-- Delete Unused Columns
-- Select all columns from the table to check the data before deletion
Select *
From NashvilleData.dbo.NashvilleHousing;

-- Delete "OwnerAddress," "TaxDistrict," "PropertyAddress," and "SaleDate" columns from the table
ALTER TABLE NashvilleData.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
