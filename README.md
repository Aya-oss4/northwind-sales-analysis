# Northwind Sales Analysis

SQL Server analysis of the Northwind database, focused on calculating key sales KPIs.

## What's Included

- **Total Revenue** - overall revenue after discounts
- **Average Order Value (AOV)** - average value per order
- **Total Orders** - per year breakdown
- **Discount Impact** - how much revenue is lost to discounts
- **Revenue Trends** - monthly, quarterly, and yearly revenue
- **Revenue Growth Rate (YoY)** - year-over-year growth

## Key Insight

Calculating a simple Year-over-Year Growth Rate gave misleading results, 
because not all years in the dataset had complete data (some years only 
covered a few months). This made growth/decline numbers inaccurate.

**Fix:** Calculated Average Monthly Revenue instead of raw totals, to make 
a fair comparison between years regardless of how many months each year covers.

## Tools Used

- SQL Server
- T-SQL (Window Functions, CTEs, Aggregations)
