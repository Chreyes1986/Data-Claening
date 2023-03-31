/*

Cleaning Data in SQL

*/

Use DataCleaning
Go

Select *
From DataCleaning.dbo.NashvilleHousing

---------------------------------------------------------------------------------

--Standarize Date Format

Select 
	SalesDateConverted, CONVERT(Date, SaleDate)
From 
	DataCleaning.dbo.NashvilleHousing

Alter Table nashvillehousing
Add SalesDateConverted Date

Update NashvilleHousing
set SalesDateConverted = convert(date,SaleDate)

--------------------------------------------------------------------------------

-- Populate Property Address Data

Select 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
From 
	DataCleaning.dbo.NashvilleHousing a
Join	
	DataCleaning.dbo.NashvilleHousing b
ON
	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From 
	DataCleaning.dbo.NashvilleHousing a
Join	
	DataCleaning.dbo.NashvilleHousing b
ON
	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------

--Breaking out Address in Individual Columns (address, city, state)

Select 
	PropertyAddress
From 
	DataCleaning.dbo.NashvilleHousing


Select
	SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) 
From 
	DataCleaning.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress))



Select 
	PARSENAME(Replace(owneraddress, ',', '.') ,3),
	PARSENAME(Replace(owneraddress, ',', '.') ,2),
	PARSENAME(Replace(owneraddress, ',', '.') ,1)

From 
	DataCleaning.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(owneraddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(owneraddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(owneraddress, ',', '.') ,1)

Select 
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
From 
	DataCleaning.dbo.NashvilleHousing

--------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select
	Distinct SoldAsVacant,
	Count(SoldasVacant)
From
	DataCleaning.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2



Select
	SoldasVacant,
	Case
		When SoldasVacant = 'N' then 'No'
		When SoldasVacant = 'Y' then 'Yes'
	Else SoldasVacant
	End
From
	DataCleaning.dbo.NashvilleHousing

Update NashvilleHousing
	Set SoldAsVacant = Case
		When SoldasVacant = 'N' then 'No'
		When SoldasVacant = 'Y' then 'Yes'
	Else SoldasVacant
	End


--------------------------------------------------------------------------------

--Delete Duplicates

With RomNumCTE AS (
Select
	*,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order By
	UniqueID) row_num
From
	DataCleaning.dbo.NashvilleHousing)
Select *
From RomNumCTE
Where row_num > 1
Order By PropertyAddress

--------------------------------------------------------------------------------

--Delete Unused Columns

Alter Table DataCleaning.dbo.NashvilleHousing
Drop Column SaleDate