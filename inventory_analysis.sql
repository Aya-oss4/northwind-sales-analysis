-- KPIS INVENTORY

-- Check available columns in Products table

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Products'


-- Total Stock Value 

select
	ROUND(sum(UnitsInStock * UnitPrice),0) as Total_Stock_Value
from Products 


-- Stock Status Summary (count of products per status)

select
	case
		when UnitsInStock > ReorderLevel then 'In Stock'
		when UnitsInStock <= ReorderLevel then 'Reorder Needed'
		else 'Out of Stock'
	end as Stock_Status,
	COUNT(*) AS Number_of_Products

from Products 
GROUP BY  
	case
		when UnitsInStock > ReorderLevel then 'In Stock'
		when UnitsInStock <= ReorderLevel then 'Reorder Needed'
		else 'Out of Stock'
	end 


-- Reorder Needed Products (still have stock but below reorder level)

select
	ProductName,
	UnitsInStock,
	ReorderLevel,
	case
        when UnitsInStock = 0 then 'Out of Stock'
        when UnitsInStock <= ReorderLevel then 'Reorder Needed'
        else 'In Stock'
    end as Stock_Status
from Products
where UnitsInStock > 0 and UnitsInStock <= ReorderLevel
order by UnitsInStock asc


-- Out of Stock Products (units in stock = 0)

select
	ProductName,
	UnitsInStock,
	ReorderLevel,
	case
		when UnitsInStock =0 then 'Out of Stock'
		when UnitsInStock <= ReorderLevel then 'Reorder Needed'
		else 'In Stock'
	end as Stock_Status
from Products
where UnitsInStock =0


-- Slow-Moving / Dead Stock

-- Step 1: Get average sales across all products (used as a reference threshold)

select
	AVG(total_sold) as Average_Sales
from(
select
	p.ProductName,
	isnull(SUM(od.Quantity) ,0)as total_sold
from Products p
left join [Order Details] od
on p.ProductID = od.ProductID
group by p.ProductName
) t

-- Step 2: Classify products as Dead Stock / Slow-Moving based on the threshold (133 = ~20% of average)

select
	p.ProductName,
	p.UnitsInStock,
	isnull(SUM(od.Quantity) ,0)as total_sold,
	case 
		when isnull(SUM(od.Quantity) ,0) = 0 then 'Dead Stock'
		when isnull(SUM(od.Quantity) ,0) < 133 then 'Slow-Moving'
		else 'Normal'
	end as Stock_Movement
from Products p
left join [Order Details] od
on p.ProductID = od.ProductID
group by p.ProductName ,p.UnitsInStock 
having isnull(SUM(od.Quantity) ,0) < 133 
ORDER BY Total_Sold ASC


-- Units on Order (and whether incoming stock will be enough after delivery)

select
	p.ProductName,
	p.UnitsInStock,
	p.UnitsOnOrder,
	
	( p.UnitsInStock + p.UnitsOnOrder ) as Stock_After_Delivery,
case
	when ( p.UnitsInStock + p.UnitsOnOrder ) < ReorderLevel then 'Still Not Enough'
	else 'Sufficient'
end as Status_After_Delivery
from Products p
where p.UnitsOnOrder>0
order by p.UnitsOnOrder desc


-- Discontinued Products

select
    ProductName,
    UnitsInStock,
    Discontinued
from Products
where Discontinued = 1


-- Frozen Value (money stuck in discontinued products that still have stock)

with Frozen_Valuee as(
select
    ProductName,
    UnitsInStock,
    UnitsInStock * UnitPrice as Frozen_Value
from Products
where Discontinued = 1 
    and UnitsInStock > 0
)

select
    sum(Frozen_Value) as Total_Frozen_Value_All_Products
from Frozen_Valuee


-- Inventory Turnover Rate

with ProductSales as(
select
    p.ProductID,
    p.ProductName,
    p.UnitsInStock,
    sum(od.Quantity) as Total_Sold
from Products p
join [Order Details] od on p.ProductID = od.ProductID
group by p.ProductID, p.ProductName, p.UnitsInStock
)

select
    ProductName,
    Total_Sold,
    UnitsInStock,
    round(cast(Total_Sold as float) / nullif(UnitsInStock, 0), 2) as Turnover_Rate
from ProductSales
order by Turnover_Rate desc
