--*************************************************************************--
-- Title: Assignment06
-- Author: Cameron Severson
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-05-16,Cameron Severson,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_CameronSeverson')
	 Begin 
	  Alter Database [Assignment06DB_CameronSeverson] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_CameronSeverson;
	 End
	Create Database Assignment06DB_CameronSeverson;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_CameronSeverson;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
--'NOTES------------------------------------------------------------------------------------ 
-- 1) You can use any name you like for you views, but be descriptive and consistent
-- 2) You can use your working code from assignment 5 for much of this assignment
-- 3) You must use the BASIC views for each table after they are created in Question 1
--------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Go
Create -- Drop
View vCategories
With Schemabinding
As
  Select CategoryID
		,CategoryName
    From dbo.Categories;
Go

Go
Create -- Drop
View vProducts
With Schemabinding
As
  Select ProductID
		,ProductName
		,CategoryID
		,UnitPrice
    From dbo.Products;
Go

Go
Create -- Drop
View vEmployees
With Schemabinding
As
  Select EmployeeID
		,EmployeeFirstName
		,EmployeeLastName
		,ManagerID
    From dbo.Employees;
Go

Go
Create -- Drop
View vInventories
With Schemabinding
As
  Select InventoryID
		,InventoryDate
		,EmployeeID
		,ProductID
		,Count
    From dbo.Inventories;
Go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On vCategories to Public;
Go 

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;
Go

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;
Go

Deny Select On Products to Public;
Grant Select On vProducts to Public;
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

Go
Create -- Drop
View vCategoryProductPrice
As
  Select Top 10000000
		 C.CategoryName
		,P.ProductName
		,P.UnitPrice 
	From vCategories As C 
	  Join vProducts As P
		On C.CategoryID = P.CategoryID
	Order By CategoryName
		    ,ProductName;
Go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

Go
Create -- Drop
View vProductNamesInventoryCountsInventoryDate
As
  Select Top 10000000
		 P.ProductName
		,I.InventoryDate
		,I.Count
	From vProducts As P
	  Join vInventories As I
	    On P.ProductID = I.ProductID
	Order By ProductName
		    ,InventoryDate
		    ,Count;
Go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

Go
Create -- Drop
View vInventoryDatesEmployeeCount
As
  Select Top 10000000
		 I.InventoryDate
		,E.EmployeeFirstName + ' ' + E.EmployeeLastName As EmployeeName
	From vInventories As I
	  Join vEmployees As E
		On I.EmployeeID = E.EmployeeID
	Group By I.InventoryDate
			,E.EmployeeFirstName
			,E.EmployeeLastName
	Order By InventoryDate;
Go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

Go
Create -- Drop
View vCategoriesProductsInventoryDateCount
As
  Select Top 10000000
		 C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count
	From vInventories As I
	  Left Join vProducts As P
		On I.ProductID = P.ProductID
	  Join vCategories As C
		On P.CategoryID = C.CategoryID
	Order By CategoryName
			,ProductName
			,InventoryDate
			,Count;
Go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

Go
Create -- Drop
View vCategoriesProductsInventoryDateCountByEmployee
As
  Select Top 10000000
		 C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count
		,E.EmployeeFirstName + ' ' + E.EmployeeLastName As EmployeeName
    From vInventories As I
	  Join vEmployees As E
		On I.EmployeeID = E.EmployeeID
	  Left Join vProducts As P
		On I.ProductID = P.ProductID
	  Join vCategories As C
		On P.CategoryID = C.CategoryID
	Order By InventoryDate
			,CategoryName
			,ProductName
			,EmployeeName;
Go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

Go
Create -- Drop
View vCategoriesProductsInvDateCountByEmployeeChaiChang
As
  Select Top 10000000
		 C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count
		,E1.EmployeeFirstName + ' ' + E1.EmployeeLastName As EmployeeName
	From vInventories As I
	  Join vEmployees As E1
		On I.EmployeeID = E1.EmployeeID
	  Left Join vProducts As P
		On I.ProductID = P.ProductID
	  Join vCategories As C
		On P.CategoryID = C.CategoryID
	Where ProductName In
		(Select ProductName
		   From Products
		   Where ProductName = 'Chai' Or ProductName = 'Chang')
	Order By InventoryDate
			,CategoryName
			,ProductName;
Go

Select * From vCategoriesProductsInvDateCountByEmployeeChaiChang;
Go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

Go
Create -- Drop
View vEmployeesByManager
As
  Select Top 10000000 
		 E1.EmployeeFirstName + ' ' + E1.EmployeeLastName As 'Manager'
		,E2.EmployeeFirstName + ' ' + E2.EmployeeLastName As 'Employee'
	From vEmployees As E1
	  Join vEmployees As E2
		On E2.ManagerID = E1.EmployeeID
	Order By Manager
			,Employee;
Go

Select * From vEmployeesByManager;
Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

Go
Create -- Drop
View vCategoriesProductsEmployeesInventories
As
  Select Top 10000000
		 C.CategoryID
		,C.CategoryName
		,P.ProductID
		,P.ProductName
		,P.UnitPrice
		,I.InventoryID
		,I.InventoryDate
		,I.Count
		,E1.EmployeeID
		,E1.EmployeeFirstName + ' ' + E1.EmployeeLastName As 'Employee'
		,E2.EmployeeFirstName + ' ' + E2.EmployeeLastName As 'Manager'
     From vInventories As I
	   Join vEmployees As E1
		 On I.EmployeeID = E1.EmployeeID
	   Join vEmployees As E2
	     On E1.ManagerID = E2.EmployeeID
	   Join vProducts As P
		 On I.ProductID = P.ProductID
	   Join vCategories As C
		 On P.CategoryID = C.CategoryID
	Order By C.CategoryName
			,ProductName
			,I.InventoryDate;
Go

Select * From vCategoriesProductsEmployeesInventories
Go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From vCategories;
Go
Select * From vProducts;
Go
Select * From vEmployees;
Go
Select * From vInventories;
Go


Select * From vCategoryProductPrice;
Go
Select * From vProductNamesInventoryCountsInventoryDate;
Go
Select * From vInventoryDatesEmployeeCount;
Go
Select * From vCategoriesProductsInventoryDateCount;
Go
Select * From vCategoriesProductsInventoryDateCountByEmployee;
Go
Select * From vCategoriesProductsInvDateCountByEmployeeChaiChang;
Go
Select * From vEmployeesByManager;
Go
Select * From vCategoriesProductsEmployeesInventories;
Go
/***************************************************************************************/