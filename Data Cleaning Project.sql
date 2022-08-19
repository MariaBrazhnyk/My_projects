use PortfolioProject

select * 
from PortfolioProject..NashvilleHousing

-- Standartize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

--Alter table PortfolioProject..NashvilleHousing
--add SaleDateConverted Date

--Update PortfolioProject..NashvilleHousing
--set SaleDateConverted = CONVERT(Date, SaleDateConverted)

----------------------------------------------------------

-- Populate Property Address data

select * 
from PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing


Alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress Nvarchar(225)

Update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



Alter table PortfolioProject..NashvilleHousing
add PropertySplitCity Nvarchar(225)

Update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, len(PropertyAddress))


select * 
from PortfolioProject..NashvilleHousing



select OwnerAddress 
from PortfolioProject..NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing


Alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress Nvarchar(225)

Update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(225)

Update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter table PortfolioProject..NashvilleHousing
add OwnerSplitState Nvarchar(225)

Update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing

-------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2


select	SoldAsVacant,
		case	when SoldAsVacant = 'Y' then 'Yes'
				when SoldAsVacant = 'N' then 'No'
				else SoldAsVacant
				end
from NashvilleHousing

Update PortfolioProject..NashvilleHousing
set SoldAsVacant = case	when SoldAsVacant = 'Y' then 'Yes'
				when SoldAsVacant = 'N' then 'No'
				else SoldAsVacant
				end

----------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as (
select *,
	row_number() over (
	partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by 
						UniqueID
						) row_num
from NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1

-------------------------------------------

-- Delete Unused Columns


select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate