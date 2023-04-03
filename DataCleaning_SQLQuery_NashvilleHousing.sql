/*

Cleaning Data in SQL Queries

*/


Select *
from PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------

--Standardize Date Format


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-------------------------------------------------------------------------------------------------------

--Populate Property Address data


Select *
from NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select NHa.ParcelID, NHa.PropertyAddress, NHb.ParcelID, NHb.PropertyAddress, ISNULL(NHA.PropertyAddress, NHb.PropertyAddress)
from NashvilleHousing NHa
Join NashvilleHousing NHb
	ON NHa.ParcelID = NHb.ParcelID
	and NHa.[UniqueID ] <> NHb.[UniqueID ]
Where NHa.PropertyAddress is null

Update NHa
Set PropertyAddress = ISNULL(NHA.PropertyAddress, NHb.PropertyAddress)
from NashvilleHousing NHa
Join NashvilleHousing NHb
	ON NHa.ParcelID = NHb.ParcelID
	and NHa.[UniqueID ] <> NHb.[UniqueID ]
Where NHa.PropertyAddress is null





-------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (address, City, State)


Select PropertyAddress
from NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

----------------------

Select OwnerAddress
From NashvilleHousing


select
PARSENAME (REPLACE(OwnerAddress, ',', '.'),3) 
, PARSENAME (REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'),1) 
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'),3) 


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'),1) 


-------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field


select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order By 2


select SoldasVacant
, CASE when SoldasVacant = 'Y' Then 'Yes'
	   when SoldasVacant = 'N' Then 'No'
	   Else SoldasVacant
	   END
From NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldasVacant = 'Y' Then 'Yes'
	   when SoldasVacant = 'N' Then 'No'
	   Else SoldasVacant
	   END


-------------------------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER  BY 
						UniqueID
						) row_num
From NashvilleHousing
--Order By ParcelID 
)

Select *
FROM RowNumCTE
Where row_num > 1
Order By PropertyAddress


-------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


