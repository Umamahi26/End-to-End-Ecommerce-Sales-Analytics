-- Total Revenue
SELECT
	ROUND(SUM(Sales),0) AS Total_Revenue
FROM global_superstore;

-- Total Orders
SELECT 
	COUNT(Order_ID) AS Total_Orders
FROM global_superstore;

-- Total Profit
SELECT
	ROUND(SUM(Profit),0) AS Total_Profit
FROM global_superstore;

-- Total Units Sold
SELECT
	SUM(Quantity) AS Units_Sold
FROM global_superstore;

-- Profit Margin
SELECT
	ROUND(SUM(Profit)/SUM(Sales),2) * 100 AS Profit_Margin
FROM global_superstore;

-- Revenue by Region
SELECT 
	Region,
	ROUND(SUM(Sales),0) AS Revenue
FROM global_superstore
GROUP BY Region
ORDER BY Revenue DESC;

-- Top 5 Products
SELECT
	TOP 5
	Product_Name,
	ROUND(SUM(Sales),0) AS Revenue
FROM global_superstore
GROUP BY Product_Name
ORDER BY Revenue DESC;

-- Monthly Revenue Trend
SELECT
	Order_Year AS Year,
	Order_Month AS Month,
	ROUND(SUM(Sales),0)AS Revenue
FROM global_superstore
GROUP BY Order_Year, Order_Month
ORDER BY Year,Revenue DESC;

-- Loss Making Products
SELECT
	Product_Name,
	ROUND(SUM(Profit),0) AS Profit
FROM global_superstore
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Profit;

-- Running Total Revenue
SELECT
	Order_Date,
	ROUND(SUM(Sales),0) AS Daily_Sales,
	ROUND(SUM(SUM(Sales)) OVER(ORDER BY Order_Date),0) AS Running_Revenue
FROM global_superstore
GROUP BY Order_Date
ORDER BY Order_Date;

-- Rank Top Cities by Revenue
SELECT *
	FROM (
			SELECT 
			City,
			ROUND(SUM(Sales),0) AS Revenue,
			RANK() OVER(ORDER BY SUM(Sales) DESC) AS City_Rank
		FROM global_superstore
		GROUP BY City
		) AS t
WHERE City_Rank <=10;

-- Region Wise Contribution %
SELECT
	Region,
	ROUND(SUM(Sales),0) AS Region_Revenue,
	ROUND(SUM(Sales) * 100.0 / SUM(SUM(Sales)) Over(),2) AS Contribution_pct
FROM global_superstore
GROUP BY Region
ORDER BY Contribution_pct DESC;

-- Monthly Sales Growth
WITH Monthly_Sales AS
(
	SELECT
	YEAR(Order_Date) AS Year,
	MONTH(Order_Date) AS Month,
	ROUND(SUM(Sales),0) AS Revenue
FROM global_superstore
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT *,
	ROUND(Revenue - LAG(Revenue) OVER(ORDER BY Year,Month),0) AS Sales_Growth
FROM Monthly_Sales;

-- Top Customer in Each Region
WITH Cust_Sales AS
(
	SELECT 
		Region,
		Customer_ID,
		ROUND(SUM(Sales),0) AS Revenue
	FROM global_superstore
	GROUP BY Region, Customer_ID
)
SELECT *
FROM 
(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY Region ORDER BY Revenue DESC) AS rn
	FROM Cust_Sales
) AS t
WHERE rn = 1;

-- Products Performing Above Average
SELECT 
	Product_Name,
	ROUND(SUM(Sales),0) AS Revenue
FROM global_superstore
GROUP BY Product_Name
HAVING SUM(Sales) >
(
SELECT AVG(Product_Revenue)
FROM(
SELECT
SUM(Sales) AS Product_Revenue
FROM global_superstore
GROUP BY Product_Name
) t
);

-- Repeat Customer Detection
WITH Cust_Orders AS
(
SELECT	
	Customer_ID,
	COUNT(DISTINCT Order_ID) AS Total_Orders
FROM global_superstore
GROUP BY Customer_ID
)
SELECT *
FROM Cust_Orders
WHERE Total_Orders > 1
ORDER BY Total_Orders DESC;
