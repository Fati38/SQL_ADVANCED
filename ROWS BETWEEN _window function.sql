---- ROWS BETWEEN 
/*

 *********** ROWS BETWEEN *********

<Window_Function>() OVER (
    PARTITION BY <column>
    ORDER BY <column>
    ROWS BETWEEN <starting point> AND <ending point>
)

The ROWS BETWEEN clause specifies the subset of rows, relative to the current row, for a window		function to consider when performing its calculation.
The range is defined using starting point and ending point, which can be one of the following:

UNBOUNDED PRECEDING: Includes all rows from the start of the partition to the current row.
UNBOUNDED FOLLOWING: Includes all rows from the current row to the end of the partition.
CURRENT ROW: Includes only the current row.
n PRECEDING: Includes n rows before the current row.
n FOLLOWING: Includes n rows after the current row.

*/

SELECT      SalesPersonID
           ,OrderDate
		   ,TotalDue
		   ,AVG(TotalDue) OVER ( 
		   PARTITION BY SalesPersonID 
		   ORDER BY OrderDate 
		   ROWS BETWEEN 2 preceding AND current row ) AS 'running_avg'

FROM       [Sales].[SalesOrderHeader]
WHERE      SalesPersonID IS NOT NULL 

ORDER BY    SalesPersonID
           ,OrderDate

--- Cummulitive total sales for months 1 to 8 in 2011

SELECT      
            a.OrderDate
		   ,a.TotalDue
		   ,b.ProductID
		   ,SUM(a.TotalDue) OVER ( PARTITION BY 
		   b.productID 
		   ORDER BY a.OrderDate
		   ROWS BETWEEN unbounded preceding AND current row  ) AS 'cumulitive_total_Due'

FROM       [Sales].[SalesOrderHeader] a
LEFT JOIN  [Sales].[SalesOrderDetail] b
ON         a.SalesOrderID = b.SalesOrderID

WHERE      a.SalesPersonID IS NOT NULL
AND        YEAR(OrderDate) = 2011
AND        Month(OrderDate) BETWEEN 1 AND 8