# Northwind Sales & Inventory Analysis

SQL Server analysis of the Northwind database, covering both sales performance and inventory health.

## Files

- **northwind_analysis.sql** — Sales KPIs (Revenue, AOV, Growth Rate, Discount Impact)
- **inventory_analysis.sql** — Inventory KPIs (Stock Value, Reorder Alerts, Dead Stock, Turnover Rate)

## Sales KPIs

- **Total Revenue** - overall revenue after discounts
- **Average Order Value (AOV)** - average value per order
- **Total Orders** - per year breakdown
- **Discount Impact** - how much revenue is lost to discounts
- **Revenue Trends** - monthly, quarterly, and yearly revenue
- **Revenue Growth Rate (YoY)** - year-over-year growth

## Inventory KPIs

- **Total Stock Value** - overall value of current inventory
- **Products Below Reorder Level** - products that need restocking
- **Out of Stock Products** - products with zero units in stock
- **Slow-Moving / Dead Stock** - products with low or no sales
- **Units on Order** - incoming stock and whether it's sufficient
- **Discontinued Products & Frozen Value** - money stuck in discontinued stock
- **Inventory Turnover Rate** - how fast each product sells relative to its stock

## Key Insights

1. Calculating a simple Year-over-Year Growth Rate gave misleading results, because not all years in the dataset had complete data (some years only covered a few months). Fixed by calculating Average Monthly Revenue instead, for a fair comparison.

2. A product with 298 units sold historically looked "healthy" by sales volume, but it's actually discontinued with stock still sitting in the warehouse — historical sales data alone would have missed this.

3. The product with the highest Turnover Rate (338x) had only 3 units left in stock — a hidden stockout risk behind a seemingly great number.

## Tools Used

- SQL Server
- T-SQL (Window Functions, CTEs, Aggregations, CASE statements)
