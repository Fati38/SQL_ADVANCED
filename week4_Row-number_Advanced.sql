/***************** ADVANCED QUESTIONS ****************************/

----- 1.Identify the top 3 highest-value orders for each product subcategory and customer by quarter.

SELECT        YEAR(s1.OrderDate) AS 'Year'
              ,DATEPART(QUARTER,s1.OrderDate) AS 'Quarter'
			  ,s3.ProductSubcategoryID 
			  ,s1.CustomerID
			  ,s1.TotalDue
			  ,s1.SalesOrderID
			  ,ROW_NUMBER() OVER ( PARTITION BY
			   YEAR(s1.OrderDate)
			  ,DATEPART(QUARTER,s1.OrderDate)
			  ,s3.ProductSubcategoryID 
			  ,s1.CustomerID 
			  ORDER BY s1.TotalDue DESC ) AS 'row_number'

FROM          [AdventureWorks2022].[Sales].[SalesOrderHeader] s1
LEFT JOIN     [AdventureWorks2022].[Sales].[SalesOrderDetail] s2
ON            s1.SalesOrderID = s2.SalesOrderID
LEFT JOIN     [AdventureWorks2022].[Production].[Product] s3
ON            s2.ProductID = s3.ProductID

----- 2.Rank each salesperson’s orders by total amount in each year and territory.
SELECT         a.Year
               ,a.TerritoryID
			   ,a.SalesPersonID
			   ,SUM(a.TotalDue) as 'Total_sales'
FROM 
(
SELECT         YEAR(OrderDate) AS 'Year'
               ,TerritoryID
			   ,SalesPersonID
			   ,TotalDue
			   ,ROW_NUMBER() OVER ( PARTITION BY 
			    YEAR(OrderDate)
				,TerritoryID
				,SalesPersonID  
				ORDER BY TotalDue DESC ) AS 'Rank'

FROM           [AdventureWorks2022].[Sales].[SalesOrderHeader] 
WHERE          SalesPersonID IS NOT NULL

) a
GROUP BY       a.Year
               ,a.TerritoryID
			   ,a.SalesPersonID
			   
ORDER BY 	   a.Year
               ,a.TerritoryID
			   ,a.SalesPersonID  DESC
                 

----  3.Find the top 2 orders with highest quantity per product model and sales territory by month.
SELECT            a.YEAR
                 ,a.MONTH
                 ,a.TerritoryID
				 ,a.ProductModelID
				 ,a.OrderQty
				 ,a.SalesOrderID
				

FROM (

SELECT            YEAR(s1.OrderDate) AS 'Year'
                 ,MONTH(s1.OrderDate) AS 'Month'
                 ,s1.TerritoryID
				 ,s3.ProductModelID
				 ,s2.OrderQty
				 ,s1.SalesOrderID
				 ,ROW_NUMBER() OVER ( PARTITION BY 
				  YEAR(s1.OrderDate)
                 ,MONTH(s1.OrderDate) 
                 ,s1.TerritoryID
				 ,s3.ProductModelID
				 ORDER BY s2.OrderQty DESC ) AS 'row_number'


FROM             [AdventureWorks2022].[Sales].[SalesOrderHeader] s1
LEFT JOIN        [AdventureWorks2022].[Sales].[SalesOrderDetail] s2
ON               s1.SalesOrderID = s2.SalesOrderID
LEFT JOIN        [AdventureWorks2022].[Production].[Product] s3
ON               s2.ProductID = s3.ProductID
) a
WHERE            a.row_number <= 2 

/*ORDER BY        a.YEAR
                 ,a.MONTH
                 ,a.TerritoryID
				 ,a.ProductModelID
				 ,a.OrderQty DESC
				 ,a.SalesOrderID

*/

---- 5.Rank products by quantity and price for each sales territory in each quarter.

SELECT        YEAR(s1.OrderDate) AS 'Year'
              ,DATEPART(QUARTER,s1.OrderDate) AS 'Quarter'
			  ,s1.TerritoryID 
			  ,s3.ProductID
			  ,s3.ListPrice
			  ,s2.OrderQty			
			  
			  ,ROW_NUMBER() OVER ( PARTITION BY
			   YEAR(s1.OrderDate)
			  ,DATEPART(QUARTER,s1.OrderDate)
			  ,s1.TerritoryID 
			  ,s3.ProductID
			   ORDER BY  s3.ListPrice DESC
			            ,s2.OrderQty  DESC ) AS 'row_number'

FROM          [AdventureWorks2022].[Sales].[SalesOrderHeader] s1
LEFT JOIN     [AdventureWorks2022].[Sales].[SalesOrderDetail] s2
ON            s1.SalesOrderID = s2.SalesOrderID
LEFT JOIN     [AdventureWorks2022].[Production].[Product] s3
ON            s2.ProductID = s3.ProductID



----  6.List the top 2 orders by revenue for each salesperson in each product category by year, orderded by top revenue groups 

SELECT         a.Year
              ,a.ProductCategoryID
			  ,a.SalesPersonID
			  ,a.SalesOrderID
			  ,a.TotalDue

FROM (

SELECT        YEAR(s1.OrderDate) AS 'Year'
              ,s4.ProductCategoryID
			  ,s1.SalesPersonID
			  ,s1.SalesOrderID
			  ,s1.TotalDue
			  ,ROW_NUMBER() OVER (PARTITION BY 
			   YEAR(s1.OrderDate)
              ,s4.ProductCategoryID
			  ,s1.SalesPersonID
			  ORDER BY s1.TotalDue DESC ) AS 'row_number'
			  ,DENSE_RANK() OVER (PARTITION BY 
			   s1.TotalDue 
			   ORDER BY s1.TotalDue DESC ) AS 'row_rank'

FROM          [AdventureWorks2022].[Sales].[SalesOrderHeader] s1
LEFT JOIN     [AdventureWorks2022].[Sales].[SalesOrderDetail] s2
ON            s1.SalesOrderID = s2.SalesOrderID
LEFT JOIN     [AdventureWorks2022].[Production].[Product] s3
ON            s2.ProductID = s3.ProductID
LEFT JOIN     [AdventureWorks2022].[Production].[ProductSubcategory] s4
ON            s3.ProductSubcategoryID = s4.ProductSubcategoryID

WHERE         s1.SalesPersonID IS NOT NULL

ORDER BY      s1.TotalDue DESC 
              ,YEAR(s1.OrderDate)
			  ,s4.ProductCategoryID
) a
ORDER BY       a.Year
              ,a.ProductCategoryID
			  ,a.SalesPersonID
			  ,a.SalesOrderID
			  ,a.TotalDue DESC