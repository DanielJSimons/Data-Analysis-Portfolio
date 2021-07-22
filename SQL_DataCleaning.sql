--During this project I clean and arrange an opensource set of data to be both more efficient and user friendly for further analysis.

select *
From Portfolio_Project.dbo.NashvilleHousing

--Standardising date format (Current date/time, to only date)

select SaleDateConverted, CONVERT(Date, SaleDate)
From Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



--------------------------------------------------------------------



---Popultating the property address data based off of the ParcelID and the assumption that the property address is approximately constant per parcelid.


select *
From Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID



--used to see between entries using a JOIN which property address is NULL
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]    --based also off the assumption that the uniqueID is unique for each delivery.
where a.PropertyAddress is null

--Updates a to copy the propertyaddress data from b using a JOIN, then checked again with the above code such that 0 entries of propertyaddress are NULL.

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]



--------------------------------------------------------------------
	


--Separating the address into its own induvidual components i.e. Address, city.. etc

select PropertyAddress
From Portfolio_Project.dbo.NashvilleHousing


--Results in two separate colums of number/road and city.
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address    --the -1 removes the last character in the entry therefore removing the specified comma.
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




--------------------------------------------------------------------




--Separating OwnerAddress into its components, includes state this time.
--Replaces the comma with a '.', PARSENAME separates with . and therfore easilly separates the column into 3 more user-friendly columns.


Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
From Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255); 

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255); 

ALTER TABLE NashvilleHousing
Add OwnerSplitCounty NVARCHAR(255); 


Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Update NashvilleHousing
SET OwnerSplitCounty = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)


--------------------------------------------------------------------



--Standardising entries within the 'Sold as Vacant' field as currently there are 2 identical responses using different strings. Change Y to Yes and, N to No.

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant



--------------------------------------------------------------------



--Deleting unused columns

Select*
From Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress     --Removed as an example of unused or irrelevant data.

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate                     --Removed as we have converted the SaleDate into a simple date format, removing the time of day.
 
