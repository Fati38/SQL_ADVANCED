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
		 