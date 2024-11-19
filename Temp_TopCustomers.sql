---- Provide a list of the top 10 customers ideas by spend and a column for their spend in 2010, 2011, 2012 and 2013

--hint: 1 temp table with ROW_NUMBER() for top customers, 1 temp table for each year, script just joins everything together at the bottom

--- Temp Table 1 : TopCustomers_ID 

IF OBJECT_ID('TempDB.dbo.##TopCustomers_ID', 'u') IS NOT NULL DROP TABLE ##TopCustomers_ID

SELECT A.*
INTO ##TopCustomers_ID
FROM(

Select   TOP 10

          customerID
          ,SUM(TotalDue) as 'Total_sales' 
		  
FROM      [Sales].[SalesOrderHeader] 

GROUP BY customerID
ORDER BY Total_sales desc

  ) AS A


--- Temp Table 2 : TopCustomers_ID in 2011

IF OBJECT_ID('TempDB.dbo.##AllCustomers_2011', 'u') IS NOT NULL DROP TABLE ##AllCustomers_2011

SELECT A.*
INTO ##AllCustomers_2011
FROM(

SELECT   
           customerID
		   ,SUM(TotalDue) as 'Total_sales_2011'
          
		  				  
FROM      [Sales].[SalesOrderHeader]  

WHERE     YEAR(OrderDate) = 2011
GROUP BY  CustomerID

  ) AS A

  --- Temp Table 3 : TopCustomers_ID in 2012

IF OBJECT_ID('TempDB.dbo.##AllCustomers_2012', 'u') IS NOT NULL DROP TABLE ##AllCustomers_2012

SELECT A.*
INTO ##AllCustomers_2012
FROM(

SELECT   
           customerID
          ,SUM(TotalDue) as 'Total_sales_2012'
		  				  
FROM      [Sales].[SalesOrderHeader]  

WHERE     YEAR(OrderDate) = 2012
GROUP BY  CustomerID

  ) AS A

  ---- --- Temp Table 3 : TopCustomers_ID in 2013

IF OBJECT_ID('TempDB.dbo.##AllCustomers_2013', 'u') IS NOT NULL DROP TABLE ##AllCustomers_2013

SELECT A.*
INTO ##AllCustomers_2013
FROM(

SELECT   
           customerID
          ,SUM(TotalDue) as 'Total_sales_2013'
		  				  
FROM      [Sales].[SalesOrderHeader]  

WHERE     YEAR(OrderDate) = 2013

GROUP BY  CustomerID
  ) AS A

SELECT     s1.CustomerID
           ,s2.Total_sales_2011
		   ,s3.Total_sales_2012
		   ,s4.Total_sales_2013

FROM       ##TopCustomers_ID s1

LEFT JOIN  ##AllCustomers_2011 s2
ON         s1.customerID = s2.customerID
LEFT JOIN ##AllCustomers_2012 s3
ON        s2.customerID = s3.customerID
LEFT JOIN ##AllCustomers_2013 s4
ON        s3.customerID = s4.customerID 

ORDER BY  s2.Total_sales_2011
		   ,s3.Total_sales_2012
		   ,s4.Total_sales_2013