
/*****************************************************************************************************************
NAME:    EC_IT143_W3.4_JA.sql

PURPOSE:
         To answer eight business user and metadata questions using the AdventureWorks SQL Server sample database.

         This script demonstrates how to translate user questions into SQL statements by identifying the
         required information, selecting appropriate database tables, understanding table relationships,
         and applying SQL commands and functions such as SELECT, JOIN, WHERE, GROUP BY, ORDER BY, TOP,
         aggregate functions, Common Table Expressions (CTEs), and INFORMATION_SCHEMA views.

MODIFICATION LOG:
Ver      Date        Author          Description
-----   ----------   -------------   -------------------------------------------------------------------------------
1.0     11/14/2026  John Allotey     1. Created this script for EC IT143 W3.4 AdventureWorks assignment.


RUNTIME:
         Estimated runtime: Less than 1 minute, depending on server performance.


NOTES:
         This script contains eight user questions and their corresponding SQL answers.

         The questions are divided into four categories:
         - Business User Questions: Marginal Complexity (2 questions)
         - Business User Questions: Moderate Complexity (2 questions)
         - Business User Questions: Increased Complexity (2 questions)
         - Metadata Questions using INFORMATION_SCHEMA views (2 questions)

         The questions were selected from my own submission and those of my classmates, Ronald and
         Destiny Arebojie. Each question identifies its original author and includes an explanation
         of the SQL statement used to answer it.

         The script uses the AdventureWorks sample database and is intended to demonstrate how SQL
         can transform business questions into meaningful information for decision-making.

         LEARNING RESOURCES:
         1. Stack Overflow - How to Ask a Good Question
            https://stackoverflow.com/help/how-to-ask

         2. Stack Overflow - How to Write a Good Answer
            https://stackoverflow.com/help/how-to-answer

         3. Center for Creative Leadership - Active Listening Skills
            https://www.ccl.org/articles/leading-effectively-articles/coaching-others-use-active-listening-skills/

         4. Microsoft Learn - INFORMATION_SCHEMA Views
            https://learn.microsoft.com/en-us/sql/relational-databases/system-information-schema-views/system-information-schema-views-transact-sql

         5. LearnSQL - SQL Code Formatting Standards
            https://learnsql.com/blog/24-rules-sql-code-formatting-standard/

         6. W3Schools - SQL Tutorial
            https://www.w3schools.com/sql/

******************************************************************************************************************/

USE AdventureWorks2022;
GO


/*==================================================================
 Q1: What are the ten most expensive products based on their list prices?

 CATEGORY: Business User - Marginal Complexity
 ORIGINAL AUTHOR: John Allotey

 A1: This query retrieves the ten products with the highest list prices
     from the Production.Product table. The TOP keyword limits the
     results to ten records, while ORDER BY sorts the products from
     the highest to the lowest list price.
==================================================================*/

SELECT TOP 10
    ProductID,
    Name AS ProductName,
    ListPrice
FROM Production.Product
ORDER BY
    ListPrice DESC;
GO


/*==================================================================
 Q2: Which five employees currently have the highest number of
     accrued vacation hours?

 CATEGORY: Business User - Marginal Complexity
 ORIGINAL AUTHOR: Ronald Mutsikwi

 A2: This query retrieves the five current employees with the highest
     accrued vacation hours. The CurrentFlag column filters for
     current employees, while ORDER BY ranks them by vacation hours.
==================================================================*/

SELECT TOP 5
    BusinessEntityID AS EmployeeID,
    JobTitle,
    VacationHours,
    SickLeaveHours
FROM HumanResources.Employee
WHERE
    CurrentFlag = 1
ORDER BY
    VacationHours DESC,
    BusinessEntityID;
GO


/*==================================================================
 Q3: Which customers placed the most orders, and how much did each
     customer spend in total?

 CATEGORY: Business User - Moderate Complexity
 ORIGINAL AUTHOR: John Allotey

 A3: This query combines customer, person, store, and sales order
     information to identify customer purchasing activity.

     COUNT calculates the number of orders placed by each customer,
     while SUM calculates their total spending using TotalDue.
     LEFT JOIN allows both individual and store customers to appear.
==================================================================*/

SELECT
    c.CustomerID,
    CASE
        WHEN p.BusinessEntityID IS NOT NULL THEN
            CONCAT(
                p.FirstName,
                ' ',
                COALESCE(p.MiddleName + ' ', ''),
                p.LastName
            )
        ELSE s.Name
    END AS CustomerName,
    COUNT(soh.SalesOrderID) AS TotalOrders,
    SUM(soh.TotalDue) AS TotalAmountSpent
FROM Sales.Customer AS c
INNER JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
LEFT JOIN Person.Person AS p
    ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store AS s
    ON c.StoreID = s.BusinessEntityID
GROUP BY
    c.CustomerID,
    p.BusinessEntityID,
    p.FirstName,
    p.MiddleName,
    p.LastName,
    s.Name
ORDER BY
    TotalOrders DESC,
    TotalAmountSpent DESC;
GO


/*==================================================================
 Q4: Which three product categories generated the highest sales
     revenue based on order quantity and unit price?

 CATEGORY: Business User - Moderate Complexity
 ORIGINAL AUTHOR: Destiny Arebojie

 A4: This query identifies the three product categories with the
     highest sales revenue.

     It joins Sales.SalesOrderDetail with the Production product
     tables to identify the categories associated with sold products.
     SUM calculates total quantities and revenue for each category.
==================================================================*/

SELECT TOP 3
    pc.Name AS ProductCategory,
    SUM(sod.OrderQty) AS TotalQuantitySold,
    SUM(sod.OrderQty * sod.UnitPrice) AS TotalSalesRevenue
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
INNER JOIN Production.ProductSubcategory AS psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS pc
    ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY
    pc.Name
ORDER BY
    TotalSalesRevenue DESC;
GO


/*==================================================================
 Q5: Which ten individual customers have the highest lifetime total
     due across all completed online sales orders, including their
     full names and order counts?

 CATEGORY: Business User - Increased Complexity
 ORIGINAL AUTHOR: Ronald Mutsikwi

 A5: This query identifies the ten most valuable individual customers
     based on their completed online sales orders.

     It joins Customer, Person, and SalesOrderHeader to retrieve
     customer names and sales information.

     PersonType = 'IN' identifies individual customers.
     OnlineOrderFlag = 1 filters online orders.
     Status = 5 identifies shipped orders in AdventureWorks.

     COUNT calculates the number of qualifying orders, while SUM
     calculates the lifetime total due for those orders.
==================================================================*/

SELECT TOP 10
    c.CustomerID,
    CONCAT(
        p.FirstName,
        ' ',
        COALESCE(p.MiddleName + ' ', ''),
        p.LastName
    ) AS CustomerName,
    COUNT(soh.SalesOrderID) AS TotalOrders,
    SUM(soh.TotalDue) AS LifetimeTotalDue
FROM Sales.Customer AS c
INNER JOIN Person.Person AS p
    ON c.PersonID = p.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
WHERE
    p.PersonType = 'IN'
    AND soh.OnlineOrderFlag = 1
    AND soh.Status = 5
GROUP BY
    c.CustomerID,
    p.FirstName,
    p.MiddleName,
    p.LastName
ORDER BY
    LifetimeTotalDue DESC;
GO


/*==================================================================
 Q6: Compare bicycle sales across sales territories during 2012 and
     2013. Show total quantity sold, total revenue, and average order
     value for each territory.

 CATEGORY: Business User - Increased Complexity
 ORIGINAL AUTHOR: Destiny Arebojie

 A6: This query compares bicycle sales performance across different
     sales territories for 2012 and 2013.

     A Common Table Expression (CTE) first calculates bicycle sales
     quantities and revenue for each individual sales order.

     The main query then groups the results by territory and year.
     SUM calculates total quantity and revenue, while AVG calculates
     the average bicycle-product revenue per order.

     The date filter includes all sales from 2012 and 2013.
==================================================================*/

WITH BicycleOrderSales AS
(
    SELECT
        st.Name AS TerritoryName,
        YEAR(soh.OrderDate) AS SalesYear,
        soh.SalesOrderID,
        SUM(sod.OrderQty) AS TotalQuantitySold,
        SUM(sod.LineTotal) AS OrderRevenue
    FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
    INNER JOIN Production.Product AS p
        ON sod.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory AS psc
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON psc.ProductCategoryID = pc.ProductCategoryID
    INNER JOIN Sales.SalesTerritory AS st
        ON soh.TerritoryID = st.TerritoryID
    WHERE
        pc.Name = 'Bikes'
        AND soh.OrderDate >= '20120101'
        AND soh.OrderDate < '20140101'
    GROUP BY
        st.Name,
        YEAR(soh.OrderDate),
        soh.SalesOrderID
)

SELECT
    TerritoryName,
    SalesYear,
    SUM(TotalQuantitySold) AS TotalQuantitySold,
    SUM(OrderRevenue) AS TotalRevenue,
    COUNT(SalesOrderID) AS NumberOfOrders,
    AVG(OrderRevenue) AS AverageOrderValue
FROM BicycleOrderSales
GROUP BY
    TerritoryName,
    SalesYear
ORDER BY
    TerritoryName,
    SalesYear;
GO


/*==================================================================
 Q7: Can you generate a list of all base tables in the AdventureWorks
     database that belong to the Sales schema using the
     INFORMATION_SCHEMA.TABLES view?

 CATEGORY: Metadata
 ORIGINAL AUTHOR: Ronald Mutsikwi

 A7: This query uses the INFORMATION_SCHEMA.TABLES view to retrieve
     the names of all base tables belonging to the Sales schema.

     The WHERE clause filters the results to include only base tables
     within the Sales schema.
==================================================================*/

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA = 'Sales'
    AND TABLE_TYPE = 'BASE TABLE'
ORDER BY
    TABLE_NAME;
GO


/*==================================================================
 Q8: Using INFORMATION_SCHEMA views, which AdventureWorks tables
     contain columns named ProductID, ProductSubcategoryID, or
     ProductCategoryID?

 CATEGORY: Metadata
 ORIGINAL AUTHOR: Destiny Arebojie

 A8: This query uses the INFORMATION_SCHEMA.COLUMNS view to identify
     database tables containing the specified product-related
     column names.

     It retrieves the schema name, table name, column name, and
     data type to provide a clear overview of where these columns
     are used throughout the database.
==================================================================*/

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
    COLUMN_NAME IN
    (
        'ProductID',
        'ProductSubcategoryID',
        'ProductCategoryID'
    )
ORDER BY
    COLUMN_NAME,
    TABLE_SCHEMA,
    TABLE_NAME;
GO


/*==================================================================
 CONCLUSION:

 This assignment demonstrates how to translate business user
 questions and database metadata questions into SQL statements.

 The eight queries apply different SQL concepts and techniques,
 including:

 - SELECT and WHERE to retrieve and filter information.
 - TOP and ORDER BY to identify and rank important records.
 - INNER JOIN and LEFT JOIN to combine related database tables.
 - GROUP BY and aggregate functions to summarize business data.
 - Common Table Expressions (CTEs) to organize complex queries.
 - INFORMATION_SCHEMA views to retrieve database metadata.

 By applying these techniques, user questions can be transformed
 into meaningful information that helps organizations understand
 their data and make informed business decisions.

 END OF SCRIPT
==================================================================*/
