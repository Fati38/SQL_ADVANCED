/***** Variables and Procedures *************/

--- Find all records from production.product where the product name contains the word "helmet"

DECLARE @product_name nvarchar(50)  -- varcharSET @product_name = 'helmet'

SELECT      *

FROM        [Production].[Product]
WHERE       name like '%'+ @product_name+'%'

---- Declare an INT variable called @MinStock and set it to 100. Write a query that uses this variable to retrieve products from the Production.ProductInventory table where the Quantity is greater than @MinStock.


DECLARE   @MinStock  INT  SET       @MinStock  = 100

SELECT    *

FROM      [Production].[ProductInventory]
WHERE     Quantity > @MinStock


--- declare 2 variables - first name and last name - and write a script that extracts all the data from person.person based on the value you put in the variable

DECLARE   @first_name  nvarchar(50)  SET       @first_name  = 'ken'

DECLARE   @last_name  nvarchar(50)  SET       @last_name  = 'J'

SELECT    *

FROM      [Person].[Person]
WHERE     FirstName LIKE '%' +@first_name +'%'
AND       LastName  LIKE '%' +@last_name +'%'
    

---- Define three variables to represent a product ID, a list price, and a discount percentage. Set these variables to values of your choice. Write a query to calculate the final price of the product after applying the discount percentage. Display the product ID, original price, discount percentage, and final price.

DECLARE   @productID  INT  SET       @productID  = 749

DECLARE   @listPrice  INT  SET       @listPrice  = 10  --3578.27

DECLARE   @discountPercent  DECIMAL(5,2)  SET       @discountPercent = 0.20

SELECT    ProductID
          ,ListPrice
		  ,ListPrice * (1 - @discountPercent) AS 'Discounted_ListPrice'

FROM      [Production].[Product] 
--WHERE  ListPrice = @listPrice
WHERE     ProductID = @productID

/*GROUP BY  ProductID
          ,ListPrice
		  ,ListPrice * (1 - @discountPercent)
*/
ORDER BY  'Discounted_ListPrice' DESC

--- Give a list of all sales in the USA in 2011

DECLARE    @territory  nvarchar(50)  SET        @territory  = 'US'

DECLARE    @sales_year   INTSET        @sales_year  = 2011

SELECT     s1.SalesOrderID
           ,OrderDate
           ,s2.Name
		   ,s2.CountryRegionCode

FROM       [Sales].[SalesOrderHeader] s1
LEFT JOIN  [Sales].[SalesTerritory] s2
ON         s1.TerritoryID = s2.TerritoryID
WHERE      s2.CountryRegionCode LIKE @territory
AND        YEAR(s1.OrderDate) = @sales_year

ORDER BY s2.CountryRegionCode


--- Retrieve a list of customer first names and last names and address information and their sales information for customers in Seattle who placed an order more than £500 in 2011

DECLARE    @order_value  INT  SET        @order_value  = 500

DECLARE    @order_year   INTSET        @order_year  = 2011

SELECT      s2.FirstName
           ,s2.LastName
		   --city,
		   ,s1.SalesOrderID
		   ,s1.TotalDue
		   ,s1.OrderDate

FROM       [Sales].[SalesOrderHeader] s1
LEFT JOIN  [Person].[Person] s2
ON         s1.CustomerID = s2.BusinessEntityID

WHERE      s1.TotalDue > @order_value
AND        YEAR(s1.OrderDate) = @order_year
AND        s2.FirstName IS NOT NULL
AND        s2.LastName IS NOT NULL 

ORDER BY  s1.TotalDue DESC
