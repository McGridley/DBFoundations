--*************************************************************************--
-- Title: Assignment06
-- Author: TGuthrie
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 17 Aug 2021, TGuthrie, Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_TGuthrie')
	 Begin 
	  Alter Database [Assignment06DB_TGuthrie] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_TGuthrie;
	 End
	Create Database Assignment06DB_TGuthrie;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_TGuthrie;

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

/********************************* Questions and Answers ********************************
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'*/





-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

	--Drop View vCat;
	Create View vCat As										-- Creating a view for a table
		Select CategoryID, CategoryName						-- Columns to put in the view
			From Assignment06DB_TGuthrie.dbo.Categories;	-- Where the data comes from
	go
	Select CategoryID, CategoryName From vCat;				-- Show the table
	go

	--Drop View vProd;
	Create View vProd As										-- Creating a view for a table
		Select ProductID, ProductName, CategoryID, UnitPrice	-- Columns to put in the view
			From Assignment06DB_TGuthrie.dbo.Products;			-- Where the data comes from
	go
	Select ProductID, ProductName, CategoryID, UnitPrice
		From vProd;												-- Show the table
	go

	--Drop View vEmp;
	Create View vEmp As											-- Creating a view for a table
		Select EmployeeID, EmployeeFirstName, 
			   EmployeeLastName, ManagerID						-- Columns to put in the view
			From Assignment06DB_TGuthrie.dbo.Employees;			-- Where the data comes from
	go
	Select EmployeeID, EmployeeFirstName, 
		   EmployeeLastName, ManagerID
		From vEmp;												-- Show the table
	go

	--Drop View vInv;
	Create View vInv As											-- Creating a view for a table
		Select InventoryID, InventoryDate, EmployeeID, 
			   ProductID, Count									-- Columns to put in the view
			From Assignment06DB_TGuthrie.dbo.Inventories;		-- Where the data comes from
	go
	Select InventoryID, InventoryDate, EmployeeID, 
		   ProductID, Count	
		From vInv;												-- Show the table
	go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
	Deny Select On Assignment06DB_TGuthrie.dbo.Categories  to Public;	-- Restrict general access to table
	Deny Select On Assignment06DB_TGuthrie.dbo.Products    to Public;	-- Restrict general access to table
	Deny Select On Assignment06DB_TGuthrie.dbo.Employees   to Public;	-- Restrict general access to table
	Deny Select On Assignment06DB_TGuthrie.dbo.Inventories to Public;	-- Restrict general access to table

	Grant Select On Assignment06DB_TGuthrie.dbo.vCat  to Public;		-- Provide general access to the view
	Grant Select On	Assignment06DB_TGuthrie.dbo.vProd to Public;		-- Provide general access to the view
	Grant Select On	Assignment06DB_TGuthrie.dbo.vEmp  to Public;		-- Provide general access to the view
	Grant Select On	Assignment06DB_TGuthrie.dbo.vInv  to Public;		-- Provide general access to the view
	go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
	--Drop View vCatProd;
	Create View vCatProd As								-- Creating a view for a table
		Select CategoryName, ProductName, UnitPrice		-- Columns to select
			From vCat Inner Join vProd					-- Join data from these tables
				On vCat.CategoryID = vProd.CategoryID;	-- The column to match against
	go

	Select CategoryName, ProductName, UnitPrice			-- Show these columns
		From vCatProd									-- from this view
		Order By CategoryName, ProductName;				-- Sort them
	go
			-- Here is an example of some rows selected from the view:
			-- CategoryName,ProductName,UnitPrice
			-- Beverages,Chai,18.00
			-- Beverages,Chang,19.00
			-- Beverages,Chartreuse verte,18.00

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
	--Drop View vProdInv;
	Create View vProdInv As								-- Creating a view for a table
		Select ProductName, [Count], InventoryDate		-- Columns to select
			From vProd Inner Join vInv					-- Join data from these tables
				On vProd.ProductID = vInv.ProductID;	-- The column to match against
	go

	Select ProductName, InventoryDate, [Count]			-- Show these columns
		From vProdInv									-- from this view
		Order By ProductName, InventoryDate, [Count];				-- Sort them
	go

			--Here is an example of some rows selected from the view:
			--ProductName,InventoryDate,Count
			--Alice Mutton,2017-01-01,15
			--Alice Mutton,2017-02-01,78
			--Alice Mutton,2017-03-01,83


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
	-- Drop View vInvEmp;
	Create View vInvEmp As														-- Creating a view for a table
		Select Distinct InventoryDate,											-- Columns to select
		       EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName		-- Marry up the first & last name
			From vInv Inner Join vEmp											-- Join data from these tables
				On vInv.EmployeeID = vEmp.EmployeeID;							-- The column to match against
	go

	Select InventoryDate, EmployeeName					-- Show these columns
		From vInvEmp									-- from this view
		Order By InventoryDate, EmployeeName;			-- Sort them
	go
	   		-- Here is an example of some rows selected from the view:
			-- InventoryDate,EmployeeName
			-- 2017-01-01,Steven Buchanan
			-- 2017-02-01,Robert King
			-- 2017-03-01,Anne Dodsworth
			
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
	-- Drop View vCatProdInv;
	Create View vCatProdInv As										-- Creating a view for a table
		Select CategoryName, ProductName, InventoryDate, [Count]	-- Columns to select
			From vCat Inner Join vProd								-- Join data from these tables
				On vCat.CategoryID = vProd.CategoryID				-- The column to match against
			Inner Join vInv											-- Then join to this table
				On vProd.ProductID = vInv.ProductID;				-- on this field
	go

	Select CategoryName, ProductName, InventoryDate, [Count]					-- Show these columns
		From vCatProdInv									-- from this view
		Order By CategoryName, ProductName, InventoryDate, [Count];			-- Sort them
	go
			-- Here is an example of some rows selected from the view:
			-- CategoryName,ProductName,InventoryDate,Count
			-- Beverages,Chai,2017-01-01,72
			-- Beverages,Chai,2017-02-01,52
			-- Beverages,Chai,2017-03-01,54

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
	-- Drop View vCatProdInvEmp;
	Create View vCatProdInvEmp As												-- Creating a view for a table
		Select CategoryName, ProductName, InventoryDate, [Count],				-- Columns to select
			   EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName		-- Marry up the first & last name
			From vCat Inner Join vProd											-- Join data from these tables
				On vCat.CategoryID = vProd.CategoryID							-- The column to match against
			Inner Join vInv														-- Then join to this table
				On vProd.ProductID = vInv.ProductID								-- on this field
			Inner Join vEmp														-- Then join this table
				On vInv.EmployeeID = vEmp.EmployeeID;							-- on this field
	go

	Select CategoryName, ProductName, InventoryDate, [Count], EmployeeName		-- Show these columns
		From vCatProdInvEmp														-- from this view
		Order By InventoryDate, CategoryName, ProductName, EmployeeName;		-- Sort them
	go
	   	 	-- Here is an example of some rows selected from the view:
			-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
			-- Beverages,Chai,2017-01-01,72,Steven Buchanan
			-- Beverages,Chang,2017-01-01,46,Steven Buchanan
			-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
	-- Drop View vCatProdInvChaiChangOnly;
	Create View vCatProdInvChaiChangOnly As												-- Creating a view for a table
		Select CategoryName, ProductName, InventoryDate, [Count],				-- Columns to select
			   EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName		-- Marry up the first & last name
			From vCat Inner Join vProd											-- Join data from these tables
				On vCat.CategoryID = vProd.CategoryID							-- The column to match against
			Inner Join vInv														-- Then join to this table
				On vProd.ProductID = vInv.ProductID								-- on this field
			Inner Join vEmp														-- Then join this table
				On vInv.EmployeeID = vEmp.EmployeeID							-- on this field
			Where ProductName In ('Chai', 'Chang');
	go

	Select CategoryName, ProductName, InventoryDate, [Count], EmployeeName		-- Show these columns
		From vCatProdInvChaiChangOnly											-- from this view
	go
	   	 	-- Here is an example of some rows selected from the view:
			-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
			-- Beverages,Chai,2017-01-01,72,Steven Buchanan
			-- Beverages,Chang,2017-01-01,46,Steven Buchanan
			-- Beverages,Chai,2017-02-01,52,Robert King

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
	-- Drop View vManagerManaged;
	Create View vManagerManaged As												-- Creating a view for a table
		Select																	-- These are the things to display
				Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName As Manager,	-- Will come from a self join
				Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName As Employee	-- Merge the first & last name for managers & non-managers
			From Employees As Mgr Inner Join Employees As Emp					-- This is the self join. Staffing is a second copy of Employees, not sure of the terminology to correctly describe this
				On Mgr.EmployeeID = Emp.ManagerID;								-- on this field
			go

		Select Manager, Employee												-- Show these columns
			From vManagerManaged												-- from this view
			Order By Manager;													-- sort on
		go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?
	-- Drop View vIwantitall;
	Create View vIwantitall As												-- Creating a view for a table
		Select																-- Columns to select
				vCat.CategoryID, CategoryName, vProd.ProductID, 
				ProductName, UnitPrice,	InventoryID, InventoryDate,
				[Count], vEmp.EmployeeID,
				vEmp.EmployeeFirstName + ' ' + vEmp.EmployeeLastName As EmployeeName
			From vCat Inner Join vProd											-- Join data from these tables
				On vCat.CategoryID = vProd.CategoryID							-- The column to match against
			Inner Join vInv														-- Then join to this table
				On vProd.ProductID = vInv.ProductID								-- on this field
			Inner Join vEmp														-- Then join this table
				On vInv.EmployeeID = vEmp.EmployeeID							-- on this field

	go

	Select 	CategoryID, CategoryName, ProductID, 
			ProductName, UnitPrice,	InventoryID, InventoryDate,
			[Count], EmployeeID, EmployeeName									-- Show these columns
		From vIwantitall														-- from this view
	go


			-- Here is an example of some rows selected from the view:
			-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
			-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
			-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
			-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
-- My view are tested in each of the questions. I did not use Order By in the views so these 
-- select statements are too basic. See each question for a select.
--Select * From [dbo].[vCat]
--Select * From [dbo].[vProd]
--Select * From [dbo].[vInv]
--Select * From [dbo].[vEmp]
--Select * From [dbo].[vCatProd]
--Select * From [dbo].[vProdInv]
--Select * From [dbo].[vInvEmp]
--Select * From [dbo].[vCatProdInv]
--Select * From [dbo].[vCatProdInvEmp]
--Select * From [dbo].[vCatProdInvChaiChangOnly]
--Select * From [dbo].[vManagerManaged]
--Select * From [dbo].[vIwantitall]
/***************************************************************************************/