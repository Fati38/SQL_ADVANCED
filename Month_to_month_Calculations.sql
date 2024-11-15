--- Each salesperson previous TotalDue amount 

SELECT    SalesPersonID
          ,TotalDue
		  ,OrderDate
		  ,LAG(TotalDue) OVER (PARTITION BY 
		   SalesPersonID
		   ORDER BY 
		   OrderDate ASC ) AS 'previous_totalDue'
           ,ROW_NUMBER() OVER (PARTITION BY 
		   SalesPersonID 
		   ORDER BY  OrderDate  ) as 'row_number'

FROM      [AdventureWorks2022].[Sales].[SalesOrderHeader] 
WHERE     SalesPersonID IS NOT NULL 

-- For each product order quantity show the next order quantity for each territory

SELECT     s2.TerritoryID
           ,s1.ProductID
		   ,s1.OrderQty
		   ,s2.OrderDate

		   ,LEAD(s1.OrderQty) OVER (PARTITION BY 
		    s2.TerritoryID
           ,s1.ProductID
		    ORDER BY 
		    s2.OrderDate ) AS 'next_order_quantity'

FROM       [AdventureWorks2022].[Sales].[SalesOrderDetail] s1
LEFT JOIN  [AdventureWorks2022].[Sales].[SalesOrderHeader] s2
ON         s1.SalesOrderID = s2.SalesOrderID

--- Calculate the diff in total sales between consecutive months for each territory

WITH Total_sale_per_month  AS

(
SELECT    TerritoryID
          
          ,YEAR(OrderDate) as 'Year'
		  ,MONTH(OrderDate) as 'Month'
		  ,DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS 'yyyy_mm'
		  ,SUM(TotalDue) as 'total_per_yyyy_mm'

FROM      [AdventureWorks2022].[Sales].[SalesOrderHeader]

GROUP BY  TerritoryID        
         ,YEAR(OrderDate) 
	     ,MONTH(OrderDate) 


)

SELECT           TerritoryID
                ,[yyyy_mm]
				,total_per_yyyy_mm

				,LAG(total_per_yyyy_mm) OVER ( PARTITION BY 
				 TerritoryID
                
				 ORDER BY [yyyy_mm] ) AS 'prev_total_yyyy_mm'

				 ,total_per_yyyy_mm - LAG(total_per_yyyy_mm) OVER ( PARTITION BY 
				 TerritoryID
                
				 ORDER BY [yyyy_mm] ) AS 'month_month_total'
	
FROM 
Total_sale_per_month


--ORDER BY  TerritoryID         
		 --, date_yyyymm01 desc
/*
(

SELECT 

       TerritoryID
       ,[yyy-mm]
	   
	   ,total_sales
	  ,previous_month_sales
	  ,total_sales - previous_month_sales  as 'monthly_total_sales_difference'

FROM   Total_sale_per_month
) a

GROUP BY       a.TerritoryID
                 , a.[yyy-mm]

ORDER BY       a.TerritoryID
                 , a.[yyy-mm]

*/

-- For each sales person what is the highest sales was and the value of the sales happend just after the highest sale. for the same person ?
/* I want to see the sale that happened after the biggest sale, not the next highest. eg if the biggest sale was on the 13th November, I want to see what the value of the sale was on the 14th november
slightly different question to highest & second highest value, but fiendishly more difficult
*/

WITH     max_sales_per_person AS (

SELECT     SalesPersonID          
		  ,MAX(TotalDue) as 'Max_sales'

FROM      [AdventureWorks2022].[Sales].[SalesOrderHeader]
 
WHERE     SalesPersonID  IS NOT NULL
GROUP BY  SalesPersonID

--ORDER BY  Max_sales_per_person desc

),
 
Date_max_sales AS (
SELECT      s2.OrderDate
            ,s1.Max_sales 
			,s1.SalesPersonID
FROM        max_sales_per_person s1
LEFT JOIN   [Sales].[SalesOrderHeader] s2
ON          s1.Max_sales = s2.TotalDue
AND         s1.SalesPersonID = s2.SalesPersonID
)

SELECT     s1.SalesPersonID
          ,s1.Max_sales
		  ,s2.OrderDate
		  ,LEAD (s3.TotalDue) OVER (PARTITION BY
		  s1.SalesPersonID
		  ,s1.Max_sales
		  ORDER BY s2.OrderDate ) AS 'next_sales_after_highest'

FROM      max_sales_per_person s1
LEFT JOIN Date_max_sales s2
ON        s1.Max_sales = s2.Max_sales
AND       s1.SalesPersonID = s2.SalesPersonID
LEFT JOIN [Sales].[SalesOrderHeader] s3
ON        s2.Max_sales = s3.TotalDue
AND       s3.SalesPersonID = s2.SalesPersonID


----- USING ROW_NUMBER
-- For each sales person what is the highest sales was and the value of the sales happend just after the highest sale.
/* I want to see the sale that happened after the biggest sale, not the next highest. eg if the biggest sale was on the 13th November, I want to see what the value of the sale was on the 14th november
*/

--- CTE to retrieve max sales value for each salesperson

WITH     max_sales_per_person AS (

SELECT     SalesPersonID          
		  ,MAX(TotalDue) as 'Max_sales'

FROM      [AdventureWorks2022].[Sales].[SalesOrderHeader]
 
WHERE     SalesPersonID  IS NOT NULL
GROUP BY  SalesPersonID

),
--- CTE to retrieve the OrderDate corresponding to the maximum sale for each saleperson
Date_max_sales AS (
SELECT       s2.OrderDate
            ,s1.Max_sales 
			
			,s1.SalesPersonID
FROM        max_sales_per_person s1
LEFT JOIN   [Sales].[SalesOrderHeader] s2
ON          s1.Max_sales = s2.TotalDue
AND         s1.SalesPersonID = s2.SalesPersonID
),

---- CTE to rank the sales happened after that maximum sale

Rank_sales_after_max_sales AS (

SELECT     s1.SalesPersonID
          ,s1.Max_sales
		  ,s1.OrderDate as 'max_order_date'
		  ,s2.TotalDue
		  ,s2.OrderDate as 'next_order_dates'
		  ,DENSE_RANK() OVER (PARTITION BY 
		   s1.SalesPersonID
		   
		  ORDER BY s1.Max_sales DESC, s2.OrderDate   ) as 'Rank_sales'
          
FROM       Date_max_sales s1
LEFT JOIN  [AdventureWorks2022].[Sales].[SalesOrderHeader] s2
        
ON        s1.SalesPersonID = s2.SalesPersonID
AND       s1.OrderDate < = s2.OrderDate

/*ORDER BY s1.SalesPersonID
          ,s1.Max_sales
		  ,s1.OrderDate 
		  ,s2.OrderDate 
*/
 )
--- Main query to retrieve the sale value that happned just after the maximun sale for each person  ( rank sales =2)

SELECT    DISTINCT *

FROM      Rank_sales_after_max_sales a
WHERE     a.Rank_sales = 2

ORDER BY  a.SalesPersonID
          ,a.Max_sales
		  ,a.next_order_dates
		 
