## TITLE: Elevate Customer Satisfaction: Revolutionize Supply Chain with SQL-Driven Inventory Optimization
## RATIONALE FOR THE PROJECT
## Inventory optimization is the process of strategically managing inventory levels to maximize efficiency 
## and minimize costs while ensuring that customer demand is met. It involves analyzing factors such as demand patterns, lead times, supply chain constraints, and storage costs 
## to determine the optimal quantity of each item to stock. 

## The goal of inventory optimization is to strike a balance between having enough inventory to fulfill customer orders promptly while avoiding excess stock that ties up capital and increases carrying costs.
## Implementing a comprehensice inventory optimization system powered by MySQL is imperative for TechElectro INc. due to several compelling reasons.
## Cost Reduction
## Enhanced Customer Satisfaction
## Competitive Advantage
## Profitability

## 	AIMS OF THE PROJECT
## The primary goals of this project are to implement a solid inventory optimization system using MySQL and address business challenges effectively
## Optimal Inventory levels
## Data_driven Decisions

## Prelim-creation of Schema/Database
CREATE SCHEMA tech_electro;
USE tech_electro;

## DAT exploration
SELECT * FROM tech_electro.external_factors limit 10;
SELECT * FROM tech_electro.inventory_data limit 10;
SELECT * FROM tech_electro.product_information limit 10;
SELECT * FROM tech_electro.sales_data limit 10;

## Understanding the structure of the datasets
DESCRIBE tech_electro.product_information;
DESC tech_electro.sales_data;

## Data Cleaning
## Changing to the right data type for all columns
## external factors table
## SalesDate DATE, GDP Decimal (15,2), InflationRate Decimal (5,2), Seasonalfactor decimal (5,2)
Alter Table tech_electro.external_factors 
Add column New_Sales_Date DATE;
SET SQL_SAFE_UPDATES = 0; ##Turning off safe updates
Update tech_electro.external_factors 
SET New_Sales_Date = STR_TO_DATE(Sales_Date,'%d/%m/%Y');
Alter Table tech_electro.external_factors 
Drop column Sales_Date;
Alter TABLE tech_electro.external_factors 
Change Column New_Sales_Date Sales_Date DATE;

Select * from tech_electro.external_factors;

Alter TABLE tech_electro.external_factors 
Modify Column GDP Decimal (15,2);
Alter TABLE tech_electro.external_factors 
Modify Column Inflation_Rate Decimal (5,2);
Alter TABLE tech_electro.external_factors
Modify Column Seasonal_Factor Decimal (5,2);
Show columns from tech_electro.external_factors;

## Product data
## Product_ID INT NOT NULL, Product_Category TEXT; Promotions ENUM ('yes', 'no')
Alter TABLE tech_electro.product_data
Add column NewPromotions ENUM ('yes', 'no');
Update tech_electro.product_data
Set NewPromotions = CASE
When Promotions = 'yes' Then 'yes'
When Promotions = 'no' then 'no'
Else Null
End;
Alter TABLE tech_electro.product_data
drop column Promotions;
Alter TABLE tech_electro.product_data
Change column NewPromotions Promotions ENUM ('yes', 'no');
describe tech_electro.product_data;

## Sales Data
Alter Table tech_electro.sales_data 
Add column New_Sales_Date DATE;
Update tech_electro.sales_data  
SET New_Sales_Date = STR_TO_DATE(Sales_Date,'%d/%m/%Y');
Alter Table tech_electro.sales_data  
Drop column Sales_Date;
Alter TABLE tech_electro.sales_data 
Change Column New_Sales_Date Sales_Date DATE;
desc tech_electro.sales_data; 

## Identifying missing values using 'IS NUll' function
## external factor data
Select
	SUM(CASE WHEN Sales_Date IS NULL THEN 1 ELSE 0 END) As missing_sales_date,
	SUM(CASE WHEN GDP IS NULL THEN 1 ELSE 0 END) As missing_gdp,
	SUM(CASE WHEN Inflation_Rate IS NULL THEN 1 ELSE 0 END) As missing_inflation_rate,
	SUM(CASE WHEN Seasonal_Factor IS NULL THEN 1 ELSE 0 END) As missing_seasonal_factor
FROM 
	tech_electro.external_factors;
    
## Identifying missing values using 'IS NUll' function
## Product_data
Select
	SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) As missing_product_ID,
	SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END) As missing_product_category,
	SUM(CASE WHEN Promotions IS NULL THEN 1 ELSE 0 END) As missing_promotions
FROM 
	tech_electro.product_data;
    
## Identifying missing values using 'IS NUll' function
## Sales_data
Select
	SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) As missing_product_ID,
	SUM(CASE WHEN Sales_Date IS NULL THEN 1 ELSE 0 END) As missing_sales_date,
	SUM(CASE WHEN Inventory_Quantity IS NULL THEN 1 ELSE 0 END) As missing_inventory_quantity,
	SUM(CASE WHEN Product_Cost IS NULL THEN 1 ELSE 0 END) As missing_product_cost
FROM 
	tech_electro.sales_data;
    
## Identifying using 'Group BY' and 'Having' clauses and remove them if necessary
## external factor data
Select Sales_Date, Count(*) AS count
From tech_electro.external_factors
Group by Sales_Date
Having count>1;

Select Count(*)
From 
(Select Sales_Date, Count(*) AS count
From tech_electro.external_factors
Group by 1
Having count>1) as Duplicate;

## Product data
Select 
Product_ID, Product_Category, Count(*) AS count
From tech_electro.product_data
Group by 1,2
Having count>1;

Select Count(*)
From 
(Select 
Product_ID, Product_Category, Count(*) AS count
From tech_electro.product_data
Group by 1,2
Having count>1) as Duplicate;

## sales data
Select 
Prod_ID, Sales_Date, Count(*) AS count
From tech_electro.sales_data
Group by 1,2
Having count>1;

## Dealing with duplicates for external_factors and Product_data
## external factor
Delete e1 from tech_electro.external_factors e1
INNER JOIN (
Select Sales_Date,
ROW_NUMBER() OVER (PARTITION BY Sales_Date ORDER BY Sales_Date) AS rn
FROM tech_electro.external_factors
) e2 ON e1.Sales_Date = e2.Sales_Date
WHERE e2.rn>1;

## Product_data
Delete p1 from tech_electro.product_data p1
INNER JOIN (
Select Product_ID,
ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Product_ID) AS rn
FROM tech_electro.product_data
) p2 ON p1.Product_ID = p2.Product_ID
WHERE p2.rn>1;

##Data Integration
## Combine Sales_data and Product_data first
## New_Sales_Date should be used
DROP VIEW IF EXISTS Sales_Product_Data;
-- Alternatively, if it's a table, use:
-- DROP TABLE IF EXISTS Inventory_Date;
CREATE VIEW Sales_Product_Data AS
Select
s.Prod_ID,
s.Sales_Date,
s.Inventory_Quantity,
s.Product_Cost,
p.Product_ID,
p.Product_Category,
p.Promotions
from sales_data s
Join product_data p On s.Prod_ID=p.Product_ID;
Select * from sales_data

Select * from Sales_Product_Data
##sale_product data and external_factors
DROP VIEW IF EXISTS Inventory_Date;
-- Alternatively, if it's a table, use:
-- DROP TABLE IF EXISTS Inventory_Date;

CREATE VIEW Inventory_Date AS
SELECT
    sp.Product_ID,
    sp.Sales_Date,
    sp.Inventory_Quantity,
    sp.Product_Cost,
    sp.Product_Category,
    sp.Promotions,
    e.GDP,
    e.Inflation_Rate,
    e.Seasonal_Factor
FROM
    Sales_Product_Data sp
JOIN
    external_factors e
ON
    sp.Sales_Date = e.New_Sales_Date;
   
Select * from Inventory_Date

## Descriptive Analysis
## Basic Statistics
## Avergae Sales (Inventory Quantity * Product Cost*)

Select Product_ID,
round(AVG(Inventory_Quantity*Product_Cost),2)AS avg_sales
From Inventory_Date
Group by 1
Order by avg_sales DESC;

##Median stock levels (i., 'Inventory Quantity')
Select Product_ID,
round(AVG(Inventory_Quantity),2)AS median_stock
From (
Select Product_ID,
Inventory_Quantity,
ROW_NUMBER () OVER(Partition by Product_ID order by Inventory_Quantity) As row_num_asc,
ROW_NUMBER () OVER(Partition by Product_ID order by Inventory_Quantity DESC) As row_num_desc
from Inventory_Date)
AS subquery
Where row_num_asc IN (row_num_desc, row_num_desc -1, row_num_desc +1)
Group by Product_ID;

##Product performance metrics (total sales per product)
Select Product_ID,
round(sum(Inventory_Quantity*Product_Cost)) as total_sales
From Inventory_Date
Group by 1
Order by total_sales desc;

##Identify high-demand products based on avaerga sales
WITH HighDemandProducts AS (
    SELECT Product_ID, AVG(Inventory_Quantity) AS avg_sales
    FROM Inventory_Date
    GROUP BY Product_ID
    HAVING avg_sales > (SELECT AVG(Inventory_Quantity) * 0.95 FROM sales_data)
)

## Calculate stockout frequency from high-demand products
select s.Product_ID,
Count(*) as stockout_frequency
From Inventory_Date s
Where S.Product_ID in (Select Product_ID from HighDemandProducts)
AND s.Inventory_Quantity=0
Group by s.Product_ID;
## None of the High demand products has experienced stockout

## Alternative way to Calculate stockout frequency from high-demand products
WITH HighDemandProducts AS (
    SELECT Product_ID, AVG(Inventory_Quantity) AS avg_sales
    FROM Inventory_Date
    GROUP BY Product_ID
    HAVING avg_sales > (SELECT AVG(Inventory_Quantity) * 0.95 FROM sales_data)
)
SELECT s.Product_ID,
       Count(*) as stockout_frequency
FROM Inventory_Date s
JOIN HighDemandProducts hdp ON s.Product_ID = hdp.Product_ID
WHERE s.Inventory_Quantity = 0
GROUP BY s.Product_ID;

## Influence of external factors
## GDP is overall economic health. Lower GDP is an indicator of economic downturn
## High inflation rate can deter customers purchasing power.
## Influence of GDP
select * from Inventory_Date
Select Product_ID, GDP,
Avg(Case when 'GDP'>=0 then Inventory_Quantity else null end) As avg_sales_positive_gdp,
Avg(Case when 'GDP'<0 then Inventory_Quantity else null end) As avg_sales_non_negative_gdp
From Inventory_Date
Group by 1,2
Having avg_sales_positive_gdp Is NOT Null;

Select Product_ID, Inflation_Rate,
Avg(Case when 'Inflation_Rate'>=0 then Inventory_Quantity else null end) As avg_sales_positive_gdp,
Avg(Case when 'Inflation_Rate'<0 then Inventory_Quantity else null end) As avg_sales_non_negative_gdp
From Inventory_Date
Group by 1,2
Having avg_sales_positive_gdp Is NOT Null;

##Inventory Optimisation aims to ensure the right stock is maintained to meet customers demand
## Determine the optimal reorder point
## Reorder Point, inventory level at which a new order should be placed.
## Reorder Point = Lead time demand + Safety Stock
## Lead time expected sales during the lead time.
## Lead time = Rolling average sales * lead time.
## Safety stock, buffer stock to account for demand and supply.
## Safety stock = Z * the root of lead time * standard deviation of demand.
## Lead time between placing an order and receiving it
## A constant lead time of 7 days for all products
## We aim for a 95% service level

WITH InventoryCalculation AS (
    SELECT 
        Product_ID,
        AVG(rolling_avg_sales) AS avg_rolling_sales,
        AVG(rolling_variance) AS avg_rolling_variance
    FROM (
        SELECT 
            Product_ID,
            AVG(daily_sales) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
            AVG(squared_diff) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
        FROM (
            SELECT 
                Product_ID, 
                Sales_Date, 
                Inventory_Quantity * Product_Cost AS daily_sales,
                (Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) *
                (Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
            FROM Inventory_Date
        ) subquery
    ) subquery2
    GROUP BY Product_ID
)
SELECT 
    Product_ID,
    avg_rolling_sales,
    avg_rolling_variance,
    avg_rolling_sales * 7 AS lead_time_demand,
    1.645 * (avg_rolling_variance * 7) AS safety_stock,
    (avg_rolling_sales * 7) + (1.645 * (avg_rolling_variance * 7)) AS reorder_point
FROM InventoryCalculation;
## Safety stock of 0 means they have to start re-ordering the products

## Create Optimisation Table
Create table inventory_optimization (
Product_ID int,
reorder_point double
);

## Step 2: Create the stored Procedure to recalculate reorder point
DELIMITER //

CREATE PROCEDURE RecalculateReorderPoint(IN productID INT)
BEGIN
    DECLARE avg_rolling_sales DOUBLE;
    DECLARE avg_rolling_variance DOUBLE;
    DECLARE lead_time_demand DOUBLE;
    DECLARE safety_stock DOUBLE;
    DECLARE reorder_point DOUBLE;

    SELECT 
        AVG(rolling_avg_sales),
        AVG(rolling_variance)
    INTO 
        avg_rolling_sales,
        avg_rolling_variance
    FROM (
        SELECT 
            Product_ID,
            AVG(daily_sales) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
            AVG(squared_diff) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
        FROM (
            SELECT 
                Product_ID, 
                Sales_Date, 
                Inventory_Quantity * Product_Cost AS daily_sales,
                (Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) *
                (Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
            FROM Inventory_Date
            WHERE Product_ID = productID
        ) AS inner_derived
    ) AS outer_derived;

    SET lead_time_demand = avg_rolling_sales * 7;
    SET safety_stock = 1.645 * SQRT(avg_rolling_variance * 7);
    SET reorder_point = lead_time_demand + safety_stock;

    INSERT INTO inventory_optimization (Product_ID, reorder_point)
    VALUES (productID, reorder_point)
    ON DUPLICATE KEY UPDATE reorder_point = reorder_point;
END //

DELIMITER ;

## Step 3: make inventory_data a permanent table
create table Inventory_table as select * from inventory_Date

## Step 4: create the trigger
DELIMITER //

DROP TRIGGER IF EXISTS AfterInsertUnifiedTable;
CREATE TRIGGER AfterInsertUnifiedTable
AFTER INSERT ON Inventory_table
FOR EACH ROW
BEGIN
    CALL RecalculateReorderPoint(NEW,Product_ID);
END//

DELIMITER ;

## Analysing overstocking and understocking products
## Overstocking refers to a situation where a company holds more inventory than is necessary to meet customer demand
## Understocking occurs when a company holds insufficient inventory to meet customer demand.

WITH RollingSales AS (
    SELECT 
        Product_ID,
        Sales_Date,
        AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
    FROM 
        inventory_table
),
 ## Calculate the number of days a product was out of stock
StockoutDays AS (
    SELECT 
        Product_ID,
        COUNT(*) AS stockout_days
    FROM 
        inventory_table
    WHERE 
        Inventory_Quantity = 0
    GROUP BY 
        Product_ID
)
 ## Join the above CTEs with the main table to get the results
SELECT 
    f.Product_ID,
    AVG(f.Inventory_Quantity * f.Product_Cost) AS avg_inventory_value,
    AVG(rs.rolling_avg_sales) AS avg_rolling_sales,
    COALESCE(sd.stockout_days, 0) AS stockout_days
FROM 
    inventory_table f
JOIN 
    RollingSales rs ON f.Product_ID = rs.Product_ID AND f.Sales_Date = rs.Sales_Date
LEFT JOIN 
    StockoutDays sd ON f.Product_ID = sd.Product_ID
GROUP BY 
    f.Product_ID, sd.stockout_days;
    
    ## Most of the products are constantly overstocked.
    ## No understocked products
    
    ## Monitor and Adjust Procedure
    ## Monitor inventory levels
    
    DELIMITER //
    CREATE PROCEDURE MonitorInventorylevels()
    begin
    Select Product_ID, Avg(Inventory_Quantity) as AvgInventory
    From Inventory_table
    group by Product_ID
    order by AvgInventory desc;
    END//
    
    Delimiter ;
    
     ## Monitor Sales Trends
    
    DELIMITER //
    CREATE PROCEDURE MonitorSalesTrends()
    begin
    Select Product_ID, Sales_Date,
    AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
    From Inventory_table
	order by Product_ID, Sales_Date;
    END//
    
    Delimiter ;

 ## Monitor Stockout Frequencies
DELIMITER //
    CREATE PROCEDURE MonitorStockouts()
    begin
    Select Product_ID, Count(*) as StockoutDays
    From Inventory_table
    where Inventory_Quantity = 0
    group by Product_ID
    order by StockoutDays desc;
    END//
    
    Delimiter ;
    
## Feedback Loop
## Feedback Loop Establishment:
## Feedback Portal: Develop an online platform for stakeholders to easily submit feedback on inventory performance and challenges.
## Review Meetings: Organize periodic sessions to discuss inventory system performance and gather direct insights.
## System Monitoring: Use established SQL procedures to track system metrics, with deviations from expectations flagged for review.
## Refinement Based on Feedback:
## Feedback Analysis: Regularly compile and scrutinize feedback to identify recurring themes or pressing issues.
## Action Implementation: Prioritize and act on the feedback to adjust reorder points, safety stock levels, or overall processes.
## Change Communication: Inform stakeholders about changes, underscoring the value of their feedback and ensuring transparency.

## Insights
## Inventory Discrepancies
## The initial stages of the analysis revealed significant discrepancies in inventory levels, with instances of overstocking. These inconsistencies were contributing to customer capital inefficiencies and dissatisfaction.
## Sales Trends and External Influences
## The analysis indicated that sales trends were notably influenced by various external factors. Recognizing these patterns presents an opportunity to forecast demand more accurately.
## Suboptimal Inventory Levels
## Through the inventory optimization analysis, it was evident that the existing inventory levels were not optimized for current sales trends. Products were identified that had either close excess inventory.

## Recommendations
## 1. Implement Dynamic Inventory Management: The company should transition from a static to a dynamic management system, adjusting inventory levels based on real-time sales trends, seasonality, and external factors.
## 2. Optimize Reorder Points and Safety Stocks: Use the reorder points and safety stocks calculated during the analysis to minimize stockouts and reduce excess inventory. Regularly review these metrics to ensure they align with current market conditions.
## 3. Enhance Pricing Strategies: Conduct a thorough review of product pricing strategies, especially for products identified as unprofitable. Consider factors such as competitor pricing, market demand, and product acquisition costs.
## 4. Reduce Overstock: Identify products that are consistently overstocked and take steps to reduce their inventory levels. This could include promotional sales, discounts, or even discontinuing products with low sales performance.
## 5. Establish a Feedback Loop: Develop a systematic approach to collect and analyze feedback from various stakeholders. Use this feedback for continuous improvement and alignment with business objectives.
## 6. Regular Monitoring and Adjustments: Adopt a proactive approach to inventory management by regularly monitoring key metrics and making necessary adjustments to inventory levels, order quantities, and safety stocks.

