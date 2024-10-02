USE SalesDB

--------------- WINDOW FUNCTIONS ------------------------------

-- TASK: Find the total Sales Across all orders

SELECT
SUM (Sales) TotalSales
FROM Sales.Orders;

-- TASK: Find the total Sales for each product

SELECT
ProductID,
SUM(Sales) TotalSales
FROM Sales.Orders
GROUP BY ProductID

-- TASK: Find the total sales for each product, additionally provide details such as order id & order date

SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER(PARTITION BY ProductID) TotalSalesByProduct
FROM Sales.Orders

-- TASK: Find the total sales across all orders, additionally provide details such as order id & order date

SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER() TotalSales
FROM Sales.Orders

-- TASK: Find the total sales across all products, find the total sales for each product additionally provide details such as order id & order date

SELECT
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER() TotalSales,
	SUM(Sales) OVER(PARTITION BY ProductID) TotalSalesByProduct
FROM Sales.Orders

-- TASK: Find the total sales for each combination of product and order status

SELECT
	OrderID,
	OrderDate,
	ProductID,
	OrderStatus,
	SUM(Sales) OVER(PARTITION BY ProductID, OrderStatus) TotalSalesByProductAndStatus
FROM Sales.Orders

-- TASK: Rank each order based on their sales from highest to lowest, additionally provide details such as order Id, order date

SELECT
	OrderID,
	OrderDate,
	Sales,
	RANK() OVER (ORDER BY Sales DESC) RankSales
FROM Sales.Orders

-- TASK: Rank the orders based on their sales from highest to lowest

SELECT
	OrderID,
	ProductID,
	Sales,
	DENSE_RANK() OVER (ORDER BY Sales DESC) SalesRank
FROM Sales.Orders

-- TASK: Find the top highest sales for each product

SELECT *
FROM (
	SELECT
		OrderID,
		ProductID,
		Sales,
		ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) RankByProduct
	FROM Sales.Orders
	) t
WHERE RankByProduct = 1

-- TASK: Find the lowest 2 customers based on their total sales

SELECT TOP 2 *
FROM
	(
	SELECT
		CustomerID,
		SUM(Sales) TotalSales,
		ROW_NUMBER () OVER (ORDER BY SUM(Sales)) RankByCustomer
	FROM Sales.Orders
	GROUP BY CustomerID
	) t

-- TASK: Identify duplicate rows in the table 'Orders Archive' and return a clean result without any duplicates

SELECT *
FROM (
SELECT
	ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTime DESC) rn,
	*
	FROM Sales.OrdersArchive
	) t
WHERE t.rn > 1



SELECT
	OrderID,
	Sales,
	NTILE(2) OVER (ORDER BY Sales DESC)
FROM Sales.Orders

-- TASK: Segment all orders into 3 categories: high, medium and low sales

SELECT *,
CASE WHEN Buckets = 1 THEN 'Hight'
	 WHEN Buckets = 2 THEN 'Medium'
	 WHEN Buckets = 3 THEN 'Low'
END SalesSegmentation
FROM (
	SELECT
		OrderID,
		Sales,
		NTILE(3) OVER (ORDER BY Sales DESC) Buckets
	FROM Sales.Orders) t

SELECT
	NTILE(2) OVER (ORDER BY OrderID DESC) Buckets,
	*
FROM Sales.Orders

-- TASK: Find the products that fall within the highest 40% of prices

SELECT *
FROM (
	SELECT
		Product,
		Price,
		CUME_DIST() OVER (ORDER BY Price DESC) DistRank
	FROM Sales.Products
	) t
WHERE t.DistRank <= 0.4

-- TASK: Analyze the month-over-month performance by finding the percentage change in sales between the current and previous months

SELECT
	OrderID,
	ShipDate,
	Sales,
	LEAD(Sales, 1, 0) OVER (ORDER BY MONTH(ShipDate)) PrevMonth
FROM Sales.Orders


SELECT
*,
CurrentMonthSales - PrevMonthSales AS MoM_Change,
 ROUND(CAST((CurrentMonthSales - PrevMonthSales) AS FLOAT)/PrevMonthSales * 100, 1) AS MoM_Perc
FROM (
	SELECT 
		MONTH(ShipDate) OrderMonth,
		SUM(Sales) CurrentMonthSales,
		LAG(SUM(Sales)) OVER (ORDER BY MONTH(ShipDate)) PrevMonthSales
	FROM Sales.Orders
	GROUP BY MONTH(ShipDate)
	) t

-- TASK: In order to analyze customer loyalty, rank customers based on the average days between their orders

SELECT
	CustomerID,
	AVG(DaysUntilNextOrder) AvgDays,
	RANK() OVER (ORDER BY COALESCE(AVG(DaysUntilNextOrder), 999999)) CustomerRank
FROM (
	SELECT 
		OrderID,
		CustomerID,
		OrderDate CurrentOrder,
		LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) NextOrder,
		DATEDIFF(day, OrderDate, LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate)) DaysUntilNextOrder
	FROM Sales.Orders
	) t
GROUP BY CustomerID

-- TASK: Find the lowest and highest sales for each product
-- TASK: Find the difference in sales between the current and the lowest sales

SELECT
	OrderID,
	ProductID,
	Sales,
	FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales DESC) HighestSales,
	LAST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales DESC RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) LowestSales,
	Sales - LAST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales DESC RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) Diff
FROM Sales.Orders

-- Union

SELECT
	FirstName,
	LastName
FROM Sales.Customers

UNION

SELECT
	FirstName,
	LastName
FROM Sales.Employees

-- TASK: Orders data are stored in separate tables. Combine all orders data into one report without duplicates

SELECT
*
FROM Sales.Orders

UNION

SELECT
*
FROM Sales.OrdersArchive;

-- TASK: Count how many times each customer has made an order with sales greater than 30

SELECT
CustomerID,
SUM(SalesFlag)
FROM(
	SELECT
		OrderID,
		CustomerID,
		Sales,
		CASE 
			WHEN Sales > 30 THEN 1
			ELSE 0
		END SalesFlag
	FROM Sales.Orders
	) t
GROUP BY CustomerID

-- TASK: Display the full name of customers in a single field by merging their first and last names, and add 10 bonus to each customer's score.

SELECT
	CustomerID,
	COALESCE(FirstName, '') + ' ' + COALESCE(LastName, '') FullName,
	COALESCE(Score, 0) + 10 ScoreWithBonus
FROM Sales.Customers

-- TASK: Calculate the age of employees

SELECT
	*,
	DATEDIFF(year, BirthDate, GETDATE()) EmployeeAge
FROM Sales.Employees

-- TASK: Find the average shipping duration in days for each month

SELECT
	OrderID,
	OrderDate,
	ShipDate,
	AVG(DATEDIFF(day, OrderDate, ShipDate)) OVER (PARTITION BY MONTH(ShipDate)) ShippingDuration
FROM Sales.Orders

SELECT
	AVG(DATEDIFF(day, OrderDate, ShipDate)) ShippingDuration
FROM Sales.Orders
GROUP BY MONTH(ShipDate)

-- TASK: Find the number of days between each order and the previous order

SELECT
	OrderID,
	OrderDate,
	LAG(OrderDate) OVER (ORDER BY OrderDate) PrevOrder,
	DATEDIFF(day, LAG(OrderDate) OVER (ORDER BY OrderDate), OrderDate) DaysBetweenOrders
FROM Sales.Orders

-- TASK: Find the products that have a price higher than the average price of all products

SELECT
	*
FROM (
	SELECT
		ProductID,
		Price,
		AVG(Price) OVER() AvgPrice
	FROM Sales.Products
	) t
WHERE Price > AvgPrice

-- TASK: Rank Customers based on their total amount of sales

SELECT
	*,
	RANK() OVER (ORDER BY t.CustomerSales DESC) CustomerRank
FROM (
	SELECT
		CustomerID,
		SUM(Sales) CustomerSales
	FROM Sales.Orders
	GROUP BY CustomerID
	) t

-- TASK: Show the details of orders made by customers in Germany

SELECT
	*
FROM Sales.Orders
WHERE CustomerID IN 
				(SELECT CustomerID
				FROM Sales.Customers
				WHERE Country = 'Germany')


-- TASK: Select female employees whose salaries are greater than the salaries of any male employees

SELECT
	*
FROM Sales.Employees
WHERE Gender = 'F'
AND
Salary > ANY (SELECT Salary FROM Sales.Employees WHERE Gender = 'M')

-- TASK: Select female employees whose salaries are greater than the salaries of all male employees

SELECT
	*
FROM Sales.Employees
WHERE Gender = 'F'
AND
Salary > ALL (SELECT Salary FROM Sales.Employees WHERE Gender = 'M')




------------ CTE --------------------

-- Step1: Find the total Sales Per Customer

WITH CTE_Total_Sales AS
(
	SELECT
		CustomerID,
		SUM(Sales) AS TotalSales
	FROM Sales.Orders
	GROUP BY CustomerID
),

-- Step2: Find the last order date for each customer

CTE_Last_Order_Date AS
(
	SELECT
		CustomerID,
		MAX(OrderDate) LastOrderDate
	FROM Sales.Orders
	GROUP BY CustomerID
),

-- Step3: Rank Customers based on Total Sales Per Customer (Nested CTE)

CTE_Customer_Rank AS
(
	SELECT
		CustomerID,
		RANK() OVER (ORDER BY TotalSales DESC) CustomerRank
	FROM CTE_Total_Sales
),

-- Step4: Segment customers based on their total sales (Nested CTE)

CTE_Customer_Segments AS
(
	SELECT
		CustomerID,
		CASE WHEN TotalSales > 100 THEN 'High'
			 WHEN TotalSales > 80 THEN 'Medium'
			 ELSE 'Low'
		END CustomerSegments
	FROM CTE_Total_Sales
)

SELECT
	c.CustomerID,
	c.FirstName,
	c.LastName,
	cts.TotalSales,
	lod.LastOrderDate,
	ccr.CustomerRank,
	ccs.CustomerSegments
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales cts
	ON c.CustomerID = cts.CustomerID
LEFT JOIN CTE_Last_Order_Date lod
	ON c.CustomerID = lod.CustomerID
LEFT JOIN CTE_Customer_Rank ccr
	ON c.CustomerID = ccr.CustomerID
LEFT JOIN CTE_Customer_Segments ccs
	ON c.CustomerID = ccs.CustomerID

-- Recursive CTE: Generate a Sequence of Numbers from 1 to 20

WITH Series AS
(
	SELECT 1 AS MyNumber
	UNION ALL
	SELECT
		MyNumber + 1
	FROM Series
	WHERE MyNumber < 20
)

SELECT
	*
FROM Series
OPTION (MAXRECURSION 30)

-- Recursive CTE: Show the employee hierarchy by displaying each employee's level within the organization

WITH CTE_Emp_Hierarchy AS
(
	SELECT
		EmployeeID,
		FirstName,
		ManagerID,
		1 AS Level
	FROM Sales.Employees
	WHERE ManagerID IS NULL
	UNION ALL
	SELECT
		e.EmployeeID,
		e.FirstName,
		e.ManagerID,
		Level + 1
	FROM Sales.Employees e
	INNER JOIN CTE_Emp_Hierarchy ceh
	ON e.ManagerID = ceh.EmployeeID
)

SELECT
	*
FROM CTE_Emp_Hierarchy

-- Find the running total of sales for each month

WITH CTE_Monthly_Summary AS (
	SELECT
		DATETRUNC(month, OrderDate) OrderMonth,
		SUM(Sales) TotalSales,
		COUNT(OrderID) TotalOrders,
		SUM(Quantity) TotalQuantities
		FROM Sales.Orders
		GROUP BY DATETRUNC(month, OrderDate)
	)

SELECT
	OrderMonth,
	TotalSales,
	SUM(TotalSales) OVER (ORDER BY OrderMonth) AS RunningTotal
FROM CTE_Monthly_Summary





------------------------- VIEWS ------------------------

CREATE VIEW Sales.V_Monthly_Summary AS 
(
		SELECT
		DATETRUNC(month, OrderDate) OrderMonth,
		SUM(Sales) TotalSales,
		COUNT(OrderID) TotalOrders,
		SUM(Quantity) TotalQuantities
		FROM Sales.Orders
		GROUP BY DATETRUNC(month, OrderDate)
)

SELECT
	OrderMonth,
	TotalSales,
	SUM(TotalSales) OVER (ORDER BY OrderMonth) AS RunningTotal
FROM Sales.V_Monthly_Summary

-- Update the View

--DROP VIEW Sales.V_Monthly_Summary

IF OBJECT_ID ('Sales.V_Monthly_Summary') IS NOT NULL
	DROP VIEW Sales.V_Monthly_Summary;
GO
CREATE VIEW Sales.V_Monthly_Summary AS 
(
		SELECT
		DATETRUNC(month, OrderDate) OrderMonth,
		SUM(Sales) TotalSales,
		COUNT(OrderID) TotalOrders
		FROM Sales.Orders
		GROUP BY DATETRUNC(month, OrderDate)
)

-- TASK: Provide a view that combines details from orders, products, customers and employees

CREATE VIEW Sales.V_Order_Details AS (
	SELECT
		o.OrderID,
		o.OrderDate,
		p.Product,
		p.Category,
		COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') CustomerName,
		c.Country CustomerCountry,
		COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') SalesName,
		e.Department,
		o.Sales,
		o.Quantity
	FROM Sales.Orders o
	LEFT JOIN Sales.Products p
		ON o.ProductID = p.ProductID
	LEFT JOIN Sales.Customers c
		ON o.CustomerID = c.CustomerID
	LEFT JOIN Sales.Employees e
		ON o.SalesPersonID = e.EmployeeID
)

SELECT
	*
FROM Sales.V_Order_Details

-- TASK: Provide a view for the EU Sales Team that combines details from all tables and excludes data related to the USA.

CREATE VIEW Sales.V_Order_Details_EU AS (
	SELECT
		o.OrderID,
		o.OrderDate,
		p.Product,
		p.Category,
		COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') CustomerName,
		c.Country CustomerCountry,
		COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') SalesName,
		e.Department,
		o.Sales,
		o.Quantity
	FROM Sales.Orders o
	LEFT JOIN Sales.Products p
		ON o.ProductID = p.ProductID
	LEFT JOIN Sales.Customers c
		ON o.CustomerID = c.CustomerID
	LEFT JOIN Sales.Employees e
		ON o.SalesPersonID = e.EmployeeID
	WHERE c.Country != 'USA'
)

SELECT
	*
FROM Sales.V_Order_Details_EU





----------------------------- CTAS ----------------------------------

-- CTAS to create table that shows the total numbers of orders for each month

SELECT
	DATENAME(month, OrderDate) OrderMonth,
	COUNT(OrderID) TotalOrders
INTO Sales.MonthlyOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate)

SELECT
	*
FROM Sales.MonthlyOrders

-- Updating CTAS

IF OBJECT_ID('Sales.MonthlyOrders', 'U') IS NOT NULL
	DROP TABLE Sales.MonthlyOrders;
GO
SELECT
	DATENAME(month, OrderDate) OrderMonth,
	COUNT(OrderID) TotalOrders
INTO Sales.MonthlyOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate)