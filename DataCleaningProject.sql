select *
from PortfolioProject..NashvilleHousing

-- Standardize Date Format

select SaleDateConverted ,convert(date, Saledate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set saledate = convert(date, Saledate)

alter table NashvilleHousing
add SaleDateConverted Date


update NashvilleHousing
set SaleDateConverted = convert(date, Saledate)

--Property Address Data

select *
from PortfolioProject..NashvilleHousing
order by ParcelID

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID] <> B.[UniqueID ]
where A.PropertyAddress is null

update A
set PropertyAddress = isnull(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID] <> B.[UniqueID ]

--Breaking out Address into Individual Columns

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
,substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add	OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject.dbo.NashvilleHousing

--Y and N to Yes and No 

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end

--Remove Duplicates

with RowNumCTE as(
select *, 
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				) row_num
from PortfolioProject..NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1

--Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate