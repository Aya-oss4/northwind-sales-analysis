--KPIS SALES

-- Total Revenue

select 
		round(sum((UnitPrice*Quantity)*(1-Discount)) ,0 )as Total_Revenue
	
	from [Order Details] ;

-- AOV

with OrderRevenu as(
	select 
		orderid,
		round(sum((UnitPrice*Quantity)*(1-Discount)) ,0 )as Total_Revenue
	
	from [Order Details]
	group by orderid 
) 
select 
	round(AVG(Total_Revenue) ,0) as AOV
from OrderRevenu ;


-- Total Orders

select 
	count (DISTINCT orderid) as Total_Orders
from Orders;

-- Total Orders per year

select
	year(orderdate) as order_year,
	count (DISTINCT orderid) as Total_Orders
from Orders
group by year(orderdate)
order by year(orderdate) ;


-- Discount Impact
with [Discount Impact] as(
select
	round(sum(Quantity*UnitPrice),0) as Revenue_Before_Discount,
	ROUND(SUM(Quantity * UnitPrice * (1 - Discount)), 0) AS Revenue_After_Discount,
	round(sum(Quantity*UnitPrice) - SUM(Quantity * UnitPrice * (1 - Discount)), 0) as Total_Discount_Amount
from [Order Details]
)

select
	Revenue_Before_Discount,
	Revenue_After_Discount,
	Total_Discount_Amount,
	cast(round((Total_Discount_Amount / Revenue_Before_Discount)*100,1)as varchar)+'%' as [Discount %]
from[Discount Impact] 

-- Revenue by Year 

SELECT 
    YEAR(o.OrderDate) AS OrderYear,
    ROUND(SUM((od.UnitPrice * od.Quantity) * (1 - od.Discount)), 0) AS Total_Revenue
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate)
ORDER BY OrderYear

--- Revenue by Month

SELECT 
    YEAR(o.OrderDate) AS OrderYear,
    DATENAME(MONTH,o.OrderDate)as OrderMonth,
    ROUND(SUM((od.UnitPrice * od.Quantity) * (1 - od.Discount)), 0) AS Total_Revenue
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate), DATENAME(MONTH,o.OrderDate)
ORDER BY OrderYear, OrderMonth

-- Revenue by Quarter

SELECT 
    YEAR(o.OrderDate) AS OrderYear,
    DATEPART(QUARTER, o.OrderDate) AS OrderQuarter,
    ROUND(SUM((od.UnitPrice * od.Quantity) * (1 - od.Discount)), 2) AS Total_Revenue
FROM Orders o
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate), DATEPART(QUARTER, o.OrderDate)
ORDER BY OrderYear, OrderQuarter ;


SELECT
	YEAR(o.OrderDate) as OrderYear,
	DATENAME(MONTH,o.OrderDate),
	 MONTH(o.OrderDate) AS MonthNum,				
    ROUND(SUM((od.UnitPrice * od.Quantity) * (1 - od.Discount)), 0) AS Total_Revenue
FROM Orders o
JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), DATENAME(MONTH, o.OrderDate)
ORDER BY OrderYear, MonthNum

-- Revenue Growth Rate YoY

with[Revenue by Year] as (
	SELECT 
		YEAR(o.OrderDate) AS OrderYear,
		ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0) AS Total_Revenue
	FROM Orders o
	JOIN [Order Details] od ON o.OrderID = od.OrderID
	GROUP BY YEAR(o.OrderDate)
)
SELECT
	OrderYear,
	Total_Revenue,
	ROUND(lag(Total_Revenue) over(order by OrderYear),0) AS Previous_Year_Revenue ,
CAST(	ROUND( (Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY OrderYear))  / LAG(Total_Revenue) OVER (ORDER BY OrderYear) * 100
, 0)AS VARCHAR) + '%' AS YoY_Growth
	
FROM [Revenue by Year] 
ORDER BY OrderYear;

-- 
with[Revenue by Year] as (
	SELECT 
		YEAR(o.OrderDate) AS OrderYear,
		ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0) AS Total_Revenue
	FROM Orders o
	JOIN [Order Details] od ON o.OrderID = od.OrderID
	GROUP BY YEAR(o.OrderDate)
)
SELECT
    OrderYear,
    Total_Revenue,
    Previous_Year_Revenue,
    CONCAT(YoY_Growth, '%') AS YoY_Growth
FROM (
    SELECT
        OrderYear,
        Total_Revenue,
     ISNULL(   ROUND(LAG(Total_Revenue) OVER (ORDER BY OrderYear), 0),0) AS Previous_Year_Revenue,
	ISNULL(
        ROUND(
            (Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY OrderYear))
            / LAG(Total_Revenue) OVER (ORDER BY OrderYear) * 100
        , 0) ,0) AS YoY_Growth
    FROM [Revenue by Year]

) T

-- 
SELECT YEAR(OrderDate) AS Yr, MIN(OrderDate) AS FirstOrder, MAX(OrderDate) AS LastOrder
FROM Orders
GROUP BY YEAR(OrderDate) ;

-- Avg_Monthly_Revenue

with YearlyStats as(
select
	YEAR(o.orderdate) as order_year ,
	count(DISTINCT month(o.orderdate)) as Months_Covered,
	round(sum((od.Quantity*od.UnitPrice)*(1-od.Discount)),0) as Total_Revenue
FROM Orders o
JOIN [Order Details] od 
ON o.OrderID = od.OrderID
group by YEAR(o.orderdate)
),

Revenue_Growth_Rate as(

SELECT
	order_year,
	Months_Covered,
	Total_Revenue,
	round((Total_Revenue/Months_Covered ),0) as Avg_Monthly_Revenue
FROM YearlyStats

)

SELECT
	r.order_year,
	r.Months_Covered,
	Total_Revenue,
	Avg_Monthly_Revenue,
	
	cast(ROUND(
	(Avg_Monthly_Revenue-lag(Avg_Monthly_Revenue) OVER(order by r.order_year))
	/lag(Avg_Monthly_Revenue) OVER(order by r.order_year)* 100 ,0) as varchar) + '%' YoY_Growth_Corrected

from Revenue_Growth_Rate r

order by order_year  ;


-----
