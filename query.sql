/* cleaning data with SQL */

-- look at the data
select *
from NashvilleHousing

/* standardize date format */
select SaleDate as SaleDateTime, convert(Date,SaleDate) as SaleDate
from NashvilleHousing

-- creating a column to save the date from the date and time column
alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

/* look at PropertyAddress column */

select PropertyAddress
from NashvilleHousing

-- finding null values in the column
select PropertyAddress
from NashvilleHousing
where PropertyAddress is null

select *
from NashvilleHousing
where PropertyAddress is null

-- repopulating the null wherever possible
select ParcelID, PropertyAddress
from NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.Propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.Propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- double checking
select *
from NashvilleHousing
where PropertyAddress is null

/* breaking address into address, city, state */
select PropertyAddress
from NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City

from NashvilleHousing

alter table NashvilleHousing
add PropertyAddressSplit Nvarchar(255)

update NashvilleHousing
set PropertyAddressSplit = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertyCity Nvarchar(255)

update NashvilleHousing
set PropertyCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

-- owner address
select OwnerAddress
from NashvilleHousing

select
parsename(replace(OwnerAddress, ',', '.'), 1) as OwnerState,
parsename(replace(OwnerAddress, ',', '.'), 2) as OwnerCity,
parsename(replace(OwnerAddress, ',', '.'), 3) as OwnerAddressNew
from NashvilleHousing

alter table NashvilleHousing
add OwnerAddressSplit nvarchar(255)

update NashvilleHousing
set OwnerAddressSplit = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerCity nvarchar(255)

update NashvilleHousing
set OwnerCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerState nvarchar(255)

update NashvilleHousing
set OwnerState = parsename(replace(OwnerAddress, ',', '.'), 1)

--reviewing the dataset
select *
from NashvilleHousing

/* checking the SoldAsVacant column */
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

--changing Y and N to Yes and No
select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

/* remove duplicates */
with RowNumCTE as (
select *,
	row_number() over (
	partition by ParcelID,
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
order by PropertyAddress

with RowNumCTE as (
select *,
	row_number() over (
	partition by ParcelID,
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
delete
from RowNumCTE
where row_num > 1

/* delete unused columns */
select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate